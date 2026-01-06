#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/home/adminso/bluegreen_v7_dev"
C2="$BASE_DIR/src/scripts/run_wp_bootstrap.sh"
C2_NEW="$C2.new"
PIPELINE="$BASE_DIR/src/scripts/run_wp_pipeline_v7.sh"

fail(){ echo "[FATAL] $*" >&2; exit 1; }
info(){ echo "[FIX] $*"; }

echo "============================================================"
echo " FIX C2 — USE docker compose run FOR WP-CLI (v7)"
echo "============================================================"

[[ -f "$C2" ]] || fail "run_wp_bootstrap.sh introuvable"
[[ -x "$PIPELINE" ]] || fail "pipeline WP introuvable"

info "Sauvegarde de C2"
cp "$C2" "$C2.bak.$(date +%Y%m%d-%H%M%S)"

info "Remplacement docker exec → docker compose run --rm (WP-CLI)"

while IFS= read -r line; do
  if [[ "$line" == *'docker exec "$slot" wp'* ]]; then
    # On réécrit la ligne SANS évaluer $slot
    echo '  docker compose run --rm "$slot" wp '"${line#*wp }" >> "$C2_NEW"
  else
    echo "$line" >> "$C2_NEW"
  fi
done < "$C2"

mv "$C2_NEW" "$C2"
chmod +x "$C2"

info "Patch appliqué : WP-CLI via docker compose run"

info "Relance du pipeline WordPress"
"$PIPELINE"

echo "============================================================"
echo "[OK] WP-CLI EXECUTION ALIGNÉE + PIPELINE RELANCÉ"
echo "============================================================"
exit 0
