#!/usr/bin/env bash
set -euo pipefail

############################################################
# WORDPRESS PIPELINE — BLUEGREEN v7
# Rôle : exécuter C2 → C3 selon l’intention projet
############################################################

BASE_DIR="/home/adminso/bluegreen_v7_dev"
SRC="$BASE_DIR/src"
CONF="$SRC/global.conf"
SCRIPTS="$SRC/scripts"

C2="$SCRIPTS/run_wp_bootstrap.sh"
C3_THEME="$SCRIPTS/run_wp_theme_core.sh"
C3_CONFIG="$SCRIPTS/run_wp_config_core.sh"

fail() { echo "[FATAL] $*" >&2; exit 1; }
info() { echo "[INFO]  $*"; }

echo "============================================================"
echo " WORDPRESS PIPELINE v7 — OPÉRATEUR"
echo "============================================================"

[[ -f "$CONF" ]] || fail "global.conf introuvable : $CONF"

info "Chargement global.conf (source canonique)"
# shellcheck disable=SC1090
source "$CONF"

echo "------------------ INTENTION PROJET ------------------"
echo "Profil d’installation : ${PROJECT_INSTALL_PROFILE:-<unset>}"
echo "WordPress activé       : ${ENABLE_WORDPRESS:-false}"
echo "Auto-install WP        : ${WP_AUTO_INSTALL:-false}"
echo "Domaine principal      : ${PRIMARY_DOMAIN:-<unset>}"
echo "------------------------------------------------------"

if [[ "${ENABLE_WORDPRESS:-false}" != "true" ]]; then
  info "WordPress désactivé → aucune exécution C2/C3"
  echo "[OK] PIPELINE TERMINÉ — INFRA SEULE"
  exit 0
fi

[[ -n "${PRIMARY_DOMAIN:-}" ]] \
  || fail "PRIMARY_DOMAIN requis lorsque ENABLE_WORDPRESS=true"

[[ -x "$C2" ]] || fail "C2 manquant ou non exécutable"
[[ -x "$C3_THEME" ]] || fail "C3 theme manquant ou non exécutable"
[[ -x "$C3_CONFIG" ]] || fail "C3 config manquant ou non exécutable"

info "C2 — Bootstrap WordPress"
"$C2"

info "C3 — Theme core"
"$C3_THEME"

info "C3 — Config core"
"$C3_CONFIG"

echo "============================================================"
echo "[OK] WORDPRESS PRÊT — C2 + C3 PASS (BLUE + GREEN)"
echo "============================================================"
exit 0
