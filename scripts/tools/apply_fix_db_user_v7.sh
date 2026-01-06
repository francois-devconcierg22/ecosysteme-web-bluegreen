#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/home/adminso/bluegreen_v7_dev"
RUNTIME_ENV="$BASE_DIR/tmp/runtime.env"
COMPOSE="$BASE_DIR/src/docker-compose.app.yml"

log(){ echo "[DB-FIX] $*"; }
fail(){ echo "[FATAL] $*" >&2; exit 1; }

echo "============================================================"
echo " FIX DB USER — WORDPRESS v7"
echo "============================================================"

[[ -f "$RUNTIME_ENV" ]] || fail "runtime.env introuvable"

set -a
source "$RUNTIME_ENV"
set +a

: "${MYSQL_ROOT_PASSWORD:?}"
: "${DB_NAME:?}"
: "${DB_USER:?}"
: "${DB_PASSWORD:?}"

log "Attente DB root…"
for i in $(seq 1 30); do
  if docker compose -f "$COMPOSE" exec -T db \
    mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "SELECT 1;" >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

docker compose -f "$COMPOSE" exec -T db \
  mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "SELECT 1;" \
  || fail "MySQL root inaccessible"

log "Création / réparation user WordPress"

docker compose -f "$COMPOSE" exec -T db \
  mysql -uroot -p"$MYSQL_ROOT_PASSWORD" <<SQL
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
ALTER USER '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
SQL

log "Test connexion applicative WordPress"

docker run --rm \
  --network bg_shared_net \
  mysql:8.0 \
  mysql -h db -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" \
  -e "SELECT 1;" \
  || fail "Connexion applicative toujours impossible"

log "OK — DB WordPress opérationnelle"

echo "============================================================"
echo "[OK] DB réparée — prête pour C2"
echo "============================================================"
