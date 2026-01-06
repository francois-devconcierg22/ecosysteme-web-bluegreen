#!/bin/bash
set -euo pipefail

ROOT="/home/adminso/bluegreen_v7_dev"
ENV_FILE="$ROOT/.env"
TS="$(date '+%Y-%m-%d %H:%M:%S')"

printf "=================================================\n"
printf "[%s] RESOLUTION ENV — DB + WORDPRESS\n" "$TS"
printf "ENV_FILE : %s\n" "$ENV_FILE"
printf "=================================================\n"

if [ -z "${PROJECT_PREFIX:-}" ]; then
  printf "[FATAL] PROJECT_PREFIX non défini\n"
  exit 42
fi

if [ -z "${WP_DOMAIN:-}" ]; then
  printf "[FATAL] WP_DOMAIN non défini\n"
  exit 42
fi

DB_NAME="${PROJECT_PREFIX}_wp"
DB_USER="${PROJECT_PREFIX}_user"
DB_PASSWORD="$(openssl rand -hex 16)"
DB_HOST="db"
MYSQL_ROOT_PASSWORD="$(openssl rand -hex 16)"

if [ -f "$ENV_FILE" ]; then
  printf "[INFO] Backup .env existant\n"
  cp "$ENV_FILE" "$ENV_FILE.bak.$(date +%s)"
fi

printf "[INFO] Génération .env compatible WordPress\n"

cat > "$ENV_FILE" <<ENVEOF
# GENERATED_BY=resolve_env.sh
# GENERATED_AT=$TS
# NE PAS MODIFIER A LA MAIN

PROJECT_PREFIX=$PROJECT_PREFIX
WP_DOMAIN=$WP_DOMAIN

# --- MySQL ---
MYSQL_DATABASE=$DB_NAME
MYSQL_USER=$DB_USER
MYSQL_PASSWORD=$DB_PASSWORD
MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD

# --- WordPress natif ---
WORDPRESS_DB_NAME=$DB_NAME
WORDPRESS_DB_USER=$DB_USER
WORDPRESS_DB_PASSWORD=$DB_PASSWORD
WORDPRESS_DB_HOST=$DB_HOST
ENVEOF

chmod 600 "$ENV_FILE"

printf "[OK] .env généré (WordPress prêt)\n"
printf "=================================================\n"
