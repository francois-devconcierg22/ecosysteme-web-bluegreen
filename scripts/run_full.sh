#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TS="$(date '+%Y-%m-%d %H:%M:%S')"

log(){ printf "[%s] %s\n" "$TS" "$*"; }
fail(){ printf "[FATAL] %s\n" "$*"; exit 42; }

log "============================================================"
log " RUN FULL v7 — PIPELINE CANONIQUE"
log " ROOT : $ROOT"
log "============================================================"

##############################################################################
log "[STEP 1] INFRA ONLY"
exec_or_fail() {
  local s="$1"
  [ -x "$s" ] || fail "Script manquant : $s"
  "$s"
}

exec_or_fail "$ROOT/src/scripts/run_infra.sh"

##############################################################################
log "[STEP 2] WORDPRESS CORE"
exec_or_fail "$ROOT/src/scripts/run_infra_wp.sh"

##############################################################################
log "[STEP 3] WORDPRESS BOOTSTRAP"
exec_or_fail "$ROOT/src/scripts/run_wp_bootstrap.sh"

##############################################################################
log "============================================================"
log "[OK] FULL v7 — TERMINÉ SANS ERREUR"
log "============================================================"
