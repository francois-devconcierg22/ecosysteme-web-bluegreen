#!/usr/bin/env bash
set -euo pipefail

C2="/home/adminso/bluegreen_v7_dev/src/scripts/run_wp_bootstrap.sh"
SRC="/home/adminso/bluegreen_v7_dev/src"
TS="$(date +%Y%m%d-%H%M%S)"

log(){ echo "[WPCLI-VOLUME-FIX] $*"; }
fail(){ echo "[FATAL] $*" >&2; exit 1; }

cp "$C2" "$C2.bak.wpcli-volume.$TS"
log "Backup créé"

awk '
BEGIN { in_fn=0 }
/^wpcli_run\(\)/ {
  in_fn=1
  print "wpcli_run() {"
  print "  local slot=\"$1\"; shift"
  print "  local WP_DIR=\"$SRC/$slot/wp\""
  print "  docker compose \\"
  print "    -f \"$COMPOSE_APP\" \\"
  print "    -f \"$COMPOSE_WPCLI\" \\"
  print "    run --rm \\"
  print "    -v \"$WP_DIR:/var/www/html\" \\"
  print "    --env DB_NAME=\"$DB_NAME\" \\"
  print "    --env DB_USER=\"$DB_USER\" \\"
  print "    --env DB_PASSWORD=\"$DB_PASSWORD\" \\"
  print "    --env WORDPRESS_DB_HOST=\"$DB_SERVICE\" \\"
  print "    wpcli wp \"$@\""
  print "}"
  next
}
in_fn && /^}/ { in_fn=0; next }
!in_fn { print }
' "$C2" > "$C2.tmp"

mv "$C2.tmp" "$C2"
bash -n "$C2"

echo "============================================================"
echo "[OK] wpcli_run corrigé — volume WordPress aligné"
echo "============================================================"
