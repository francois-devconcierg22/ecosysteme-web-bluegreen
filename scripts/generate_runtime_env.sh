#!/bin/bash
set -euo pipefail

ROOT="/home/adminso/bluegreen_v7_dev"
ENV_FILE="$ROOT/.env"
RUNTIME_DIR="$ROOT/tmp"
RUNTIME_ENV="$RUNTIME_DIR/runtime.env"
TS="$(date '+%Y-%m-%d %H:%M:%S')"

mask() {
  local s="${1:-}"
  [ -z "$s" ] && printf "<empty>" && return
  printf "%s***%s" "${s:0:2}" "${s: -2}"
}

printf "=================================================\n"
printf "[RUNTIME-ENV] Génération canonique depuis .env\n"
printf "ROOT : %s\n" "$ROOT"
printf "SRC  : %s\n" "$ENV_FILE"
printf "DST  : %s\n" "$RUNTIME_ENV"
printf "DATE : %s\n" "$TS"
printf "=================================================\n"

# --- Préconditions ---
if [ ! -f "$ENV_FILE" ]; then
  printf "[FATAL] .env absent\n"
  exit 42
fi

if ! grep -q '^# GENERATED_BY=resolve_env.sh' "$ENV_FILE"; then
  printf "[FATAL] .env non signé — génération runtime.env interdite\n"
  exit 42
fi

# --- Chargement explicite ---
set -a
# shellcheck disable=SC1090
. "$ENV_FILE"
set +a

# --- Vérifications strictes ---
REQUIRED=(
  WORDPRESS_DB_NAME
  WORDPRESS_DB_USER
  WORDPRESS_DB_PASSWORD
  MYSQL_ROOT_PASSWORD
)

for v in "${REQUIRED[@]}"; do
  if [ -z "${!v:-}" ]; then
    printf "[FATAL] Variable manquante dans .env : %s\n" "$v"
    exit 42
  fi
done

# --- Écriture atomique ---
mkdir -p "$RUNTIME_DIR"
TMP_FILE="$(mktemp)"

{
  printf "# GENERATED_BY=generate_runtime_env.sh\n"
  printf "# SOURCE=.env\n"
  printf "# GENERATED_AT=%s\n" "$TS"
  printf "# NE PAS MODIFIER A LA MAIN\n\n"

  printf "DB_NAME=%s\n" "$WORDPRESS_DB_NAME"
  printf "DB_USER=%s\n" "$WORDPRESS_DB_USER"
  printf "DB_PASSWORD=%s\n" "$WORDPRESS_DB_PASSWORD"
  printf "MYSQL_ROOT_PASSWORD=%s\n" "$MYSQL_ROOT_PASSWORD"
} > "$TMP_FILE"

chmod 600 "$TMP_FILE"
mv "$TMP_FILE" "$RUNTIME_ENV"

printf "[OK] runtime.env généré\n"
printf "DB_NAME=%s\n" "$WORDPRESS_DB_NAME"
printf "DB_USER=%s\n" "$WORDPRESS_DB_USER"
printf "DB_PASSWORD(mask)=%s\n" "$(mask "$WORDPRESS_DB_PASSWORD")"
printf "MYSQL_ROOT_PASSWORD(mask)=%s\n" "$(mask "$MYSQL_ROOT_PASSWORD")"
printf "=================================================\n"
