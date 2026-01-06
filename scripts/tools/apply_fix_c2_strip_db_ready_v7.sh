#!/usr/bin/env bash
set -euo pipefail

C2="/home/adminso/bluegreen_v7_dev/src/scripts/run_wp_bootstrap.sh"
TS="$(date +%Y%m%d-%H%M%S)"

log(){ echo "[C2-STRIP] $*"; }
fail(){ echo "[FATAL] $*" >&2; exit 1; }

[[ -f "$C2" ]] || fail "C2 introuvable: $C2"

cp "$C2" "$C2.bak.strip-dbready.$TS"
log "Backup créé: $C2.bak.strip-dbready.$TS"

log "Suppression stricte de toute logique DB-ready"

# On supprime TOUTES les lignes liées à DB ready
sed -i '
/Attente DB/d
/connexion applicative/d
/SELECT 1/d
/mysql .*SELECT/d
/DB non prête/d
' "$C2"

log "Vérification syntaxe Bash"
bash -n "$C2"

echo "============================================================"
echo "[OK] C2 PURGÉ"
echo " - Aucun wait DB"
echo " - Aucun test MySQL"
echo " - Fail-fast uniquement"
echo "============================================================"
