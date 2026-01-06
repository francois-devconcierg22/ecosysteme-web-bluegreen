#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/home/adminso/bluegreen_v7_dev"
C2="$BASE_DIR/src/scripts/run_wp_bootstrap.sh"
C2_NEW="$C2.new"
PIPELINE="$BASE_DIR/src/scripts/run_wp_pipeline_v7.sh"

fail(){ echo "[FATAL] $*" >&2; exit 1; }
info(){ echo "[FIX] $*"; }

echo "============================================================"
echo " FIX C2 WP CONTAINER CHECK — BLUEGREEN v7"
echo "============================================================"

[[ -f "$C2" ]] || fail "run_wp_bootstrap.sh introuvable"
[[ -x "$PIPELINE" ]] || fail "pipeline WP introuvable"

info "Sauvegarde de C2"
cp "$C2" "$C2.bak.$(date +%Y%m%d-%H%M%S)"

info "Patch du check runtime wp-* (docker inspect + wait loop)"

patched=0
while IFS= read -r line; do
  if [[ "$line" == *'fail "$slot non démarré"'* ]]; then
    cat >> "$C2_NEW" <<'BLOCK'
  # Attente conteneur (runtime) : on check le conteneur, pas le service compose
  if ! docker inspect "$slot" >/dev/null 2>&1; then
    fail "$slot introuvable (docker inspect KO)"
  fi
  for i in $(seq 1 30); do
    status="$(docker inspect -f '{{.State.Status}}' "$slot" 2>/dev/null || true)"
    [[ "$status" == "running" ]] && break
    sleep 1
  done
  status="$(docker inspect -f '{{.State.Status}}' "$slot" 2>/dev/null || true)"
  [[ "$status" == "running" ]] || fail "$slot non démarré (status=$status)"
BLOCK
    patched=1
  else
    echo "$line" >> "$C2_NEW"
  fi
done < "$C2"

[[ "$patched" -eq 1 ]] || fail "Patch non appliqué: pattern 'non démarré' introuvable dans C2"

mv "$C2_NEW" "$C2"
chmod +x "$C2"

info "Patch appliqué avec succès"

info "Relance du pipeline WordPress"
"$PIPELINE"

echo "============================================================"
echo "[OK] WP CONTAINER CHECK ALIGNÉ + PIPELINE RELANCÉ"
echo "============================================================"
exit 0
