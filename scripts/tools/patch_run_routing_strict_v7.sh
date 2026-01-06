#!/bin/bash
set -euo pipefail

ROOT="/home/adminso/bluegreen_v7_dev"
RUNSH="$ROOT/src/run.sh"
BACKUP_DIR="$ROOT/_patch_backups"
TS="$(date +%Y%m%d_%H%M%S)"

mkdir -p "$BACKUP_DIR"

log(){ printf "[%s] %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$*"; }
fail(){ printf "[FATAL] %s\n" "$*"; exit 42; }

log "PATCH ROUTAGE STRICT run.sh v7"
log "ROOT : $ROOT"

if [ -f "$RUNSH" ]; then
  cp -a "$RUNSH" "$BACKUP_DIR/run.sh.bak.$TS"
  log "Backup créé : $BACKUP_DIR/run.sh.bak.$TS"
else
  fail "run.sh absent"
fi

cat <<'RUNEOF' > "$RUNSH"
#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TS="$(date '+%Y-%m-%d %H:%M:%S')"

log(){ printf "[%s] %s\n" "$TS" "$*"; }
fail(){ printf "[FATAL] %s\n" "$*"; exit 42; }

MODE=""

if [ "$#" -ne 1 ]; then
  fail "Usage: $0 --mode=infra_only|infra_wp|full|update"
fi

case "$1" in
  --mode=infra_only) MODE="infra_only" ;;
  --mode=infra_wp)   MODE="infra_wp" ;;
  --mode=full)       MODE="full" ;;
  --mode=update)     MODE="update" ;;
  *) fail "Argument invalide : $1" ;;
esac

log "ROOT : $ROOT"
log "MODE CLI ACTIF : $MODE"

SCRIPT="$ROOT/src/scripts/run_${MODE}.sh"
[ -x "$SCRIPT" ] || fail "Script cible absent : $SCRIPT"

case "$MODE" in
  infra_only) exec "$ROOT/src/scripts/run_infra.sh" ;;
  infra_wp)   exec "$ROOT/src/scripts/run_infra_wp.sh" ;;
  full)       exec "$ROOT/src/scripts/run_full.sh" ;;
  update)     exec "$ROOT/src/scripts/run_update.sh" ;;
  *) fail "Mode invalide après parsing : $MODE" ;;
esac
RUNEOF

chmod +x "$RUNSH"
log "run.sh patché avec routage STRICT"
