#!/usr/bin/env bash
set -euo pipefail

BASE="/home/adminso/bluegreen_v7_dev"
SRC="$BASE/src"
RUNTIME="$BASE/tmp/runtime.env"
COMPOSE="$SRC/docker-compose.app.yml"

log(){ echo "[DB-RESET] $*"; }
fail(){ echo "[FATAL] $*" >&2; exit 1; }

[[ -f "$RUNTIME" ]] || fail "runtime.env manquant"
[[ -f "$COMPOSE" ]] || fail "docker-compose.app.yml manquant"

log "Chargement runtime.env"
set -a
source "$RUNTIME"
set +a

: "${DB_NAME:?}"
: "${DB_USER:?}"
: "${DB_PASSWORD:?}"
: "${MYSQL_ROOT_PASSWORD:?}"

log "Arrêt stack applicative"
docker compose -f "$COMPOSE" down -v

log "Suppression volumes DB persistants"
docker volume rm src_db_data db_data bgv7_db_data 2>/dev/null || true

log "Redémarrage stack DB avec secrets actuels"
docker compose -f "$COMPOSE" up -d bg-db

log "Attente MySQL…"
sleep 10

log "Test connexion applicative"
docker exec bg-db \
  mysql -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" \
  -e "SELECT 1;" >/dev/null

log "DB recréée et cohérente"
echo "============================================================"
echo "[OK] DB RESET + SECRETS ACTIFS"
echo "============================================================"
