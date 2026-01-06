#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# CANONICAL C2 — RUN WP BOOTSTRAP v7.1
# DO NOT PATCH — REGENERATE ONLY
# Responsibility: WordPress core bootstrap ONLY
# Preconditions:
#  - DB is READY
#  - runtime.env is valid
# ============================================================

echo "============================================================"
echo " C2 — RUN WP BOOTSTRAP v7.1 (CANONICAL) — BLUE + GREEN"
echo "============================================================"

BASE_DIR="/home/adminso/bluegreen_v7_dev"
SRC="$BASE_DIR/src"

GLOBAL_CONF="$BASE_DIR/tmp/global.conf"
DB_SECRETS="$BASE_DIR/tmp/db_secrets.env"
WP_SECRETS="$BASE_DIR/tmp/wp_admin_secrets.env"
RUNTIME_ENV="$BASE_DIR/tmp/runtime.env"

COMPOSE_APP="$SRC/docker-compose.app.yml"
COMPOSE_WPCLI="$SRC/docker-compose.wpcli.override.yml"

DB_SERVICE="db"
WP_PATH="/var/www/html"

log()  { echo "[WP-BOOT] $*"; }
fail() { echo "[FATAL] $*" >&2; exit 1; }

# ------------------------------------------------------------
# WP-CLI runner (single canonical entry point)
# ------------------------------------------------------------
wpcli_run() {
  local slot="$1"; shift
  local WP_DIR="$SRC/$slot/wp"
  docker compose \
    -f "$COMPOSE_APP" \
    -f "$COMPOSE_WPCLI" \
    run --rm \
    -v "$WP_DIR:/var/www/html" \
    --env DB_NAME="$DB_NAME" \
    --env DB_USER="$DB_USER" \
    --env DB_PASSWORD="$DB_PASSWORD" \
    --env WORDPRESS_DB_HOST="$DB_SERVICE" \
    wpcli wp "$@"
}

# ------------------------------------------------------------
# Data-only source (safe env loading)
# ------------------------------------------------------------
data_only_source() {
  local f="$1"
  [[ -f "$f" ]] || return 0
  set -a
  source <(grep -E '^[A-Z0-9_]+=.*' "$f" || true)
  set +a
}

# ------------------------------------------------------------
# Load configuration
# ------------------------------------------------------------
log "Chargement des variables (canonique)…"
data_only_source "$GLOBAL_CONF"
data_only_source "$DB_SECRETS"
data_only_source "$RUNTIME_ENV"

: "${DB_NAME:?}"
: "${DB_USER:?}"
: "${DB_PASSWORD:?}"
: "${PRIMARY_DOMAIN:?}"

# ------------------------------------------------------------
# WordPress parameters
# ------------------------------------------------------------
WP_ADMIN_USER="${WP_ADMIN_USER:-admin}"
WP_ADMIN_EMAIL="${WP_ADMIN_EMAIL:-ausolcontact@gmail.com}"

WP_BLUE_DOMAIN="$PRIMARY_DOMAIN"
WP_GREEN_DOMAIN="green.$PRIMARY_DOMAIN"

# ------------------------------------------------------------
# Admin secret (runtime only)
# ------------------------------------------------------------
if [[ ! -f "$WP_SECRETS" ]]; then
  log "Génération du secret admin WordPress (runtime)…"
  WP_ADMIN_PASSWORD="$(openssl rand -base64 16)"
  umask 077
  echo "WP_ADMIN_PASSWORD=$WP_ADMIN_PASSWORD" > "$WP_SECRETS"
else
  data_only_source "$WP_SECRETS"
fi

: "${WP_ADMIN_PASSWORD:?}"

# ------------------------------------------------------------
# Start required services (NO WAIT, NO CHECK)
# ------------------------------------------------------------
log "Démarrage des services WordPress (Blue + Green)…"
docker compose -f "$COMPOSE_APP" up -d wp-blue wp-green

# ------------------------------------------------------------
# Bootstrap function (idempotent)
# ------------------------------------------------------------
bootstrap_one() {
  local slot="$1"
  local url="$2"

  log "----- SLOT: $slot / URL: $url -----"

  if wpcli_run "$slot" core is-installed --path="$WP_PATH" >/dev/null 2>&1; then
    log "$slot : déjà installé — SKIP"
    return 0
  fi

  log "$slot : génération wp-config.php…"
  wpcli_run "$slot" config create \
    --path="$WP_PATH" \
    --dbname="$DB_NAME" \
    --dbuser="$DB_USER" \
    --dbpass="$DB_PASSWORD" \
    --dbhost="$DB_SERVICE" \
    --force

  log "$slot : installation WordPress…"
  wpcli_run "$slot" core install \
    --path="$WP_PATH" \
    --url="https://$url" \
    --title="Conciergerie Séjour d'Ouest" \
    --admin_user="$WP_ADMIN_USER" \
    --admin_password="$WP_ADMIN_PASSWORD" \
    --admin_email="$WP_ADMIN_EMAIL" \
    --skip-email
}

# ------------------------------------------------------------
# Execution
# ------------------------------------------------------------
bootstrap_one "wp-blue"  "$WP_BLUE_DOMAIN"
bootstrap_one "wp-green" "$WP_GREEN_DOMAIN"

echo "============================================================"
echo "[OK] C2 TERMINÉ — WordPress installé (Blue + Green)"
echo "============================================================"
