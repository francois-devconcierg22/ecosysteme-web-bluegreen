#!/usr/bin/env bash
set -euo pipefail

RUNTIME="/home/adminso/bluegreen_v7_dev/tmp/runtime.env"

log(){ echo "[RUNTIME-CHECK] $*"; }
fail(){ echo "[FATAL] $*" >&2; exit 1; }

[[ -f "$RUNTIME" ]] || fail "runtime.env absent : $RUNTIME"

log "Lecture runtime.env"
cat "$RUNTIME"

REQUIRED_VARS=(
  DB_NAME
  DB_USER
  DB_PASSWORD
  MYSQL_ROOT_PASSWORD
)

for v in "${REQUIRED_VARS[@]}"; do
  val="$(grep -E "^${v}=" "$RUNTIME" | cut -d= -f2- || true)"
  [[ -n "$val" ]] || fail "Variable vide ou absente : $v"
done

log "Toutes les variables DB sont présentes et non vides"

echo "============================================================"
echo "[OK] runtime.env VALIDÉ"
echo "============================================================"
