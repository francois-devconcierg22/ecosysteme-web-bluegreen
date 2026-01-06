#!/usr/bin/env bash
set -euo pipefail

BASE="/home/adminso/bluegreen_v7_dev"
SRC="$BASE/src"
COMPOSE_APP="$SRC/docker-compose.app.yml"
COMPOSE_WPCLI="$SRC/docker-compose.wpcli.override.yml"
RUNTIME="$BASE/tmp/runtime.env"
NET="bg_shared_net"

say(){ echo -e "$*"; }
hdr(){ echo "============================================================"; echo " $*"; echo "============================================================"; }

need(){ [[ -e "$1" ]] || { echo "[FATAL] manquant: $1" >&2; exit 1; }; }

hdr "AUDIT BLUEGREEN v7 — DOCKER / COMPOSE / NETWORK / DB"
need "$COMPOSE_APP"
need "$RUNTIME"

say "\n[1] FICHIERS COMPOSE ACTIFS (hors backups)"
find "$SRC" -maxdepth 1 -type f -name 'docker-compose*.yml' ! -name '*.bak.*' -print | sort

say "\n[2] CHECK env_file runtime.env (chemins effectifs)"
for f in $(find "$SRC" -maxdepth 1 -type f -name 'docker-compose*.yml' ! -name '*.bak.*' -print | sort); do
  echo "----- $f"
  awk '
    $0 ~ /^[[:space:]]*env_file:[[:space:]]*$/ {inblock=1; print NR ": " $0; next}
    inblock && $0 ~ /^[[:space:]]*-[[:space:]]*/ {print NR ": " $0; next}
    inblock {inblock=0}
  ' "$f" || true
done

say "\n[3] CHECK container_name (si absent → dérive src-*-1)"
grep -n "container_name" "$COMPOSE_APP" || echo "[WARN] Aucun container_name dans docker-compose.app.yml (risque élevé)"

say "\n[4] CHECK réseaux déclarés et utilisés"
echo "---- docker-compose.app.yml networks"
grep -nE '^[[:space:]]*networks:|bg_shared_net|external:|name:' "$COMPOSE_APP" || true
echo "---- docker-compose.wpcli.override.yml networks"
[[ -f "$COMPOSE_WPCLI" ]] && grep -nE '^[[:space:]]*networks:|bg_shared_net|external:|name:' "$COMPOSE_WPCLI" || true

say "\n[5] CHECK runtime.env (DB vars)"
grep -E '^(DB_NAME|DB_USER|DB_PASSWORD|MYSQL_ROOT_PASSWORD)=' "$RUNTIME" || true

say "\n[6] ÉTAT CONTENEURS (focus db/wp/traefik)"
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}' | egrep 'db|wp|traefik|src-' || true

say "\n[7] RÉSEAUX DOCKER — attachements"
echo "---- bg_shared_net"
docker network inspect "$NET" 2>/dev/null | sed -n '/"Containers":/,/},/p' || echo "[WARN] bg_shared_net introuvable"
echo "---- src_default (si existe)"
docker network inspect src_default 2>/dev/null | sed -n '/"Containers":/,/},/p' || echo "(absent)"

say "\n[8] ALIAS sur bg_shared_net (db / wp-blue / wp-green)"
for n in bg-db src-db-1 db wp-blue src-wp-blue-1 wp-green src-wp-green-1; do
  if docker inspect "$n" >/dev/null 2>&1; then
    echo "---- $n"
    docker inspect -f '{{.Name}} :: {{range $k,$v := .NetworkSettings.Networks}}NET={{$k}} ALIASES={{json $v.Aliases}}{{"\n"}}{{end}}' "$n" | sed 's/\\//g'
  fi
done

say "\n[9] TEST DB — mode réseau (comme WordPress)"
set -a; source "$RUNTIME"; set +a
if [[ -n "${DB_NAME:-}" && -n "${DB_USER:-}" && -n "${DB_PASSWORD:-}" ]]; then
  docker run --rm --network "$NET" mysql:8.0 \
    mysql -h db -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" -e "SELECT 1;" \
    && echo "[OK] DB réseau OK" \
    || echo "[KO] DB réseau KO"
else
  echo "[WARN] DB vars absentes dans runtime.env, test réseau impossible"
fi

say "\n[10] TEST DB — mode compose exec (dépend service name/projet)"
if docker compose -f "$COMPOSE_APP" ps >/dev/null 2>&1; then
  if docker compose -f "$COMPOSE_APP" exec -T db mysql -uroot -p"${MYSQL_ROOT_PASSWORD:-}" -e "SELECT 1;" >/dev/null 2>&1; then
    echo "[OK] compose exec db OK"
  else
    echo "[KO] compose exec db KO (service db/projet compose incohérent ou root pwd absent)"
  fi
else
  echo "[WARN] docker compose ps KO (projet compose non cohérent)"
fi

say "\n[11] CHECK cohérence attendue (noms cibles)"
echo "Attendu (scripts) : bg-db, wp-blue, wp-green"
echo "Vu (docker ps)    :"
docker ps --format '{{.Names}}' | egrep 'bg-db|wp-blue|wp-green|src-db-1|src-wp-blue-1|src-wp-green-1' || true

hdr "FIN AUDIT — si tu vois src-*-1, il faut recanoniser container_name/projet compose"
