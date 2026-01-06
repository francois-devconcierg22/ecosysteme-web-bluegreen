#!/bin/bash
set -euo pipefail

# ============================================================
# BLUE/GREEN – GENERATION DES SECRETS (PIPEFAIL SAFE)
# ============================================================

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SECRETS_FILE="${BASE_DIR}/secrets.env"
ENV_FILE="${BASE_DIR}/.env"

echo "============================================================"
echo " BLUE/GREEN – GENERATION DES SECRETS"
echo " BASE_DIR : ${BASE_DIR}"
echo "============================================================"

# ------------------------------------------------------------
# Sécurité : ne jamais écraser
# ------------------------------------------------------------
if [ -f "${ENV_FILE}" ] || [ -f "${SECRETS_FILE}" ]; then
  echo "[INFO] Secrets déjà présents → génération ignorée."
  exit 0
fi

# ------------------------------------------------------------
# Générateur SAFE (neutralise pipefail localement)
# ------------------------------------------------------------
gen_pass() {
  set +o pipefail
  LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 32
  set -o pipefail
}

DB_NAME="wordpress"
DB_USER="wp_user"
DB_PASSWORD="$(gen_pass)"
MYSQL_ROOT_PASSWORD="$(gen_pass)"

# ------------------------------------------------------------
# Écriture simple, sans heredoc
# ------------------------------------------------------------
{
  printf 'DB_NAME=%s\n' "${DB_NAME}"
  printf 'DB_USER=%s\n' "${DB_USER}"
  printf 'DB_PASSWORD=%s\n' "${DB_PASSWORD}"
  printf 'MYSQL_ROOT_PASSWORD=%s\n' "${MYSQL_ROOT_PASSWORD}"
} > "${SECRETS_FILE}"

chmod 600 "${SECRETS_FILE}"

echo "[OK] secrets.env généré : ${SECRETS_FILE}"
