#!/usr/bin/env bash
set -euo pipefail

BASE="/home/adminso/bluegreen_v7_dev"
SRC="$BASE/src"
RUNTIME="$BASE/tmp/runtime.env"
COMPOSE_APP="$SRC/docker-compose.app.yml"
COMPOSE_WPCLI="$SRC/docker-compose.wpcli.override.yml"
NET="bg_shared_net"
PROJECT="bgv7"

log(){ echo "[RECANON] $*"; }
fail(){ echo "[FATAL] $*" >&2; exit 1; }

echo "============================================================"
echo " RECANONIZE STACK v7 — NAMES + PROJECT + NETWORK"
echo "============================================================"

[[ -f "$RUNTIME" ]] || fail "runtime.env manquant: $RUNTIME"
docker network inspect "$NET" >/dev/null 2>&1 || fail "Réseau requis absent: $NET"

TS="$(date +%Y%m%d-%H%M%S)"
cp "$COMPOSE_APP" "$COMPOSE_APP.bak.recanon.$TS" 2>/dev/null || true
cp "$COMPOSE_WPCLI" "$COMPOSE_WPCLI.bak.recanon.$TS" 2>/dev/null || true
log "Backups créés (timestamp=$TS)"

log "1) Écriture docker-compose.app.yml CANONIQUE (container_name stables)"
cat > "$COMPOSE_APP" <<YML
services:
  db:
    image: mysql:8.0
    container_name: bg-db
    restart: unless-stopped
    env_file:
      - ../tmp/runtime.env
    environment:
      MYSQL_ROOT_PASSWORD: \${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: \${DB_NAME}
      MYSQL_USER: \${DB_USER}
      MYSQL_PASSWORD: \${DB_PASSWORD}
    volumes:
      - db_data:/var/lib/mysql
    networks:
      - ${NET}

  wp-blue:
    image: wordpress:php8.2-fpm
    container_name: wp-blue
    restart: unless-stopped
    depends_on:
      - db
    env_file:
      - ../tmp/runtime.env
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: \${DB_USER}
      WORDPRESS_DB_PASSWORD: \${DB_PASSWORD}
      WORDPRESS_DB_NAME: \${DB_NAME}
    volumes:
      - ./blue/wp:/var/www/html
    networks:
      - ${NET}

  wp-green:
    image: wordpress:php8.2-fpm
    container_name: wp-green
    restart: unless-stopped
    depends_on:
      - db
    env_file:
      - ../tmp/runtime.env
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: \${DB_USER}
      WORDPRESS_DB_PASSWORD: \${DB_PASSWORD}
      WORDPRESS_DB_NAME: \${DB_NAME}
    volumes:
      - ./green/wp:/var/www/html
    networks:
      - ${NET}

networks:
  ${NET}:
    external: true
    name: ${NET}

volumes:
  db_data:
YML

log "2) Validation compose (avec env-file)"
docker compose -p "$PROJECT" -f "$COMPOSE_APP" --env-file "$RUNTIME" config >/dev/null

log "3) Stop & reset (DB incluse) + suppression des anciens containers src-* si présents"
docker compose -p "$PROJECT" -f "$COMPOSE_APP" --env-file "$RUNTIME" down -v --remove-orphans || true
docker rm -f src-db-1 src-wp-blue-1 src-wp-green-1 >/dev/null 2>&1 || true

log "4) Démarrage stack (project=$PROJECT)"
docker compose -p "$PROJECT" -f "$COMPOSE_APP" --env-file "$RUNTIME" up -d

log "5) Vérification conteneurs attendus"
docker ps --format 'table {{.Names}}\t{{.Status}}' | egrep 'bg-db|wp-blue|wp-green' || fail "Conteneurs attendus non visibles"

log "6) Smoke test DB réseau (comme WordPress)"
set -a; source "$RUNTIME"; set +a
: "${DB_NAME:?}"; : "${DB_USER:?}"; : "${DB_PASSWORD:?}"

for i in $(seq 1 60); do
  if docker run --rm --network "$NET" mysql:8.0 \
    mysql -h db -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" -e "SELECT 1;" >/dev/null 2>&1; then
    log "DB prête (réseau OK)"
    break
  fi
  sleep 2
done

docker run --rm --network "$NET" mysql:8.0 \
  mysql -h db -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" -e "SELECT 1;" >/dev/null 2>&1 \
  || fail "DB non prête (réseau) après timeout"

echo "============================================================"
echo "[OK] STACK RECANONISÉE — noms stables + DB OK"
echo "============================================================"

log "7) Lancement C2 (bootstrap WP)"
exec "$BASE/src/scripts/run_wp_bootstrap.sh"
