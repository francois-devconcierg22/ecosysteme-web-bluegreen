#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/home/adminso/bluegreen_v7_dev"
ENV_BASE="$BASE_DIR/src/env_base.env"
SECRETS="$BASE_DIR/tmp/db_secrets.env"

fail() { echo "[FATAL] $*" >&2; exit 1; }
log()  { echo "[INFRA] $*"; }

[[ -f "$ENV_BASE" ]] || fail "env_base.env manquant"
[[ -f "$SECRETS"  ]] || fail "db_secrets.env manquant"

log "Injection env_base.env (data-only)"
set -a
source <(grep -E "^[A-Z0-9_]+=.*" "$ENV_BASE")
source <(grep -E "^[A-Z0-9_]+=.*" "$SECRETS")
set +a

: "${DB_NAME:?}"
: "${DB_USER:?}"
: "${DB_PASSWORD:?}"
: "${MYSQL_ROOT_PASSWORD:?}"

log "DB runtime injecté : $DB_NAME / $DB_USER"
