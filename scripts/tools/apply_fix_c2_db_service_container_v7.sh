#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/home/adminso/bluegreen_v7_dev"
C2="$BASE_DIR/src/scripts/run_wp_bootstrap.sh"
PIPELINE="$BASE_DIR/src/scripts/run_wp_pipeline_v7.sh"

fail(){ echo "[FATAL] $*" >&2; exit 1; }
info(){ echo "[FIX] $*"; }

echo "============================================================"
echo " FIX C2 DB SERVICE / CONTAINER — BLUEGREEN v7"
echo "============================================================"

[[ -f "$C2" ]] || fail "run_wp_bootstrap.sh introuvable"
[[ -x "$PIPELINE" ]] || fail "pipeline WP introuvable"

info "Sauvegarde de C2"
cp "$C2" "$C2.bak.$(date +%Y%m%d-%H%M%S)"

info "Correction DB_SERVICE et DB_CONTAINER"

# 1) Forcer DB_SERVICE=db
sed -i 's/^DB_SERVICE=".*"/DB_SERVICE="db"/' "$C2"

# 2) Ajouter DB_CONTAINER juste après DB_SERVICE
grep -q '^DB_CONTAINER=' "$C2" || \
sed -i '/^DB_SERVICE=/a DB_CONTAINER="bg-db"' "$C2"

# 3) Corriger la vérification runtime (container)
sed -i 's/grep -q "^${DB_SERVICE}$"/grep -q "^${DB_CONTAINER}$"/g' "$C2"

chmod +x "$C2"

info "Correctif DB service/container appliqué"

info "Relance du pipeline WordPress"
"$PIPELINE"

echo "============================================================"
echo "[OK] DB SERVICE / CONTAINER ALIGNÉS + PIPELINE RELANCÉ"
echo "============================================================"
exit 0
