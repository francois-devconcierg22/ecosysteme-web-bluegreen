#!/usr/bin/env bash
set -euo pipefail

echo "============================================================"
echo " RUN INFRA v7 — Docker / Traefik / DB"
echo "============================================================"

BASE_DIR="/home/adminso/bluegreen_v7_dev"
SRC="$BASE_DIR/src"
COMPOSE_APP="$SRC/docker-compose.app.yml"
COMPOSE_TRAEFIK="$SRC/docker-compose.traefik.yml"
NETWORK_NAME="bg_shared_net"

log() { echo "[INFRA] $*"; }
fail() { echo "[FATAL] $*" >&2; exit 1; }

log "Vérification Docker…"
command -v docker >/dev/null 2>&1 || fail "Docker non installé"
docker info >/dev/null 2>&1 || fail "Docker non fonctionnel"

log "Vérification docker-compose…"
docker compose version >/dev/null 2>&1 || fail "docker compose indisponible"

log "Vérification des fichiers compose…"
[[ -f "$COMPOSE_APP" ]] || fail "Manquant: $COMPOSE_APP"
[[ -f "$COMPOSE_TRAEFIK" ]] || fail "Manquant: $COMPOSE_TRAEFIK"



log "Détection du service DB (auto)..."
DB_SERVICE="$(docker compose -f "$COMPOSE_APP" config --services | grep -E "^(db|mysql|mariadb)$" | head -n1)"

[[ -n "$DB_SERVICE" ]] || fail "Aucun service DB détecté dans $COMPOSE_APP"
log "Service DB détecté : $DB_SERVICE"

log "Lancement DB (compose app)…"
docker compose -f "$COMPOSE_APP" up -d -d "$DB_SERVICE"

log "Attente DB (présence container)…"

log "Lancement Traefik…"
docker compose -f "$COMPOSE_TRAEFIK" up -d -d traefik

log "État des containers INFRA:"
docker ps --format "table {{.Names}}\t{{.Status}}"

log "INFRA v7 — OK"
exit 0
