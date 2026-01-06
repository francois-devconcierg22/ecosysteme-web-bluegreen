#!/usr/bin/env bash
set -euo pipefail

RUNTIME="/home/adminso/bluegreen_v7_dev/tmp/runtime.env"
TS="$(date +%Y%m%d-%H%M%S)"

log(){ echo "[DB-ROTATE] $*"; }
fail(){ echo "[FATAL] $*" >&2; exit 1; }

[[ -f "$RUNTIME" ]] || fail "runtime.env introuvable"

cp "$RUNTIME" "$RUNTIME.bak.$TS"
log "Backup créé : $RUNTIME.bak.$TS"

DB_NAME="wordpress"
DB_USER="wp_user"

DB_PASSWORD="$(openssl rand -base64 24)"
MYSQL_ROOT_PASSWORD="$(openssl rand -base64 32)"

cat > "$RUNTIME" <<EOF_ENV
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
EOF_ENV

log "Nouveaux secrets générés"
log "DB_NAME=$DB_NAME"
log "DB_USER=$DB_USER"
log "DB_PASSWORD=********"
log "MYSQL_ROOT_PASSWORD=********"

echo "============================================================"
echo "[OK] Secrets DB régénérés"
echo "============================================================"
