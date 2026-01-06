#!/bin/bash
set -euo pipefail

DB_CONTAINER="bg-db"
MAX_WAIT=60
WAITED=0

echo "------------------------------------------------------------"
echo " Attente disponibilité MySQL (${DB_CONTAINER})"
echo "------------------------------------------------------------"

until docker exec "${DB_CONTAINER}" mysqladmin ping -h "127.0.0.1" --silent; do
  sleep 2
  WAITED=$((WAITED + 2))
  echo "[INFO] MySQL pas encore prêt (${WAITED}s)"
  if [ "${WAITED}" -ge "${MAX_WAIT}" ]; then
    echo "[FATAL] MySQL indisponible après ${MAX_WAIT}s"
    exit 1
  fi
done

echo "[OK] MySQL prêt."
