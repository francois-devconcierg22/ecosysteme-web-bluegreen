#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/home/adminso/bluegreen_v7_dev"
C2="$BASE_DIR/src/scripts/run_wp_bootstrap.sh"
RUNTIME_ENV="$BASE_DIR/tmp/runtime.env"

log(){ echo "[FIX-C2] $*"; }
fail(){ echo "[FATAL] $*" >&2; exit 1; }

echo "============================================================"
echo " FIX C2 — DB READY (NETWORK MODE) v7"
echo "============================================================"

[[ -f "$C2" ]] || fail "C2 introuvable"
[[ -f "$RUNTIME_ENV" ]] || fail "runtime.env introuvable"

set -a
source "$RUNTIME_ENV"
set +a

: "${DB_NAME:?}"
: "${DB_USER:?}"
: "${DB_PASSWORD:?}"

TS="$(date +%Y%m%d-%H%M%S)"
cp "$C2" "$C2.bak.db-ready-network.$TS"
log "Backup C2 créé"

# Suppression de tout ancien bloc d'attente DB
sed -i '/Attente DB/,/DB non prête/d' "$C2"

log "Insertion du bloc DB READY réseau canonique"

sed -i "/Démarrage stack/a\\
log \"Attente DB (connexion applicative réseau WordPress)…\"\\
for i in \$(seq 1 60); do\\
  if docker run --rm --network bg_shared_net mysql:8.0 \\\\\\n\
    mysql -h db -u\"\\\$DB_USER\" -p\"\\\$DB_PASSWORD\" \"\\\$DB_NAME\" \\\\\\n\
    -e \"SELECT 1;\" >/dev/null 2>&1; then\\
    log \"DB prête (connexion réseau OK)\"\\
    break\\
  fi\\
  sleep 2\\
done\\
docker run --rm --network bg_shared_net mysql:8.0 \\\\\\n\
  mysql -h db -u\"\\\$DB_USER\" -p\"\\\$DB_PASSWORD\" \"\\\$DB_NAME\" \\\\\\n\
  -e \"SELECT 1;\" >/dev/null 2>&1 || fail \"DB non prête (connexion réseau impossible)\"\\
" "$C2"

log "Vérification syntaxe Bash"
bash -n "$C2" || fail "Erreur de syntaxe Bash après patch"

echo "============================================================"
echo "[OK] C2 corrigé — DB READY en mode réseau"
echo "============================================================"
