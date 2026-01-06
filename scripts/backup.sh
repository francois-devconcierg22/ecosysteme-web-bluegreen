#!/bin/bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="${BASE_DIR}/backups/$(date +%Y%m%d_%H%M)"

mkdir -p "${BACKUP_DIR}"

bash "${BASE_DIR}/scripts/backup_db.sh" "${BACKUP_DIR}"
bash "${BASE_DIR}/scripts/backup_files.sh" "${BACKUP_DIR}"
bash "${BASE_DIR}/scripts/backup_rotation.sh" "${BASE_DIR}/backups"
