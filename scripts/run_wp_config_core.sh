#!/usr/bin/env bash
set -euo pipefail

echo "============================================================"
echo " C3 — RUN WP CONFIG CORE v7 — Settings + Hardening (BLUE+GREEN)"
echo "============================================================"

BASE_DIR="/home/adminso/bluegreen_v7_dev"
SRC="$BASE_DIR/src"
COMPOSE_APP="$SRC/docker-compose.app.yml"
RUNTIME_ENV="$BASE_DIR/tmp/runtime.env"
NET_NAME="${NETWORK_NAME:-bg_shared_net}"

fail(){ echo "[FATAL] $*" >&2; exit 1; }
log(){  echo "[WP-CONFIG] $*"; }

[[ -f "$COMPOSE_APP" ]] || fail "compose app manquant: $COMPOSE_APP"
[[ -f "$RUNTIME_ENV" ]] || fail "runtime.env manquant: $RUNTIME_ENV"

wpcli(){  # $1=blue|green ; $2..=args
  local SLOT="$1"; shift
  local WP_DIR="$SRC/$SLOT/wp"
  [[ -d "$WP_DIR" ]] || fail "WP_DIR introuvable: $WP_DIR"
  docker run --rm --network "$NET_NAME" \
    --env-file "$RUNTIME_ENV" \
    -v "$WP_DIR:/var/www/html" \
    -w /var/www/html \
    wordpress:cli wp --allow-root "$@"
}

for SLOT in blue green; do
  log "Cible: $SLOT"
  if ! wpcli "$SLOT" core is-installed >/dev/null 2>&1; then
    fail "$SLOT : WordPress non installé. Action: exécuter d’abord C2 (wp_bootstrap)."
  fi

  log "Permaliens : /%postname%/"
  wpcli "$SLOT" rewrite structure "/%postname%/" --hard || true
  wpcli "$SLOT" rewrite flush --hard || true

  log "Désactivation commentaires/pings par défaut"
  wpcli "$SLOT" option update default_comment_status closed || true
  wpcli "$SLOT" option update default_ping_status closed || true
  wpcli "$SLOT" option update default_pingback_flag 0 || true

  log "MU-plugins hardening (XML-RPC off + uploads no-php)"
  MU_DIR="$SRC/$SLOT/wp/wp-content/mu-plugins"
  mkdir -p "$MU_DIR"
  printf "%s\n" "<?php" "// BG Hardening — XML-RPC off" "add_filter(\"xmlrpc_enabled\", \"__return_false\");" > "$MU_DIR/bg-disable-xmlrpc.php"
  UPLOADS_HT="$SRC/$SLOT/wp/wp-content/uploads/.htaccess"
  if [[ ! -f "$UPLOADS_HT" ]]; then
    printf "%s\n" "<FilesMatch \\\"\\.(php|phtml|phar)\\$\\\">" "  Require all denied" "</FilesMatch>" > "$UPLOADS_HT"
  fi

  log "Config core OK sur $SLOT"
done

echo "============================================================"
echo "[OK] C3 CONFIG CORE — terminé (BLUE+GREEN)"
echo "============================================================"
exit 0
