#!/bin/bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <backups_root_dir>"
  exit 1
fi

ROOT="$1"
RETENTION="${RETENTION_DAYS:-7}"

echo "[INFO] Rotation des backups (> ${RETENTION} jours)"

find "${ROOT}" -maxdepth 1 -type d -mtime "+${RETENTION}" -print -exec rm -rf {} \; || true

echo "[OK] Rotation des backups terminée"
