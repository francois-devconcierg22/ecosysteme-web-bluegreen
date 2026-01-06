#!/bin/bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GLOBAL="${BASE_DIR}/global.conf"
OUTPUT="${BASE_DIR}/env_base.env"

if [ ! -f "${GLOBAL}" ]; then
  echo "[FATAL] global.conf introuvable (${GLOBAL})"
  exit 1
fi

echo "[INFO] Import des variables depuis global.conf → env_base.env"

# On ne garde que les lignes de type KEY=VALUE non commentées
grep -E '^[A-Z0-9_]+=' "${GLOBAL}" > "${OUTPUT}"

echo "[OK] env_base.env généré (${OUTPUT})"
