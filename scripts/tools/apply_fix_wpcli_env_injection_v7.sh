#!/usr/bin/env bash
set -euo pipefail

C2="/home/adminso/bluegreen_v7_dev/src/scripts/run_wp_bootstrap.sh"
TS="$(date +%Y%m%d-%H%M%S)"

log(){ echo "[WPCLI-FIX] $*"; }
fail(){ echo "[FATAL] $*" >&2; exit 1; }

[[ -f "$C2" ]] || fail "C2 introuvable: $C2"

log "Backup du script C2"
cp "$C2" "$C2.bak.wpcli-env.$TS"

log "Réécriture propre de wpcli_run() avec injection explicite des variables DB"

awk '
BEGIN { in_fn=0 }
/^wpcli_run\(\)/ {
  in_fn=1
  print "wpcli_run() {"
  print "  local slot=\"$1\"; shift"
  print "  docker compose \\"
  print "    -f \"$COMPOSE_APP\" \\"
  print "    -f \"$COMPOSE_WPCLI\" \\"
  print "    run --rm \\"
  print "    --env DB_NAME=\"$DB_NAME\" \\"
  print "    --env DB_USER=\"$DB_USER\" \\"
  print "    --env DB_PASSWORD=\"$DB_PASSWORD\" \\"
  print "    --env WORDPRESS_DB_HOST=\"$DB_SERVICE\" \\"
  print "    wpcli wp \"$@\""
  print "}"
  next
}
in_fn && /^}/ {
  in_fn=0
  next
}
!in_fn { print }
' "$C2" > "$C2.tmp"

mv "$C2.tmp" "$C2"

log "Vérification syntaxe Bash"
bash -n "$C2"

echo "============================================================"
echo "[OK] wpcli_run() corrigé"
echo " - Injection DB explicite"
echo " - Compatible wordpress:cli"
echo " - Aucun wait DB"
echo "============================================================"
