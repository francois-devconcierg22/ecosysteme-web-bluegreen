#!/usr/bin/env bash
set -euo pipefail

BASE="/home/adminso/bluegreen_v7_dev"
SRC="$BASE/src"
COMPOSE="$SRC/docker-compose.app.yml"
RUNTIME="$BASE/tmp/runtime.env"
NET="bg_shared_net"
TS="$(date +%Y%m%d-%H%M%S)"

log(){ echo "[COMPOSE-REWRITE] $*"; }
fail(){ echo "[FATAL] $*" >&2; exit 1; }

[[ -f "$RUNTIME" ]] || fail "runtime.env manquant"
mkdir -p "$SRC"

if [[ -f "$COMPOSE" ]]; then
  cp "$COMPOSE" "$COMPOSE.bak.$TS"
  log "Backup créé : $COMPOSE.bak.$TS"
fi

log "Réécriture complète de docker-compose.app.yml"

cat > "$COMPOSE" <<'YML'
version: "3.9"

services:
  db:
    image: mysql:8.0
    container_name: bg-db
    restart: unless-stopped
    env_file:
      - ../tmp/runtime.env
    volumes:
      - db_data:/var/lib/mysql
    networks:
      - bg_shared_net

  wp-blue:
    image: wordpress:php8.2-fpm
    container_name: wp-blue
    restart: unless-stopped
    depends_on:
      - db
    env_file:
      - ../tmp/runtime.env
    environment:
      WORDPRESS_DB_HOST: db
    volumes:
      - ./blue/wp:/var/www/html
    networks:
      - bg_shared_net

  wp-green:
    image: wordpress:php8.2-fpm
    container_name: wp-green
    restart: unless-stopped
    depends_on:
      - db
    env_file:
      - ../tmp/runtime.env
    environment:
      WORDPRESS_DB_HOST: db
    volumes:
      - ./green/wp:/var/www/html
    networks:
      - bg_shared_net

volumes:
  db_data:

networks:
  bg_shared_net:
    external: true
YML

log "Validation docker compose"
docker compose -f "$COMPOSE" config >/dev/null

echo "============================================================"
echo "[OK] docker-compose.app.yml réécrit et valide"
echo "============================================================"
