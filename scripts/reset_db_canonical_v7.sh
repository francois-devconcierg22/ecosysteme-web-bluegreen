#!/bin/bash
set -euo pipefail

ROOT="/home/adminso/bluegreen_v7_dev"
ENV_FILE="$ROOT/.env"
RUNTIME_ENV="$ROOT/tmp/runtime.env"
COMPOSE="$ROOT/compose_safe.sh"
TS="$(date '+%Y-%m-%d %H:%M:%S')"

mask() { local s="${1:-}"; [ -z "$s" ] && printf "<empty>" && return; printf "%s***%s" "${s:0:2}" "${s: -2}"; }

snapshot_env() {
  printf "\n=================================================\n"
  printf "SNAPSHOT VARIABLES (%s)\n" "$1"
  printf "=================================================\n"
  printf "WORDPRESS_DB_NAME=%s\n" "$WORDPRESS_DB_NAME"
  printf "WORDPRESS_DB_USER=%s\n" "$WORDPRESS_DB_USER"
  printf "WORDPRESS_DB_PASSWORD(mask)=%s\n" "$(mask "$WORDPRESS_DB_PASSWORD")"
  printf "MYSQL_ROOT_PASSWORD(mask)=%s\n" "$(mask "$MYSQL_ROOT_PASSWORD")"
}

snapshot_runtime_env() {
  printf "\n=================================================\n"
  printf "SNAPSHOT tmp/runtime.env\n"
  printf "=================================================\n"
  sed -E 's/(PASSWORD)=.*/\1=<masked>/g' "$RUNTIME_ENV" || true
}

printf "\n=================================================\n"
printf "[RESET-DB] RESET DB CANONIQUE v7\n"
printf "DATE : %s\n" "$TS"
printf "ROOT : %s\n" "$ROOT"
printf "=================================================\n"

printf "\n=================================================\n"
printf "[STEP 1] Vérification .env et runtime.env\n"
printf "=================================================\n"

for f in "$ENV_FILE" "$RUNTIME_ENV"; do
  if [ ! -f "$f" ]; then
    printf "[FATAL] Fichier absent : %s\n" "$f"
    exit 42
  fi
done

set -a
. "$ENV_FILE"
. "$RUNTIME_ENV"
set +a

REQUIRED=( WORDPRESS_DB_NAME WORDPRESS_DB_USER WORDPRESS_DB_PASSWORD MYSQL_ROOT_PASSWORD )
for v in "${REQUIRED[@]}"; do
  if [ -z "${!v:-}" ]; then
    printf "[FATAL] Variable manquante : %s\n" "$v"
    exit 42
  fi
done

printf "[OK] Sources de vérité valides\n"
snapshot_env "AVANT RESET"
snapshot_runtime_env

printf "\n=================================================\n"
printf "[STEP 2] Arrêt stack + purge volumes (down -v)\n"
printf "=================================================\n"
"$COMPOSE" down --remove-orphans -v || true

printf "\n=================================================\n"
printf "[STEP 3] Détection service DB (compose config)\n"
printf "=================================================\n"

SERVICES="$("$COMPOSE" config --services 2>/dev/null || true)"
printf "[DEBUG] Services détectés :\n%s\n" "${SERVICES:-<aucun>}"

DB_SERVICE="$(printf "%s\n" "$SERVICES" | grep -E '^(db|mysql|mariadb)$' | head -n1 || true)"
if [ -z "$DB_SERVICE" ]; then
  printf "[FATAL] Aucun service DB détecté\n"
  exit 42
fi
printf "[OK] Service DB = %s\n" "$DB_SERVICE"

printf "\n=================================================\n"
printf "[STEP 4] Démarrage DB seule (%s)\n" "$DB_SERVICE"
printf "=================================================\n"
"$COMPOSE" up -d "$DB_SERVICE"

printf "\n=================================================\n"
printf "[STEP 5] Détection conteneur DB réel\n"
printf "=================================================\n"
DB_CONTAINER=""
for i in $(seq 1 30); do
  DB_CONTAINER="$(docker ps --format '{{.Names}}' | grep -E 'bg-db|db|mysql|mariadb' | head -n1 || true)"
  [ -n "$DB_CONTAINER" ] && break
  sleep 1
done
if [ -z "$DB_CONTAINER" ]; then
  printf "[FATAL] Conteneur DB non détecté après démarrage\n"
  docker ps
  exit 42
fi
printf "[OK] DB_CONTAINER = %s\n" "$DB_CONTAINER"

printf "\n=================================================\n"
printf "[STEP 6] Attente MySQL READY (SQL)\n"
printf "=================================================\n"
for i in $(seq 1 45); do
  if docker exec "$DB_CONTAINER" mysqladmin ping -uroot -p"$MYSQL_ROOT_PASSWORD" --silent >/dev/null 2>&1; then
    printf "[OK] MySQL prêt\n"
    break
  fi
  sleep 1
done
if ! docker exec "$DB_CONTAINER" mysqladmin ping -uroot -p"$MYSQL_ROOT_PASSWORD" --silent >/dev/null 2>&1; then
  printf "[FATAL] MySQL non prêt après timeout\n"
  exit 42
fi

snapshot_env "APRÈS RESET"
snapshot_runtime_env

printf "\n=================================================\n"
printf "[DONE] RESET DB CANONIQUE v7 — SUCCÈS\n"
printf "=================================================\n"
