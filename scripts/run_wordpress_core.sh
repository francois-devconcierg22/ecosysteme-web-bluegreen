#!/usr/bin/env bash
set -euo pipefail

echo "============================================================"
echo " RUN WORDPRESS CORE v7 — wp-blue / wp-green"
echo "============================================================"

BASE_DIR="/home/adminso/bluegreen_v7_dev"
SRC="$BASE_DIR/src"
COMPOSE_APP="$SRC/docker-compose.app.yml"

log()  { echo "[WP-CORE] $*"; }
fail() { echo "[FATAL] $*" >&2; exit 1; }

log "Vérification docker compose…"
docker compose version >/dev/null 2>&1 || fail "docker compose indisponible"

log "Vérification des services déclarés…"
SERVICES="$(docker compose -f "$COMPOSE_APP" config --services)"
echo "$SERVICES" | grep -q "^wp-blue$"  || fail "Service wp-blue absent"
echo "$SERVICES" | grep -q "^wp-green$" || fail "Service wp-green absent"

log "Démarrage wp-blue (sans auto-install)…"
docker compose -f "$COMPOSE_APP" up -d wp-blue

log "Démarrage wp-green (sans auto-install)…"
docker compose -f "$COMPOSE_APP" up -d wp-green

log "Vérification des containers WordPress…"
docker ps --format "{{.Names}}" | grep -q "^wp-blue$"  || fail "wp-blue non démarré"
docker ps --format "{{.Names}}" | grep -q "^wp-green$" || fail "wp-green non démarré"

log "WordPress CORE opérationnel (containers uniquement)"
echo "============================================================"
echo "[OK] WORDPRESS CORE v7 — OK"
echo "============================================================"
exit 0
