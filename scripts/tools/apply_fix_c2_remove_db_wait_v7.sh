#!/usr/bin/env bash
set -euo pipefail

C2="/home/adminso/bluegreen_v7_dev/src/scripts/run_wp_bootstrap.sh"
TS="$(date +%Y%m%d-%H%M%S)"

log(){ echo "[C2-FIX] $*"; }
fail(){ echo "[FATAL] $*" >&2; exit 1; }

[[ -f "$C2" ]] || fail "C2 introuvable: $C2"

cp "$C2" "$C2.bak.remove-dbwait.$TS"
log "Backup créé: $C2.bak.remove-dbwait.$TS"

log "Suppression de tout bloc 'Attente DB' dans C2"

# On commente proprement les blocs DB-ready
sed -i '
/Attente DB/,+15 {
  s/^/# [DISABLED-DB-READY] /
}
' "$C2"

log "Vérification syntaxe bash"
bash -n "$C2"

echo "============================================================"
echo "[OK] C2 nettoyé — aucune attente DB interne"
echo "     La DB doit être prête AVANT C2 (contrat respecté)"
echo "============================================================"
