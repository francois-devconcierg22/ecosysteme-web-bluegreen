#!/bin/bash
set -euo pipefail

ROOT="/home/adminso/bluegreen_v7_dev"
ENV_FILE="$ROOT/.env"
RUNTIME_ENV="$ROOT/tmp/runtime.env"
COMPOSE="$ROOT/compose_safe.sh"
TS="$(date '+%Y-%m-%d %H:%M:%S')"

mask() {
  local s="${1:-}"
  [ -z "$s" ] && printf "<empty>" && return
  printf "%s***%s" "${s:0:2}" "${s: -2}"
}

log() {
  printf "\n=================================================\n"
  printf "%s\n" "$1"
  printf "=================================================\n"
}

##############################################################################
log "[RESET-DB] RESET DB CANONIQUE + PREUVE SQL v7"
printf "DATE : %s\n" "$TS"
printf "ROOT : %s\n" "$ROOT"

##############################################################################
log "[STEP 1] Chargement des sources de vérité"

for f in "$ENV_FILE" "$RUNTIME_ENV"; do
  if [ ! -f "$f" ]; then
    printf "[FATAL] Fichier manquant : %s\n" "$f"
    exit 42
  fi
done

set -a
. "$ENV_FILE"
. "$RUNTIME_ENV"
set +a

REQUIRED=(
  WORDPRESS_DB_NAME
  WORDPRESS_DB_USER
  WORDPRESS_DB_PASSWORD
  MYSQL_ROOT_PASSWORD
)

for v in "${REQUIRED[@]}"; do
  if [ -z "${!v:-}" ]; then
    printf "[FATAL] Variable manquante : %s\n" "$v"
    exit 42
  fi
done

log "SNAPSHOT VARIABLES (AVANT RESET)"
printf "WORDPRESS_DB_NAME=%s\n" "$WORDPRESS_DB_NAME"
printf "WORDPRESS_DB_USER=%s\n" "$WORDPRESS_DB_USER"
printf "WORDPRESS_DB_PASSWORD(mask)=%s\n" "$(mask "$WORDPRESS_DB_PASSWORD")"
printf "MYSQL_ROOT_PASSWORD(mask)=%s\n" "$(mask "$MYSQL_ROOT_PASSWORD")"

##############################################################################
log "[STEP 2] Arrêt stack + purge volumes MySQL"

"$COMPOSE" down -v || true

##############################################################################
log "[STEP 3] Démarrage DB seule"

"$COMPOSE" up -d db

##############################################################################
log "[STEP 4] Détection DB canonique"

DB_SERVICE="$(
  "$COMPOSE" config --services \
  | grep -E '^(db|mysql|mariadb)$' \
  | head -n1
)"

if [ -z "$DB_SERVICE" ]; then
  printf "[FATAL] Aucun service DB détecté\n"
  exit 42
fi

DB_CONTAINER="$(
  docker ps --format '{{.Names}}' \
  | grep "$DB_SERVICE" \
  | head -n1
)"

if [ -z "$DB_CONTAINER" ]; then
  printf "[FATAL] Conteneur DB introuvable\n"
  exit 42
fi

printf "DB_SERVICE   = %s\n" "$DB_SERVICE"
printf "DB_CONTAINER = %s\n" "$DB_CONTAINER"

##############################################################################
log "[STEP 5] Attente MySQL prêt (niveau SQL)"

READY=0
for i in $(seq 1 30); do
  if docker exec "$DB_CONTAINER" \
    mysqladmin ping -uroot -p"$MYSQL_ROOT_PASSWORD" --silent \
    >/dev/null 2>&1; then
    READY=1
    printf "[OK] MySQL prêt après %s secondes\n" "$i"
    break
  fi
  sleep 1
done

if [ "$READY" -ne 1 ]; then
  printf "[FATAL] MySQL non prêt après timeout\n"
  exit 42
fi

##############################################################################
log "[STEP 6] PREUVE SQL — état réel MySQL"

docker exec "$DB_CONTAINER" \
  mysql -uroot -p"$MYSQL_ROOT_PASSWORD" <<SQL

SELECT 'DATABASE_EXISTS' AS CHECK_TYPE, SCHEMA_NAME
FROM INFORMATION_SCHEMA.SCHEMATA
WHERE SCHEMA_NAME = '$WORDPRESS_DB_NAME';

SELECT 'USER_EXISTS' AS CHECK_TYPE, user, host
FROM mysql.user
WHERE user = '$WORDPRESS_DB_USER';

SHOW GRANTS FOR '$WORDPRESS_DB_USER'@'%';

SQL

##############################################################################
log "[STEP 7] PREUVE AUTH — connexion utilisateur WordPress"

if docker exec "$DB_CONTAINER" \
  mysql -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" \
  -e "SELECT 1;" "$WORDPRESS_DB_NAME" \
  >/dev/null 2>&1; then
  printf "[OK] Authentification WP_USER valide\n"
else
  printf "[FATAL] WP_USER ne peut PAS se connecter à MySQL\n"
  exit 42
fi

##############################################################################
log "[STEP 8] Redémarrage stack complète"

"$COMPOSE" up -d

##############################################################################
log "[DONE] RESET DB CANONIQUE + PREUVE SQL — OK"
