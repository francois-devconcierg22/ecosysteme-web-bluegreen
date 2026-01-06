#!/usr/bin/env bash
set -euo pipefail

############################################################
# PATCH C2 — DOMAIN FIX v7 (ROBUSTE)
############################################################

BASE_DIR="/home/adminso/bluegreen_v7_dev"
CONF="$BASE_DIR/src/global.conf"
C2="$BASE_DIR/src/scripts/run_wp_bootstrap.sh"
PIPELINE="$BASE_DIR/src/scripts/run_wp_pipeline_v7.sh"

fail() { echo "[FATAL] $*" >&2; exit 1; }
info() { echo "[PATCH] $*"; }

echo "============================================================"
echo " PATCH C2 DOMAIN — BLUEGREEN v7 (ROBUSTE)"
echo "============================================================"

[[ -f "$CONF" ]] || fail "global.conf introuvable"
[[ -f "$C2" ]] || fail "run_wp_bootstrap.sh introuvable"
[[ -x "$PIPELINE" ]] || fail "pipeline WP introuvable ou non exécutable"

info "Chargement global.conf"
# shellcheck disable=SC1090
source "$CONF"

info "Résolution du domaine canonique"
WP_PRIMARY_DOMAIN="${PRIMARY_DOMAIN:-${WP_DOMAIN:-${WORDPRESS_DOMAIN:-}}}"

[[ -n "$WP_PRIMARY_DOMAIN" ]] \
  || fail "PRIMARY_DOMAIN / WP_DOMAIN / WORDPRESS_DOMAIN absent dans global.conf"

info "Domaine canonique détecté : $WP_PRIMARY_DOMAIN"

info "Sauvegarde de C2"
cp "$C2" "$C2.bak.$(date +%Y%m%d-%H%M%S)"

info "Patch C2 : export du domaine canonique"

# On force la variable AVANT l’exécution de la logique C2
sed -i "1a export WP_PRIMARY_DOMAIN=\"$WP_PRIMARY_DOMAIN\"" "$C2"

chmod +x "$C2"

info "Patch appliqué avec succès"

info "Relance du pipeline WordPress (C2 → C3)"
"$PIPELINE"

echo "============================================================"
echo "[OK] PATCH C2 APPLIQUÉ + PIPELINE RELANCÉ"
echo "============================================================"
exit 0
