#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/home/adminso/bluegreen_v7_dev"
C2="$BASE_DIR/src/scripts/run_wp_bootstrap.sh"
PIPELINE="$BASE_DIR/src/scripts/run_wp_pipeline_v7.sh"

fail(){ echo "[FATAL] $*" >&2; exit 1; }
info(){ echo "[FIX] $*"; }

echo "============================================================"
echo " FIX C2 WP SERVICE CHECK — BLUEGREEN v7"
echo "============================================================"

[[ -f "$C2" ]] || fail "run_wp_bootstrap.sh introuvable"
[[ -x "$PIPELINE" ]] || fail "pipeline WP introuvable"

info "Sauvegarde de C2"
cp "$C2" "$C2.bak.$(date +%Y%m%d-%H%M%S)"

info "Correction du check runtime wp-blue / wp-green"

# Remplacer le test docker ps par docker compose ps
sed -i \
  's/docker ps --format .{{.Names}}. | grep -q "\\^${slot}\\$"/docker compose ps -q "${slot}" >\/dev\/null 2>\&1/' \
  "$C2"

chmod +x "$C2"

info "Correctif WP service check appliqué"

info "Relance du pipeline WordPress"
"$PIPELINE"

echo "============================================================"
echo "[OK] WP SERVICE CHECK ALIGNÉ + PIPELINE RELANCÉ"
echo "============================================================"
exit 0
