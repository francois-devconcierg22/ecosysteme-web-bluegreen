#!/usr/bin/env bash
set -euo pipefail

COMPOSE="/home/adminso/bluegreen_v7_dev/src/docker-compose.app.yml"
TS="$(date +%Y%m%d-%H%M%S)"

log(){ echo "[ENV-SINGLE] $*"; }
fail(){ echo "[FATAL] $*" >&2; exit 1; }

cp "$COMPOSE" "$COMPOSE.bak.single-env.$TS"
log "Backup créé : $COMPOSE.bak.single-env.$TS"

log "Nettoyage des blocs environment DB (WordPress uniquement)"

awk '
/wp-blue:/ { in_wp=1 }
 /wp-green:/ { in_wp=1 }
 in_wp && /^[[:space:]]*environment:/ { skip=1; next }
 skip && /^[[:space:]]*[a-zA-Z]/ { skip=0 }
 !skip { print }
' "$COMPOSE" > "$COMPOSE.tmp"

mv "$COMPOSE.tmp" "$COMPOSE"

log "Validation docker compose"
docker compose -f "$COMPOSE" config >/dev/null

echo "============================================================"
echo "[OK] Source unique d’environnement rétablie"
echo " - runtime.env = vérité absolue"
echo " - Aucun override WORDPRESS_DB_*"
echo "============================================================"
