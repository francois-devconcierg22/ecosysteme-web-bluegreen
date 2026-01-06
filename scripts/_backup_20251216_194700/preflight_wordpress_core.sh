#!/usr/bin/env bash
set -euo pipefail

fatal() { echo "[FATAL] $*" >&2; exit 1; }
info() { echo "[INFO] $*"; }

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

info "Preflight WORDPRESS CORE"

[[ -f "$BASE_DIR/wp-config.template.php" ]] || fatal "wp-config.template.php manquant"
[[ -x "$BASE_DIR/scripts/download_wordpress.sh" ]] || fatal "download_wordpress.sh manquant ou non exécutable"

info "Preflight WORDPRESS CORE OK"
