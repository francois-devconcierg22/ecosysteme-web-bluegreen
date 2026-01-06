#!/bin/bash
set -e

printf "[INFO] Préflight WordPress DB...\n"

if ! wp db check --allow-root >/dev/null 2>&1; then
  printf "[ERROR] Base de données WordPress inaccessible\n"
  exit 42
fi

printf "[OK] Préflight WordPress DB OK\n"
