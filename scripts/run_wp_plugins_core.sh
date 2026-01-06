#!/usr/bin/env bash
set -euo pipefail

echo "============================================================"
echo " RUN WP PLUGINS CORE v7 — BLUE + GREEN"
echo "============================================================"

BASE_DIR="/home/adminso/bluegreen_v7_dev"
SRC="$BASE_DIR/src"
COMPOSE_APP="$SRC/docker-compose.app.yml"

fail() { echo "[FATAL] $*" >&2; exit 1; }
log()  { echo "[WP-PLUGINS] $*"; }

log "Vérification docker compose…"
docker compose version >/dev/null 2>&1 || fail "docker compose indisponible"

log "Vérification services WordPress…"
SERVICES="$(docker compose -f "$COMPOSE_APP" config --services)"
echo "$SERVICES" | grep -q "^wp-blue$"  || fail "wp-blue absent"
echo "$SERVICES" | grep -q "^wp-green$" || fail "wp-green absent"

log "Démarrage wp-blue / wp-green…"
docker compose -f "$COMPOSE_APP" up -d wp-blue wp-green

PLUGINS=( "advanced-custom-fields" "fluentform" "wp-mail-smtp" "limit-login-attempts-reloaded" )

for SLOT in wp-blue wp-green; do
  log "Cible : $SLOT"

  # WP doit être installé avant d installer les plugins
  if ! docker exec "$SLOT" wp core is-installed >/dev/null 2>&1; then
    fail "$SLOT : WordPress n est pas installé (exécute wp_bootstrap avant)"
  fi

  for P in "${PLUGINS[@]}"; do
    log "$SLOT : install+activate $P"
    if docker exec "$SLOT" wp plugin is-installed "$P" >/dev/null 2>&1; then
      docker exec "$SLOT" wp plugin activate "$P" >/dev/null 2>&1 || fail "$SLOT : activation échouée $P"
      log "$SLOT : $P déjà installé — activation OK"
    else
      docker exec "$SLOT" wp plugin install "$P" --activate >/dev/null 2>&1 || fail "$SLOT : install échouée $P"
      log "$SLOT : $P installé+activé"
    fi
  done

  log "$SLOT : vérification statut plugins"
  docker exec "$SLOT" wp plugin status "${PLUGINS[@]}" >/dev/null 2>&1 || fail "$SLOT : status plugins KO"
done

echo "============================================================"
echo "[OK] WP PLUGINS CORE v7 TERMINÉ"
echo "============================================================"
exit 0
