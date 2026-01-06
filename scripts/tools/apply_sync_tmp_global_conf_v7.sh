#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/home/adminso/bluegreen_v7_dev"
SRC_CONF="$BASE_DIR/src/global.conf"
TMP_DIR="$BASE_DIR/tmp"
TMP_CONF="$TMP_DIR/global.conf"
PIPELINE="$BASE_DIR/src/scripts/run_wp_pipeline_v7.sh"

fail(){ echo "[FATAL] $*" >&2; exit 1; }
info(){ echo "[SYNC] $*"; }

echo "============================================================"
echo " SYNC TMP GLOBAL.CONF — BLUEGREEN v7"
echo "============================================================"

[[ -f "$SRC_CONF" ]] || fail "src/global.conf introuvable: $SRC_CONF"
[[ -x "$PIPELINE" ]] || fail "pipeline introuvable ou non exécutable: $PIPELINE"

mkdir -p "$TMP_DIR"

if [[ -f "$TMP_CONF" ]]; then
  info "Backup de tmp/global.conf"
  cp "$TMP_CONF" "$TMP_CONF.bak.$(date +%Y%m%d-%H%M%S)"
fi

info "Copie src/global.conf → tmp/global.conf"
cp "$SRC_CONF" "$TMP_CONF"

info "Contrôle: PRIMARY_DOMAIN doit exister dans tmp/global.conf"
grep -nE '^PRIMARY_DOMAIN=' "$TMP_CONF" >/dev/null \
  || fail "PRIMARY_DOMAIN absent de $TMP_CONF (sync OK mais contenu invalide)"

info "Contrôle: ENABLE_WORDPRESS"
grep -nE '^ENABLE_WORDPRESS=' "$TMP_CONF" >/dev/null \
  || fail "ENABLE_WORDPRESS absent de $TMP_CONF"

info "OK — tmp/global.conf synchronisé"

info "Relance du pipeline (C2 → C3)"
"$PIPELINE"

echo "============================================================"
echo "[OK] SYNC OK + PIPELINE RELANCÉ"
echo "============================================================"
exit 0
