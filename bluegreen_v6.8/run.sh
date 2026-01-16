#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# BlueGreen Orchestrator v6.8 — ENTRYPOINT
# SAFE / DRY-RUN ONLY (version 0.1)
# ============================================================

# ============================================================
# CONSTANTS
# ============================================================
EXIT_CONFIG_ERROR=42

# ============================================================
# HELPERS
# ============================================================
die() {
  local code="$1"
  shift
  echo "[ERROR] $*" >&2
  exit "$code"
}

info() {
  echo "[INFO] $*"
}

# ============================================================
# BASE DIRECTORY
# ============================================================
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ============================================================
# LOAD GLOBAL.CONF
# ============================================================
GLOBAL_CONF="$BASE_DIR/global.conf"

if [[ ! -f "$GLOBAL_CONF" ]]; then
  die "$EXIT_CONFIG_ERROR" "Missing global.conf"
fi

info "Loading global.conf"
# shellcheck disable=SC1090
source "$GLOBAL_CONF"

# ============================================================
# VALIDATE GLOBAL VARIABLES
# ============================================================
[[ -n "${PROJECT_ID:-}" ]] || die "$EXIT_CONFIG_ERROR" "PROJECT_ID is not set"
[[ -n "${INSTALL_MODE:-}" ]] || die "$EXIT_CONFIG_ERROR" "INSTALL_MODE is not set"

case "$INSTALL_MODE" in
  SERVER_NEUF|PROJET_UNIQUE|MULTI_PROJETS)
    ;;
  *)
    die "$EXIT_CONFIG_ERROR" "Invalid INSTALL_MODE: $INSTALL_MODE"
    ;;
esac

info "PROJECT_ID=$PROJECT_ID"
info "INSTALL_MODE=$INSTALL_MODE"

# ============================================================
# LOAD SITE.CONF
# ============================================================
SITE_KEY="${1:-}"

if [[ -z "$SITE_KEY" ]]; then
  die "$EXIT_CONFIG_ERROR" "SITE_KEY argument required (example: ./run.sh example status)"
fi

SITE_CONF="$BASE_DIR/sites/$SITE_KEY/site.conf"

if [[ ! -f "$SITE_CONF" ]]; then
  die "$EXIT_CONFIG_ERROR" "Missing site.conf for site '$SITE_KEY'"
fi

info "Loading site.conf for site '$SITE_KEY'"
# shellcheck disable=SC1090
source "$SITE_CONF"

# ============================================================
# VALIDATE SITE VARIABLES
# ============================================================
[[ -n "${SITE_KEY:-}" ]] || die "$EXIT_CONFIG_ERROR" "SITE_KEY not set in site.conf"
[[ -n "${PRIMARY_DOMAIN:-}" ]] || die "$EXIT_CONFIG_ERROR" "PRIMARY_DOMAIN not set in site.conf"

info "SITE_KEY=$SITE_KEY"
info "PRIMARY_DOMAIN=$PRIMARY_DOMAIN"

# ============================================================
# DRY-RUN GUARANTEE
# ============================================================
info "DRY-RUN MODE ACTIVE — no infrastructure action will be performed"

# ============================================================
# COMMAND DISPATCH (STUB)
# ============================================================
COMMAND="${2:-status}"

info "Command: $COMMAND"

case "$COMMAND" in
  status)
    info "Status OK (stub — no action performed)"
    ;;
  *)
    die "$EXIT_CONFIG_ERROR" "Unknown command: $COMMAND"
    ;;
esac

# ============================================================
# END
# ============================================================

