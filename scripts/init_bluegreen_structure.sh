#!/bin/bash
set -euo pipefail

echo "============================================================"
echo " BLUE/GREEN – INITIALISATION STRUCTURE WORDPRESS"
echo "============================================================"

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_WP="${BASE_DIR}/wp"
BLUE_WP="${BASE_DIR}/blue/wp"
GREEN_WP="${BASE_DIR}/green/wp"

log() {
  echo "[INFO] $*"
}

fatal() {
  echo "[FATAL] $*" >&2
  exit 1
}

# ------------------------------------------------------------
# Vérifications préalables
# ------------------------------------------------------------
[ -d "${SRC_WP}" ] || fatal "Source WordPress absente : ${SRC_WP}"

mkdir -p "${BLUE_WP}" "${GREEN_WP}"

# ------------------------------------------------------------
# Déploiement WordPress → BLUE
# ------------------------------------------------------------
log "Déploiement WordPress dans blue/"

rsync -a --delete \
  --exclude 'wp-content/uploads/' \
  "${SRC_WP}/" "${BLUE_WP}/" \
  || fatal "Échec rsync vers blue"

# ------------------------------------------------------------
# Déploiement WordPress → GREEN
# ------------------------------------------------------------
log "Déploiement WordPress dans green/"

rsync -a --delete \
  --exclude 'wp-content/uploads/' \
  "${SRC_WP}/" "${GREEN_WP}/" \
  || fatal "Échec rsync vers green"

# ------------------------------------------------------------
# Sécurisation minimale des droits (host-side)
# ------------------------------------------------------------
chmod -R u+rwX,go+rX "${BASE_DIR}/blue" "${BASE_DIR}/green" || true

echo "============================================================"
echo " [OK] Initialisation structure Blue/Green terminée"
echo "============================================================"
