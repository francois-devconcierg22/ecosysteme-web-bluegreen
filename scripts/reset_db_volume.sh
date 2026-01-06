#!/bin/bash
set -euo pipefail

ROOT="/home/adminso/bluegreen_v7_dev"
TS="$(date '+%Y-%m-%d %H:%M:%S')"

printf "=================================================\n"
printf "[%s] RESET DB — MYSQL VOLUME\n" "$TS"
printf "ROOT : %s\n" "$ROOT"
printf "=================================================\n"

printf "[STEP] Vérification .env\n"
bash "$ROOT/src/scripts/assert_env_resolved.sh"

printf "[STEP] Arrêt stack applicative\n"
cd "$ROOT/src"
docker compose -f docker-compose.app.yml down

printf "[STEP] Suppression volume MySQL\n"
docker volume rm ${PROJECT_PREFIX:-cso}_mysql_data 2>/dev/null || true
docker volume ls | grep mysql || true

printf "[STEP] Redémarrage MySQL (init propre)\n"
docker compose -f docker-compose.app.yml up -d db

printf "[INFO] Attente initialisation MySQL\n"
sleep 12

printf "[STEP] Redémarrage WordPress\n"
docker compose -f docker-compose.app.yml up -d

printf "[OK] Reset DB terminé\n"
printf "=================================================\n"
