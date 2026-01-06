#!/bin/bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BASE_ENV="${BASE_DIR}/env_base.env"
SECRETS="${BASE_DIR}/secrets.env"
FINAL="${BASE_DIR}/.env"

if [ ! -f "${BASE_ENV}" ]; then
  echo "[FATAL] env_base.env introuvable (${BASE_ENV})"
  exit 1
fi

if [ ! -f "${SECRETS}" ]; then
  echo "[WARNING] secrets.env introuvable, génération d un fichier vide"
  touch "${SECRETS}"
fi

cat "${BASE_ENV}" > "${FINAL}"
echo "" >> "${FINAL}"
cat "${SECRETS}" >> "${FINAL}"

echo "[OK] .env final généré (${FINAL})"
