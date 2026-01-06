#!/usr/bin/env bash
set -euo pipefail

############################################################
# APPLY WP FULL PROFILE — BLUEGREEN v7
# Décision métier explicite + exécution contrôlée
############################################################

BASE_DIR="/home/adminso/bluegreen_v7_dev"
CONF="$BASE_DIR/src/global.conf"
PIPELINE="$BASE_DIR/src/scripts/run_wp_pipeline_v7.sh"

# === PARAMÈTRES OPÉRATEUR ===
PRIMARY_DOMAIN="www.monsite-test.fr"
PREVIEW_DOMAIN="preprod.monsite-test.fr"

fail() { echo "[FATAL] $*" >&2; exit 1; }
info() { echo "[APPLY] $*"; }

echo "============================================================"
echo " APPLY WORDPRESS FULL PROFILE v7"
echo "============================================================"

[[ -f "$CONF" ]] || fail "global.conf introuvable : $CONF"
[[ -x "$PIPELINE" ]] || fail "pipeline WP introuvable ou non exécutable"

info "Sauvegarde de global.conf"
cp "$CONF" "$CONF.bak.$(date +%Y%m%d-%H%M%S)"

info "Activation du profil FULL + WordPress"

# --- Flags principaux ---
sed -i \
  -e 's/^PROJECT_INSTALL_PROFILE=.*/PROJECT_INSTALL_PROFILE=full/' \
  -e 's/^ENABLE_WORDPRESS=.*/ENABLE_WORDPRESS=true/' \
  -e 's/^WP_AUTO_INSTALL=.*/WP_AUTO_INSTALL=true/' \
  "$CONF"

# --- PRIMARY_DOMAIN ---
if grep -q '^PRIMARY_DOMAIN=' "$CONF"; then
  sed -i "s|^PRIMARY_DOMAIN=.*|PRIMARY_DOMAIN=${PRIMARY_DOMAIN}|" "$CONF"
else
  echo "PRIMARY_DOMAIN=${PRIMARY_DOMAIN}" >> "$CONF"
fi

# --- PREVIEW_DOMAIN ---
if grep -q '^PREVIEW_DOMAIN=' "$CONF"; then
  sed -i "s|^PREVIEW_DOMAIN=.*|PREVIEW_DOMAIN=${PREVIEW_DOMAIN}|" "$CONF"
else
  echo "PREVIEW_DOMAIN=${PREVIEW_DOMAIN}" >> "$CONF"
fi

info "global.conf mis à jour"

echo "------------------ ÉTAT ACTIF ------------------"
grep -E 'PROJECT_INSTALL_PROFILE|ENABLE_WORDPRESS|WP_AUTO_INSTALL|PRIMARY_DOMAIN|PREVIEW_DOMAIN' "$CONF"
echo "------------------------------------------------"

info "Lancement du pipeline WordPress (C2 → C3)"
"$PIPELINE"

echo "============================================================"
echo "[OK] PROFIL FULL APPLIQUÉ + PIPELINE EXÉCUTÉ"
echo "============================================================"
exit 0
