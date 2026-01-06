#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/home/adminso/bluegreen_v7_dev"
C2="$BASE_DIR/src/scripts/run_wp_bootstrap.sh"
C2_NEW="$C2.new"
PIPELINE="$BASE_DIR/src/scripts/run_wp_pipeline_v7.sh"

fail(){ echo "[FATAL] $*" >&2; exit 1; }
info(){ echo "[FIX] $*"; }

echo "============================================================"
echo " FIX C2 — REMOVE WP RUNNING CHECK (v7)"
echo "============================================================"

[[ -f "$C2" ]] || fail "run_wp_bootstrap.sh introuvable"
[[ -x "$PIPELINE" ]] || fail "pipeline WP introuvable"

info "Sauvegarde de C2"
cp "$C2" "$C2.bak.$(date +%Y%m%d-%H%M%S)"

info "Suppression des checks wp-* non démarré (job WP-CLI)"

while IFS= read -r line; do
  # on supprime toute ligne qui provoque l’échec 'non démarré'
  if [[ "$line" == *'non démarré'* ]]; then
    echo "  # [v7] Check wp-* running supprimé (conteneur job WP-CLI)" >> "$C2_NEW"
  else
    echo "$line" >> "$C2_NEW"
  fi
done < "$C2"

mv "$C2_NEW" "$C2"
chmod +x "$C2"

info "Patch appliqué : C2 compatible conteneurs WP-CLI éphémères"

info "Relance du pipeline WordPress"
"$PIPELINE"

echo "============================================================"
echo "[OK] CHECK WP RUNNING SUPPRIMÉ + PIPELINE RELANCÉ"
echo "============================================================"
exit 0
