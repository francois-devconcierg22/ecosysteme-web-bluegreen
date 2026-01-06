#!/bin/bash
set -euo pipefail

ROOT="/home/adminso/bluegreen_v7_dev"
ENV_FILE="$ROOT/.env"
COMPOSE_FILE="$ROOT/src/docker-compose.app.yml"

printf "=================================================\n"
printf "[COMPOSE SAFE] docker compose (env-file root)\n"
printf "ROOT     : %s\n" "$ROOT"
printf "ENV_FILE : %s\n" "$ENV_FILE"
printf "COMPOSE  : %s\n" "$COMPOSE_FILE"
printf "CMD      : docker compose %s\n" "${*:-<none>}"
printf "=================================================\n"

if [ ! -f "$ENV_FILE" ]; then
  printf "[FATAL] .env absent : %s\n" "$ENV_FILE"
  exit 42
fi

if ! grep -q '^# GENERATED_BY=resolve_env.sh' "$ENV_FILE"; then
  printf "[FATAL] .env non signé — exécute resolve_env.sh\n"
  exit 42
fi

exec docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" "$@"
