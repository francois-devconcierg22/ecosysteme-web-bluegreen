#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/home/adminso/bluegreen_v7_dev"
C2="$BASE_DIR/src/scripts/run_wp_bootstrap.sh"

fail(){ echo "[FATAL] $*" >&2; exit 1; }
info(){ echo "[MIGRATE] $*"; }

echo "============================================================"
echo " MIGRATE WP-CLI CALLS → wpcli_run() — BLUEGREEN v7 (STEP B)"
echo "============================================================"

[[ -f "$C2" ]] || fail "run_wp_bootstrap.sh introuvable"

info "Sauvegarde de sécurité"
cp "$C2" "$C2.bak.migrate.$(date +%Y%m%d-%H%M%S)"

info "Migration des appels WP-CLI (docker exec → wpcli_run)"

# Règles de migration explicites et sûres
sed -i \
  -e 's|docker exec "$slot" wp core is-installed|wpcli_run "$slot" core is-installed|g' \
  -e 's|docker exec "$slot" wp config create|wpcli_run "$slot" config create|g' \
  -e 's|docker exec "$slot" wp core install|wpcli_run "$slot" core install|g' \
  -e 's|docker exec "$slot" wp rewrite structure|wpcli_run "$slot" rewrite structure|g' \
  -e 's|docker exec "$slot" wp rewrite flush|wpcli_run "$slot" rewrite flush|g' \
  "$C2"

chmod +x "$C2"

info "Migration terminée (structure intacte)"

echo "============================================================"
echo "[OK] ÉTAPE B TERMINÉE — APPELS WP-CLI CANONIQUES"
echo "============================================================"
exit 0
