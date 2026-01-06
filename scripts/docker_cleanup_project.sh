#!/bin/bash
set -euo pipefail

# -------------------------------------------------------------------
# BLUE/GREEN – DOCKER CLEANUP PROJET (SAFE)
# -------------------------------------------------------------------

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_NAME="src"

echo "============================================================"
echo " BLUE/GREEN – DOCKER CLEANUP PROJET"
echo " BASE_DIR : ${BASE_DIR}"
echo "============================================================"

# Containers ciblés explicitement
CONTAINERS=(
  wp-blue
  wp-green
  bg-db
  traefik
)

echo "[INFO] Arrêt des containers projet (si existants)…"

for c in "${CONTAINERS[@]}"; do
  if docker ps -a --format '{{.Names}}' | grep -q "^${c}$"; then
    echo " - stop ${c}"
    docker stop "${c}" >/dev/null 2>&1 || true
    echo " - rm ${c}"
    docker rm "${c}" >/dev/null 2>&1 || true
  else
    echo " - ${c} absent (OK)"
  fi
done

# Network Docker Compose standard
NETWORK="${PROJECT_NAME}_default"

echo "[INFO] Nettoyage réseau Docker : ${NETWORK}"

if docker network ls --format '{{.Name}}' | grep -q "^${NETWORK}$"; then
  docker network rm "${NETWORK}" >/dev/null 2>&1 || true
  echo " - réseau supprimé"
else
  echo " - réseau absent (OK)"
fi

echo "------------------------------------------------------------"
echo "[OK] Docker cleanup projet terminé (SAFE)"
echo "------------------------------------------------------------"
