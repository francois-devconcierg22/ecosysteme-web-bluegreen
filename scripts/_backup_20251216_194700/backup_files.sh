#!/bin/bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <backup_dir>"
  exit 1
fi

BACKUP_DIR="$1"
mkdir -p "${BACKUP_DIR}"

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATE="$(date +%Y%m%d_%H%M%S)"
FILE="${BACKUP_DIR}/files_${DATE}.tar.gz"

echo "[INFO] Backup fichiers (blue/wp + green/wp) → ${FILE}"

tar -czf "${FILE}" -C "${BASE_DIR}" blue/wp green/wp

echo "[OK] Backup fichiers terminé"
