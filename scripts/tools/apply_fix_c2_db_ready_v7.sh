#!/usr/bin/env bash
set -euo pipefail

############################################################
# FIX C2 — DB READY VIA CONNEXION APPLICATIVE (v7)
# Patch sûr (sans sed multiline fragile)
############################################################

BASE_DIR="/home/adminso/bluegreen_v7_dev"
C2="$BASE_DIR/src/scripts/run_wp_bootstrap.sh"

log(){ echo "[FIX] $*"; }
fail(){ echo "[FATAL] $*" >&2; exit 1; }

echo "============================================================"
echo " FIX C2 — DB READY (connexion applicative) v7"
echo "============================================================"

[[ -f "$C2" ]] || fail "C2 introuvable : $C2"

log "1) Sauvegarde de sécurité"
cp "$C2" "$C2.bak.db-ready.$(date +%Y%m%d-%H%M%S)"

log "2) Suppression de tout ancien bloc d'attente DB"
awk '
/Attente DB/ {skip=1}
skip && NF==0 {skip=0; next}
!skip {print}
' "$C2" > "$C2.clean"

log "3) Insertion du bloc DB READY canonique après le démarrage stack"

awk '
{
  print
  if ($0 ~ /Démarrage stack/) {
    print ""
    print "log \"Attente DB (connexion applicative WordPress)…\""
    print ""
    print "for i in $(seq 1 60); do"
    print "  if docker compose -f \"$COMPOSE_APP\" exec -T db \\"
    print "     mysql -u\"$DB_USER\" -p\"$DB_PASSWORD\" \"$DB_NAME\" \\"
    print "     -e \"SELECT 1;\" >/dev/null 2>&1; then"
    print "    log \"DB prête (connexion applicative OK)\""
    print "    break"
    print "  fi"
    print "  sleep 2"
    print "done"
    print ""
    print "if ! docker compose -f \"$COMPOSE_APP\" exec -T db \\"
    print "     mysql -u\"$DB_USER\" -p\"$DB_PASSWORD\" \"$DB_NAME\" \\"
    print "     -e \"SELECT 1;\" >/dev/null 2>&1; then"
    print "  fail \"DB non prête (connexion applicative impossible)\""
    print "fi"
    print ""
  }
}
' "$C2.clean" > "$C2"

rm -f "$C2.clean"
chmod +x "$C2"

log "4) Vérification syntaxe Bash"
bash -n "$C2" || fail "Erreur de syntaxe Bash après patch"

log "5) Lancement immédiat de C2"
echo "------------------------------------------------------------"
time "$C2"
echo "------------------------------------------------------------"

echo "============================================================"
echo "[OK] FIX DB READY appliqué + C2 exécuté"
echo "============================================================"
