#!/bin/bash
set -euo pipefail

ROOT="/home/adminso/bluegreen_v7_dev"
TS="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="$ROOT/_patch_backups/$TS"
mkdir -p "$BACKUP_DIR"

printf "=================================================\n"
printf " PATCH v7 — USE compose_safe.sh everywhere\n"
printf " ROOT   : %s\n" "$ROOT"
printf " BACKUP : %s\n" "$BACKUP_DIR"
printf "=================================================\n"

COMPOSE_SAFE="$ROOT/src/scripts/compose_safe.sh"
if [ ! -x "$COMPOSE_SAFE" ]; then
  printf "[FATAL] compose_safe.sh introuvable ou non exécutable: %s\n" "$COMPOSE_SAFE"
  exit 42
fi

FILES=(
  "$ROOT/src/scripts/run_infra.sh"
  "$ROOT/src/scripts/run_wordpress_core.sh"
  "$ROOT/src/scripts/run_wp_bootstrap.sh"
  "$ROOT/src/scripts/wait_for_db.sh"
)

for f in "${FILES[@]}"; do
  if [ ! -f "$f" ]; then
    printf "[WARN] absent (skip): %s\n" "$f"
    continue
  fi
  cp "$f" "$BACKUP_DIR/$(basename "$f").bak"
  printf "[OK] Backup: %s\n" "$f"

  # Remplacements simples et sûrs
  sed -i \
    -e "s#docker compose --env-file .* -f .*docker-compose\.app\.yml#${COMPOSE_SAFE}#g" \
    -e "s#docker compose -f docker-compose\.app\.yml#${COMPOSE_SAFE}#g" \
    "$f"

  printf "[OK] Patched: %s\n" "$f"
done

printf "=================================================\n"
printf "[INFO] Smoke test: compose_safe.sh ps\n"
printf "=================================================\n"
bash "$COMPOSE_SAFE" ps || true

printf "=================================================\n"
printf "[INFO] Revalidation modes\n"
printf "=================================================\n"
bash /home/adminso/tools/run_all_modes_v7.sh

printf "=================================================\n"
printf "[DONE] PATCH compose_safe\n"
printf "=================================================\n"
