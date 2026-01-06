#!/bin/bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "------------------------------------------------------------"
echo " DOCKER CLEANUP PROJET (DB RESET SAFE)"
echo "------------------------------------------------------------"

cd "${BASE_DIR}"

docker compose -f docker-compose.app.yml down -v || true
docker compose -f docker-compose.traefik.yml down || true

echo "[INFO] Suppression secrets liés à l’ancienne DB"
rm -f secrets.env .env

echo "[OK] Docker cleanup + secrets reset terminé"
