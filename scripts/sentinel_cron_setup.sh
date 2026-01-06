#!/bin/bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="${BASE_DIR}/scripts/sentinel.sh"

if ! command -v crontab >/dev/null 2>&1; then
  echo "[FATAL] crontab non disponible"
  exit 1
fi

( crontab -l 2>/dev/null | grep -v "${SCRIPT}" ; echo "*/5 * * * * bash ${SCRIPT}" ) | crontab -

echo "[OK] Cron Sentinel configuré (toutes les 5 minutes)"
