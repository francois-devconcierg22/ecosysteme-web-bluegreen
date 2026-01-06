#!/bin/bash
set -euo pipefail

ROOT="/home/adminso/bluegreen_v7_dev"
ENV_FILE="$ROOT/.env"
LOG_DIR="$ROOT/_proof_logs"
TS="$(date +%Y%m%d_%H%M%S)"
OUT="$LOG_DIR/DB_PROOF_RUN_${TS}.log"

mkdir -p "$LOG_DIR"

mask() {
  local s="${1:-}"
  [ -z "$s" ] && printf "<empty>" && return
  printf "%s***%s" "${s:0:2}" "${s: -2}"
}

h() {
  printf "\n=================================================\n"
  printf "%s\n" "$*"
  printf "=================================================\n"
}

log() {
  printf "[%s] %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

snapshot_env() {
  h "SNAPSHOT ENV ($1)"
  printf "WORDPRESS_DB_NAME=%s\n" "${WORDPRESS_DB_NAME:-<unset>}"
  printf "WORDPRESS_DB_USER=%s\n" "${WORDPRESS_DB_USER:-<unset>}"
  printf "WORDPRESS_DB_PASSWORD(mask)=%s\n" "$(mask "${WORDPRESS_DB_PASSWORD:-}")"
  printf "WORDPRESS_DB_HOST=%s\n" "${WORDPRESS_DB_HOST:-<unset>}"
  printf "MYSQL_DATABASE=%s\n" "${MYSQL_DATABASE:-<unset>}"
  printf "MYSQL_USER=%s\n" "${MYSQL_USER:-<unset>}"
  printf "MYSQL_PASSWORD(mask)=%s\n" "$(mask "${MYSQL_PASSWORD:-}")"
  printf "MYSQL_ROOT_PASSWORD(mask)=%s\n" "$(mask "${MYSQL_ROOT_PASSWORD:-}")"
}

snapshot_docker() {
  h "SNAPSHOT DOCKER ($1)"
  docker ps --format "table {{.Names}}\t{{.Status}}" || true
}

docker_env_dump() {
  local c="$1"
  h "DOCKER ENV (container: $c)"
  if ! docker ps --format '{{.Names}}' | grep -qx "$c"; then
    log "[WARN] container absent: $c"
    return
  fi
  docker inspect "$c" --format '{{range .Config.Env}}{{println .}}{{end}}' \
    | grep -E '^(WORDPRESS_DB_|MYSQL_)' \
    | sed -E 's/(PASSWORD=).*/\1<masked>/'
}

mysql_try() {
  docker exec bg-db \
    mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT 1;" \
    >/dev/null 2>&1
}

###############################################################################
# START
###############################################################################
exec > >(tee -a "$OUT") 2>&1

h "DB CHAIN PROOF v7 — ÉTAT AVANT / APRÈS CHAQUE ÉTAPE"
log "ROOT : $ROOT"
log "ENV  : $ENV_FILE"
log "LOG  : $OUT"

if [ ! -f "$ENV_FILE" ]; then
  log "[FATAL] .env absent"
  exit 42
fi

set -a
. "$ENV_FILE"
set +a

snapshot_env "INITIAL"
snapshot_docker "INITIAL"

###############################################################################
h "STOP STACK"
snapshot_env "BEFORE STOP"
"$ROOT/compose_safe.sh" down --remove-orphans || true
docker rm -f wp-blue wp-green bg-db 2>/dev/null || true
snapshot_env "AFTER STOP"
snapshot_docker "AFTER STOP"

###############################################################################
h "START DB ONLY"
snapshot_env "BEFORE START DB"
"$ROOT/compose_safe.sh" up -d
snapshot_env "AFTER START DB"
snapshot_docker "AFTER START DB"

docker_env_dump "bg-db"

###############################################################################
h "WAIT MYSQL READY"
TIMEOUT=90
ELAPSED=0

while true; do
  log "[WAIT] SQL probe (${ELAPSED}s)"
  if mysql_try; then
    log "[OK] MySQL prêt (auth OK)"
    break
  fi
  [ "$ELAPSED" -ge "$TIMEOUT" ] && log "[FATAL] MySQL non prêt" && exit 42
  sleep 2
  ELAPSED=$((ELAPSED + 2))
done

###############################################################################
h "MYSQL STATE (ROOT)"
docker exec bg-db mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "
SELECT user,host FROM mysql.user;
SHOW DATABASES;
" || true

###############################################################################
h "START WORDPRESS"
snapshot_env "BEFORE START WP"
"$ROOT/compose_safe.sh" up -d wp-blue wp-green
snapshot_env "AFTER START WP"
snapshot_docker "AFTER START WP"

docker_env_dump "wp-blue"
docker_env_dump "wp-green"

###############################################################################
h "WP-CONFIG (wp-blue)"
docker exec wp-blue bash -lc \
  "grep -E \"DB_NAME|DB_USER|DB_PASSWORD|DB_HOST\" /var/www/html/wp-config.php" || true

###############################################################################
h "MYSQL AUTH TEST (WP USER)"
if mysql_try; then
  log "[OK] WP user authentifié"
else
  log "[FAIL] WP user NE PEUT PAS s'authentifier"
  exit 42
fi

###############################################################################
h "[DONE] DB CHAIN PROOF"
log "LOG : $OUT"
