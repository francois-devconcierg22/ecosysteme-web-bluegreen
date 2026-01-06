#!/usr/bin/env bash
set -euo pipefail

echo "============================================================"
echo " C3 — RUN WP THEME CORE v7 — GeneratePress + Child (BLUE+GREEN)"
echo "============================================================"

BASE_DIR="/home/adminso/bluegreen_v7_dev"
SRC="$BASE_DIR/src"
COMPOSE_APP="$SRC/docker-compose.app.yml"
RUNTIME_ENV="$BASE_DIR/tmp/runtime.env"
NET_NAME="${NETWORK_NAME:-bg_shared_net}"

fail(){ echo "[FATAL] $*" >&2; exit 1; }
log(){  echo "[WP-THEME] $*"; }

[[ -f "$COMPOSE_APP" ]] || fail "compose app manquant: $COMPOSE_APP"
[[ -f "$RUNTIME_ENV" ]] || fail "runtime.env manquant: $RUNTIME_ENV (ex: inject_db_env_runtime + build runtime.env)"

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
    fail "$SLOT : WordPress non installé. Action: exécuter d’abord C2 (wp_bootstrap) avec WP-CLI opérationnel."
  fi

  log "Installation du thème parent GeneratePress (si absent)"
  wpcli "$SLOT" theme install generatepress --quiet || true

  log "Création/MAJ du thème enfant bg-gp-child (idempotent)"
  CHILD_DIR="$SRC/$SLOT/wp/wp-content/themes/bg-gp-child"
  mkdir -p "$CHILD_DIR"
  printf "%s\n" "/*" "Theme Name: BG GP Child" "Template: generatepress" "Version: 1.0.0" "*/" > "$CHILD_DIR/style.css"
  printf "%s\n" "<?php" "// BG GP Child — functions.php" "add_action(\"wp_enqueue_scripts\", function(){" "  wp_enqueue_style(\"generatepress-parent\", get_template_directory_uri().\"/style.css\");" "});" > "$CHILD_DIR/functions.php"

  log "Activation du thème enfant"
  wpcli "$SLOT" theme activate bg-gp-child
done

echo "============================================================"
echo "[OK] C3 THEME CORE — terminé (BLUE+GREEN)"
echo "============================================================"
exit 0
