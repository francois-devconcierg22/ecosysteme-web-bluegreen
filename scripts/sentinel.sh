#!/bin/bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="${BASE_DIR}/logs"
mkdir -p "${LOG_DIR}"

LOG_FILE="${LOG_DIR}/sentinel_$(date +%Y%m%d).log"

{
  echo "============================================================"
  echo " SENTINEL – BLUE/GREEN HEALTH CHECK $(date)"
  echo "============================================================"

  # Container check
  for c in traefik db wp-blue wp-green; do
    if docker ps --format '{{.Names}}' | grep -q "^${c}\$"; then
      echo "[OK] Container ${c} UP"
    else
      echo "[CRITICAL] Container ${c} DOWN"
    fi
  done

  # HTTP check (localhost)
  if bash "${BASE_DIR}/scripts/monitoring_wp.sh" "http://localhost" >/dev/null 2>&1; then
    echo "[OK] WordPress répond sur http://localhost"
  else
    echo "[CRITICAL] WordPress ne répond pas sur http://localhost"
  fi

} >> "${LOG_FILE}" 2>&1
