#!/bin/bash
set -euo pipefail

ROOT="/home/adminso/bluegreen_v7_dev"
ENV_FILE="$ROOT/.env"
TS="$(date '+%Y-%m-%d %H:%M:%S')"

printf "=================================================\n"
printf "[%s] CHECK .env — WORDPRESS DB\n" "$TS"
printf "ENV_FILE : %s\n" "$ENV_FILE"
printf "=================================================\n"

if [ ! -f "$ENV_FILE" ]; then
  printf "[FATAL] .env absent\n"
  exit 42
fi

if ! grep -q '^# GENERATED_BY=resolve_env.sh' "$ENV_FILE"; then
  printf "[FATAL] .env non signé\n"
  exit 42
fi

REQUIRED_VARS=(
  WORDPRESS_DB_NAME
  WORDPRESS_DB_USER
  WORDPRESS_DB_PASSWORD
  WORDPRESS_DB_HOST
  MYSQL_DATABASE
  MYSQL_USER
  MYSQL_PASSWORD
)

for v in "${REQUIRED_VARS[@]}"; do
  if ! grep -q "^$v=" "$ENV_FILE"; then
    printf "[FATAL] %s manquant dans .env\n" "$v"
    exit 42
  fi

  val="$(grep "^$v=" "$ENV_FILE" | cut -d= -f2-)"
  if [ -z "$val" ]; then
    printf "[FATAL] %s vide\n" "$v"
    exit 42
  fi
done

printf "[OK] .env valide et cohérent WordPress/MySQL\n"
printf "=================================================\n"
