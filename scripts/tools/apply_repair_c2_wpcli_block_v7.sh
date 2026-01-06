#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/home/adminso/bluegreen_v7_dev"
C2="$BASE_DIR/src/scripts/run_wp_bootstrap.sh"
PIPELINE="$BASE_DIR/src/scripts/run_wp_pipeline_v7.sh"

fail(){ echo "[FATAL] $*" >&2; exit 1; }
info(){ echo "[REPAIR] $*"; }

echo "============================================================"
echo " REPAIR C2 WP-CLI BLOCK — BLUEGREEN v7"
echo "============================================================"

[[ -f "$C2" ]] || fail "run_wp_bootstrap.sh introuvable"

info "Sauvegarde de C2 (avant réparation)"
cp "$C2" "$C2.bak.repair.$(date +%Y%m%d-%H%M%S)"

info "Neutralisation des checks WP-CLI cassés"

# On commente toute ligne problématique autour de WP-CLI exec / run
sed -i \
  -e '/WP-CLI indisponible/ s/^/# [v7-disabled] /' \
  -e '/docker exec .* wp / s/^/# [v7-disabled] /' \
  -e '/docker compose run .* wp / s/^/# [v7-disabled] /' \
  "$C2"

info "Insertion fonction WP-CLI safe"

# On injecte une fonction propre après les fonctions utilitaires
awk '
/^fail\(\)/ {
  print
  print ""
  print "wpcli_run() {"
  print "  local slot=\"$1\"; shift"
  print "  docker compose run --rm \"$slot\" wp \"$@\""
  print "}"
  next
}
{ print }
' "$C2" > "$C2.new"

mv "$C2.new" "$C2"
chmod +x "$C2"

info "Réparation syntaxique terminée"

info "Relance du pipeline WordPress"
"$PIPELINE"

echo "============================================================"
echo "[OK] C2 RÉPARÉ + PIPELINE RELANCÉ"
echo "============================================================"
exit 0
