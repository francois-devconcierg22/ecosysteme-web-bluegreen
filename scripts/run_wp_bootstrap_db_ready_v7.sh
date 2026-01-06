#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/home/adminso/bluegreen_v7_dev"
C2="$BASE_DIR/src/scripts/run_wp_bootstrap.sh"
RUNTIME_ENV="$BASE_DIR/tmp/runtime.env"
NET="bg_shared_net"

log(){ echo "[C2-WRAPPER] $*"; }
fail(){ echo "[FATAL] $*" >&2; exit 1; }

echo "============================================================"
echo " C2 WRAPPER — DB READY (NETWORK MODE) v7"
echo "============================================================"

[[ -f "$C2" ]] || fail "C2 introuvable"
[[ -f "$RUNTIME_ENV" ]] || fail "runtime.env introuvable"

set -a
source "$RUNTIME_ENV"
set +a

: "${DB_NAME:?}"
: "${DB_USER:?}"
: "${DB_PASSWORD:?}"

log "Attente DB (connexion réseau WordPress)…"

for i in $(seq 1 60); do
  if docker run --rm --network "$NET" mysql:8.0 \
    mysql -h db -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" \
    -e "SELECT 1;" >/dev/null 2>&1; then
    log "DB prête (connexion réseau OK)"
    break
  fi
  sleep 2
done

docker run --rm --network "$NET" mysql:8.0 \
  mysql -h db -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" \
  -e "SELECT 1;" >/dev/null 2>&1 \
  || fail "DB non prête après timeout"

log "Lancement C2 (bootstrap WordPress)"
exec "$C2"
