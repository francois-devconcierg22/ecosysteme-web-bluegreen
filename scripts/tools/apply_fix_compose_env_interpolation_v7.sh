#!/usr/bin/env bash
set -euo pipefail

BASE="/home/adminso/bluegreen_v7_dev"
SRC="$BASE/src"
RUNTIME="$BASE/tmp/runtime.env"
COMPOSE_APP="$SRC/docker-compose.app.yml"
NET="bg_shared_net"
PROJECT="bgv7"
TS="$(date +%Y%m%d-%H%M%S)"

log(){ echo "[ENV-FIX] $*"; }
fail(){ echo "[FATAL] $*" >&2; exit 1; }

echo "============================================================"
echo " FIX COMPOSE ENV (NO INTERPOLATION) — BLUEGREEN v7"
echo "============================================================"

[[ -f "$RUNTIME" ]] || fail "runtime.env manquant: $RUNTIME"
[[ -f "$COMPOSE_APP" ]] || fail "docker-compose.app.yml manquant: $COMPOSE_APP"
docker network inspect "$NET" >/dev/null 2>&1 || fail "Réseau requis absent: $NET"

cp "$COMPOSE_APP" "$COMPOSE_APP.bak.envfix.$TS"
log "Backup: $COMPOSE_APP.bak.envfix.$TS"

log "1) Réécriture docker-compose.app.yml (env_file = source unique, sans \${...})"
cat > "$COMPOSE_APP" <<YML
services:
  db:
    image: mysql:8.0
    container_name: bg-db
    restart: unless-stopped
    env_file:
      - ../tmp/runtime.env
    environment:
      MYSQL_ROOT_PASSWORD: \${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: \${DB_NAME}
      MYSQL_USER: \${DB_USER}
      MYSQL_PASSWORD: \${DB_PASSWORD}
    volumes:
      - db_data:/var/lib/mysql
    networks:
      - ${NET}

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
      WORDPRESS_DB_USER: \${DB_USER}
      WORDPRESS_DB_PASSWORD: \${DB_PASSWORD}
      WORDPRESS_DB_NAME: \${DB_NAME}
    volumes:
      - ./blue/wp:/var/www/html
    networks:
      - ${NET}

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
      WORDPRESS_DB_USER: \${DB_USER}
      WORDPRESS_DB_PASSWORD: \${DB_PASSWORD}
      WORDPRESS_DB_NAME: \${DB_NAME}
    volumes:
      - ./green/wp:/var/www/html
    networks:
      - ${NET}

networks:
  ${NET}:
    external: true
    name: ${NET}

volumes:
  db_data:
YML

log "2) Validation config AVEC --env-file (interpolation garantie)"
docker compose -p "$PROJECT" -f "$COMPOSE_APP" --env-file "$RUNTIME" config >/dev/null

log "3) Redéploiement propre (down -v pour DB propre) + up"
docker compose -p "$PROJECT" -f "$COMPOSE_APP" --env-file "$RUNTIME" down -v --remove-orphans || true
docker compose -p "$PROJECT" -f "$COMPOSE_APP" --env-file "$RUNTIME" up -d

log "4) Vérification variables réellement injectées dans bg-db"
docker exec bg-db sh -lc 'echo "MYSQL_DATABASE=$MYSQL_DATABASE"; echo "MYSQL_USER=$MYSQL_USER"; echo "MYSQL_PASSWORD=${MYSQL_PASSWORD:+***}"; echo "MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:+***}"' || true

log "5) Smoke test DB réseau (attente + SELECT 1)"
set -a; source "$RUNTIME"; set +a
: "${DB_NAME:?}"; : "${DB_USER:?}"; : "${DB_PASSWORD:?}"

for i in $(seq 1 60); do
  if docker run --rm --network "$NET" mysql:8.0 \
    mysql -h db -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" -e "SELECT 1;" >/dev/null 2>&1; then
    log "DB prête (réseau OK)"
    break
  fi
  sleep 2
done

docker run --rm --network "$NET" mysql:8.0 \
  mysql -h db -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" -e "SELECT 1;" >/dev/null 2>&1 \
  || fail "DB non prête (réseau) après timeout"

echo "============================================================"
echo "[OK] COMPOSE ENV FIXÉ + DB OK — prêt pour C2"
echo "============================================================"

log "6) Lancement C2"
exec "$BASE/src/scripts/run_wp_bootstrap.sh"
