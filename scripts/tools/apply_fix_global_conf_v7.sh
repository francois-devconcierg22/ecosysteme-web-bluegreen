#!/usr/bin/env bash
set -euo pipefail

############################################################
# FIX GLOBAL.CONF — BLUEGREEN v7 (CANONIQUE MÉTIER)
############################################################

BASE_DIR="/home/adminso/bluegreen_v7_dev"
CONF="$BASE_DIR/src/global.conf"
PIPELINE="$BASE_DIR/src/scripts/run_wp_pipeline_v7.sh"

fail(){ echo "[FATAL] $*" >&2; exit 1; }
info(){ echo "[FIX] $*"; }

[[ -f "$CONF" ]] || fail "global.conf introuvable"
[[ -x "$PIPELINE" ]] || fail "pipeline WP introuvable"

info "Sauvegarde de global.conf"
cp "$CONF" "$CONF.bak.$(date +%Y%m%d-%H%M%S)"

info "Réécriture de global.conf (structure canonique)"

cat > "$CONF" <<'CONFEOF'
############################################
# GLOBAL CONFIGURATION — BLUEGREEN v7
############################################

# ============================================================
# PROFIL D’INSTALLATION
# ============================================================
PROJECT_INSTALL_PROFILE=full


# ============================================================
# IDENTITÉ PROJET
# ============================================================
PROJECT_NAME=conciergerie_sejour_douest
PROJECT_TYPE=conciergerie


# ============================================================
# DOMAINES
# ============================================================
PRIMARY_DOMAIN=www.conciergerieseJourdouest.fr
PREVIEW_DOMAIN=test.conciergerieseJourdouest.fr
ROOT_DOMAIN=conciergerieseJourdouest.fr

# Email administrateur WordPress (mail testable)
WP_ADMIN_EMAIL=ausolcontact@gmail.com


# ============================================================
# WORDPRESS
# ============================================================
ENABLE_WORDPRESS=true
WP_AUTO_INSTALL=true
WP_SITE_TITLE="Conciergerie Séjour d'Ouest"
WP_LOCALE=fr_FR


# ============================================================
# BLUE / GREEN
# ============================================================
BLUEGREEN_ENABLED=true
DEFAULT_ACTIVE_SLOT=blue


# ============================================================
# SÉCURITÉ / DEBUG
# ============================================================
ENABLE_TLS=false
DEBUG_INTERACTIVE=false
WP_DEBUG=false


# ============================================================
# BACKUPS
# ============================================================
ENABLE_BACKUPS=true
BACKUP_RETENTION_DAYS=30


############################################
# RÈGLES
############################################
# ❌ Aucun mot de passe ici
# ❌ Aucune valeur sensible
# ✅ Ce fichier décrit le PROJET
CONFEOF

info "global.conf corrigé (email AUSOL testable)"

info "Relance du pipeline WordPress (C2 → C3)"
"$PIPELINE"

echo "============================================================"
echo "[OK] global.conf corrigé + pipeline relancé"
echo "============================================================"
exit 0
