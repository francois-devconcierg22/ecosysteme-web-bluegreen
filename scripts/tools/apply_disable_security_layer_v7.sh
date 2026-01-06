#!/usr/bin/env bash
set -euo pipefail

BASE="/home/adminso/bluegreen_v7_dev"
SRC="$BASE/src"
TS="$(date +%Y%m%d-%H%M%S)"

log(){ echo "[SEC-ROLLBACK] $*"; }
fail(){ echo "[FATAL] $*" >&2; exit 1; }

echo "============================================================"
echo " DISABLE SECURITY LAYER — BLUEGREEN v7"
echo "============================================================"

# 1) Sauvegardes
log "Sauvegarde des fichiers de configuration"
for f in \
  docker-compose.app.yml \
  docker-compose.traefik.yml \
  docker-compose.wpcli.override.yml
do
  [[ -f "$SRC/$f" ]] && cp "$SRC/$f" "$SRC/$f.bak.security.$TS"
done

# 2) Désactivation Traefik côté app (labels)
log "Suppression des labels Traefik côté WordPress"
sed -i \
  -e '/traefik\./d' \
  "$SRC/docker-compose.app.yml"

# 3) Réseau Docker simple (désactivation external/internal)
log "Neutralisation des options de sécurité réseau"
sed -i \
  -e '/external:[[:space:]]*true/d' \
  -e '/internal:[[:space:]]*true/d' \
  "$SRC/docker-compose.app.yml"

# 4) Désactivation sécurité Traefik (si présente)
if [[ -f "$SRC/docker-compose.traefik.yml" ]]; then
  log "Désactivation des middlewares de sécurité Traefik"
  sed -i \
    -e '/basicAuth/d' \
    -e '/middlewares:/,/^[^ ]/d' \
    "$SRC/docker-compose.traefik.yml" || true
fi

# 5) Stop stack
log "Arrêt complet de la stack applicative"
docker compose -f "$SRC/docker-compose.app.yml" down -v || true

# 6) Recréation réseau simple
log "Recréation du réseau Docker (mode ouvert)"
docker network rm bg_shared_net 2>/dev/null || true
docker network create bg_shared_net

# 7) Relance stack sans sécurité
log "Relance de la stack applicative (mode non sécurisé)"
docker compose -f "$SRC/docker-compose.app.yml" up -d

echo "============================================================"
echo "[OK] COUCHE DE SÉCURITÉ DÉSACTIVÉE — MODE LEGACY ACTIF"
echo "============================================================"
