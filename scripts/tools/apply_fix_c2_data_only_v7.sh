#!/usr/bin/env bash
set -euo pipefail

############################################################
# FIX C2 DATA-ONLY IMPORT — BLUEGREEN v7
############################################################

BASE_DIR="/home/adminso/bluegreen_v7_dev"
C2="$BASE_DIR/src/scripts/run_wp_bootstrap.sh"
PIPELINE="$BASE_DIR/src/scripts/run_wp_pipeline_v7.sh"

fail(){ echo "[FATAL] $*" >&2; exit 1; }
info(){ echo "[FIX] $*"; }

[[ -f "$C2" ]] || fail "run_wp_bootstrap.sh introuvable"
[[ -x "$PIPELINE" ]] || fail "pipeline WP introuvable"

info "Sauvegarde de C2"
cp "$C2" "$C2.bak.$(date +%Y%m%d-%H%M%S)"

info "Ajout des variables DOMAIN à l’import data-only"

# On ajoute les DOMAIN juste après ENABLE_WORDPRESS si trouvé
sed -i '
/ENABLE_WORDPRESS/ a\
PRIMARY_DOMAIN\
PREVIEW_DOMAIN\
ROOT_DOMAIN
' "$C2"

chmod +x "$C2"

info "Correctif data-only appliqué à C2"

info "Relance du pipeline WordPress"
"$PIPELINE"

echo "============================================================"
echo "[OK] C2 DATA-ONLY ALIGNÉ + PIPELINE RELANCÉ"
echo "============================================================"
exit 0
