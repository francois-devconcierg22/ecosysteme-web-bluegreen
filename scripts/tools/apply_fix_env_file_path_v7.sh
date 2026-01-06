#!/usr/bin/env bash
set -euo pipefail

############################################################
# FIX ENV_FILE PATH — BLUEGREEN v7
# - Corrige ./tmp/runtime.env → ../tmp/runtime.env
# - Sauvegarde le compose
# - Vérifie le résultat
# - Relance la stack proprement
############################################################

BASE_DIR="/home/adminso/bluegreen_v7_dev"
COMPOSE="$BASE_DIR/src/docker-compose.app.yml"
RUNTIME_REAL="$BASE_DIR/tmp/runtime.env"

log()  { echo "[FIX] $*"; }
fail() { echo "[FATAL] $*" >&2; exit 1; }

echo "============================================================"
echo " FIX ENV_FILE PATH — BLUEGREEN v7 "
echo "============================================================"

# 1) Vérifications préalables
[[ -f "$COMPOSE" ]] || fail "docker-compose.app.yml introuvable"
[[ -f "$RUNTIME_REAL" ]] || fail "runtime.env introuvable dans $BASE_DIR/tmp"

# 2) Sauvegarde
TS="$(date +%Y%m%d-%H%M%S)"
cp "$COMPOSE" "$COMPOSE.bak.$TS"
log "Backup créé : docker-compose.app.yml.bak.$TS"

# 3) Correction du chemin env_file
log "Correction des chemins env_file (./tmp → ../tmp)"
sed -i 's|./tmp/runtime.env|../tmp/runtime.env|g' "$COMPOSE"

# 4) Vérification post-fix
echo
log "Vérification env_file dans le compose :"
grep -n "env_file" "$COMPOSE" || fail "Aucun env_file trouvé après correction"

if grep -q "./tmp/runtime.env" "$COMPOSE"; then
  fail "Ancien chemin ./tmp/runtime.env encore présent"
fi

log "Chemins env_file OK"

# 5) Relance propre de la stack
echo
log "Arrêt de la stack"
docker compose -f "$COMPOSE" down -v

log "Suppression réseau src_default (si présent)"
docker network rm src_default 2>/dev/null || true

log "Démarrage de la stack"
docker compose -f "$COMPOSE" up -d

echo "============================================================"
echo "[OK] FIX ENV_FILE PATH APPLIQUÉ — STACK RELANCÉE"
echo "============================================================"
