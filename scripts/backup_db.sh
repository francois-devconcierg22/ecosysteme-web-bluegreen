#!/bin/bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <backup_dir>"
  exit 1
fi

BACKUP_DIR="$1"
mkdir -p "${BACKUP_DIR}"

DATE="$(date +%Y%m%d_%H%M%S)"
FILE="${BACKUP_DIR}/db_${DATE}.sql.gz"

echo "[INFO] Backup DB → ${FILE}"

docker exec db sh -c 'mysqldump -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"' | gzip > "${FILE}"

echo "[OK] Backup DB terminé"
