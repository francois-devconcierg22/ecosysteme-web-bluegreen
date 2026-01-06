#!/usr/bin/env bash
set -euo pipefail

############################################################
# C2 WRAPPER — DB READY (connexion applicative) v7
# - Attente DB robuste
# - Puis exécution de C2 inchangé
############################################################

BASE_DIR="/home/adminso/bluegreen_v7_dev"
C2="$BASE_DIR/src/scripts/run_wp_bootstrap.sh"
COMPOSE_APP="$BASE_DIR/src/docker-compose.app.yml"
RUNTIME_ENV="$BASE_DIR/tmp/runtime.env"

log(){ echo "[C2-WRAPPER] $*"; }
fail(){ echo "[FATAL] $*" >&2; exit 1; }

echo "============================================================"
echo " C2 WRAPPER — DB READY (connexion applicative)"
echo "============================================================"

[[ -f "$C2" ]] || fail "C2 introuvable : $C2"
[[ -f "$RUNTIME_ENV" ]] || fail "runtime.env introuvable"

# Charger les variables DB
set -a
source "$RUNTIME_ENV"
set +a

: "${DB_NAME:?}"
: "${DB_USER:?}"
: "${DB_PASSWORD:?}"

log "Attente DB (connexion applicative WordPress)…"

for i in $(seq 1 60); do
  if docker compose -f "$COMPOSE_APP" exec -T db \
     mysql -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" \
     -e "SELECT 1;" >/dev/null 2>&1; then
    log "DB prête (connexion applicative OK)"
    break
  fi
  sleep 2
done

docker compose -f "$COMPOSE_APP" exec -T db \
  mysql -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" \
  -e "SELECT 1;" >/dev/null 2>&1 \
  || fail "DB non prête (connexion applicative impossible)"

log "Lancement C2 (run_wp_bootstrap.sh)"
echo "------------------------------------------------------------"
time "$C2"
echo "------------------------------------------------------------"

echo "============================================================"
echo "[OK] C2 exécuté avec DB READY"
echo "============================================================"
