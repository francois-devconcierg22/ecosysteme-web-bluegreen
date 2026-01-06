#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/home/adminso/bluegreen_v7_dev"
C2="$BASE_DIR/src/scripts/run_wp_bootstrap.sh"

fail(){ echo "[FATAL] $*" >&2; exit 1; }
info(){ echo "[ADD] $*"; }

echo "============================================================"
echo " ADD wpcli_run() FUNCTION — BLUEGREEN v7 (STEP A)"
echo "============================================================"

[[ -f "$C2" ]] || fail "run_wp_bootstrap.sh introuvable"

info "Sauvegarde de sécurité"
cp "$C2" "$C2.bak.add-fn.$(date +%Y%m%d-%H%M%S)"

info "Insertion de la fonction wpcli_run() après fail()"

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

info "Fonction ajoutée (aucune exécution lancée)"

echo "============================================================"
echo "[OK] ÉTAPE A TERMINÉE — BASE PRÊTE POUR MIGRATION"
echo "============================================================"
exit 0
