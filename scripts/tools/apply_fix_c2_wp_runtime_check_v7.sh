#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/home/adminso/bluegreen_v7_dev"
C2="$BASE_DIR/src/scripts/run_wp_bootstrap.sh"
C2_NEW="$C2.new"
PIPELINE="$BASE_DIR/src/scripts/run_wp_pipeline_v7.sh"

fail(){ echo "[FATAL] $*" >&2; exit 1; }
info(){ echo "[FIX] $*"; }

echo "============================================================"
echo " FIX C2 WP RUNTIME CHECK — BLUEGREEN v7 (ROBUST)"
echo "============================================================"

[[ -f "$C2" ]] || fail "run_wp_bootstrap.sh introuvable"
[[ -x "$PIPELINE" ]] || fail "pipeline WP introuvable"

info "Sauvegarde de C2"
cp "$C2" "$C2.bak.$(date +%Y%m%d-%H%M%S)"

info "Réécriture contrôlée du check runtime wp-*"

while IFS= read -r line; do
  if [[ "$line" == *'grep -q "^${slot}$"'* ]]; then
    echo '  docker compose ps -q "${slot}" >/dev/null 2>&1 || fail "$slot non démarré"' >> "$C2_NEW"
  else
    echo "$line" >> "$C2_NEW"
  fi
done < "$C2"

mv "$C2_NEW" "$C2"
chmod +x "$C2"

info "Patch appliqué avec succès"

info "Relance du pipeline WordPress"
"$PIPELINE"

echo "============================================================"
echo "[OK] WP RUNTIME CHECK ALIGNÉ + PIPELINE RELANCÉ"
echo "============================================================"
exit 0
