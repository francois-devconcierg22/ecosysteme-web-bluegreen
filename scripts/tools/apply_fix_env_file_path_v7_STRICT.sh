#!/usr/bin/env bash
set -euo pipefail

############################################################
# FIX ENV_FILE PATH — STRICT MODE — BLUEGREEN v7
############################################################

BASE_DIR="/home/adminso/bluegreen_v7_dev"
COMPOSE_DIR="$BASE_DIR/src"
RUNTIME_REAL="$BASE_DIR/tmp/runtime.env"

log()  { echo "[FIX] $*"; }
fail() { echo "[FATAL] $*" >&2; exit 1; }

echo "============================================================"
echo " FIX ENV_FILE PATH — STRICT MODE (v7)"
echo "============================================================"

# 1) Pré-checks
[[ -f "$RUNTIME_REAL" ]] || fail "runtime.env introuvable dans $BASE_DIR/tmp"

# 2) Sauvegarde de tous les docker-compose*
TS="$(date +%Y%m%d-%H%M%S)"
for f in "$COMPOSE_DIR"/docker-compose*.yml; do
  cp "$f" "$f.bak.$TS"
done
log "Backups créés (*.bak.$TS)"

# 3) Audit AVANT
echo
log "Audit AVANT correction (env_file trouvés) :"
grep -RIn "env_file" "$COMPOSE_DIR"

# 4) Correction LARGE SPECTRE
log "Correction de TOUS les chemins env_file → ../tmp/runtime.env"

sed -i \
  -e 's|./tmp/runtime.env|../tmp/runtime.env|g' \
  -e 's|tmp/runtime.env|../tmp/runtime.env|g' \
  -e 's|/tmp/runtime.env|../tmp/runtime.env|g' \
  "$COMPOSE_DIR"/docker-compose*.yml

# 5) Audit APRÈS
echo
log "Audit APRÈS correction :"
grep -RIn "env_file" "$COMPOSE_DIR"

# 6) Vérification FINALE (aucune variante interdite)
if grep -RInE '(\./tmp/|[^.]tmp/|/tmp/).*runtime.env' "$COMPOSE_DIR"; then
  fail "Chemin env_file invalide encore présent"
fi

log "Tous les env_file sont conformes"

# 7) Relance stack propre
echo
log "Arrêt stack"
docker compose -f "$COMPOSE_DIR/docker-compose.app.yml" down -v

log "Suppression réseau src_default (si présent)"
docker network rm src_default 2>/dev/null || true

log "Démarrage stack"
docker compose -f "$COMPOSE_DIR/docker-compose.app.yml" up -d

echo "============================================================"
echo "[OK] ENV_FILE PATH CANONIQUE — STACK SAINE"
echo "============================================================"
