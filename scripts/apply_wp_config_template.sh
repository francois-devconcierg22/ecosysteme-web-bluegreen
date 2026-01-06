#!/bin/bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE="${BASE_DIR}/wp/wp-config.template.php"

if [ ! -f "${TEMPLATE}" ]; then
  echo "[FATAL] Template wp-config.template.php introuvable (${TEMPLATE})"
  exit 1
fi

for slot in blue green; do
  TARGET="${BASE_DIR}/${slot}/wp/wp-config.php"
  echo "[INFO] Application du template de configuration pour ${slot} → ${TARGET}"
  cp "${TEMPLATE}" "${TARGET}"
done
