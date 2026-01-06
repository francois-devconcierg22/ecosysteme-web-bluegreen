#!/bin/bash
set -euo pipefail

ROOT="/home/adminso/bluegreen_v7_dev"
RUN_SH="$ROOT/src/run.sh"
TS="$(date +%Y%m%d_%H%M%S)"
BAK="$RUN_SH.bak.$TS"

printf "=================================================\n"
printf " PATCH v7 — ENABLE FULL MODE (idempotent)\n"
printf " ROOT  : %s\n" "$ROOT"
printf " RUNSH : %s\n" "$RUN_SH"
printf "=================================================\n"

if [ ! -f "$RUN_SH" ]; then
  printf "[FATAL] run.sh introuvable: %s\n" "$RUN_SH"
  exit 1
fi

cp "$RUN_SH" "$BAK"
printf "[OK] Backup: %s\n" "$BAK"

# Vérification scripts attendus
REQ=(
  "$ROOT/src/scripts/run_infra.sh"
  "$ROOT/src/scripts/run_wordpress_core.sh"
  "$ROOT/src/scripts/run_wp_bootstrap.sh"
)
for f in "${REQ[@]}"; do
  if [ ! -f "$f" ]; then
    printf "[FATAL] Script requis manquant: %s\n" "$f"
    exit 1
  fi
done

# Patch: remplace le bloc full) ... ;; par une implémentation
# Hypothèse: run.sh contient un case "$PROFILE" in ... full) ... ;; ... esac
python3 - <<'PY'
import re, pathlib, sys
run_sh = pathlib.Path("/home/adminso/bluegreen_v7_dev/src/run.sh")
txt = run_sh.read_text()

pattern = r"(^[ \t]*full\)[\s\S]*?^[ \t]*;;\s*$)"
m = re.search(pattern, txt, flags=re.M)
if not m:
    print("[FATAL] Bloc 'full)' introuvable dans run.sh", file=sys.stderr)
    sys.exit(2)

replacement = """full)
    printf "[INFO] Profil d’installation : full\\n"

    # 0) Préflight .env (doit être généré par resolve_env.sh)
    if [ ! -f "/home/adminso/bluegreen_v7_dev/.env" ]; then
      printf "[FATAL] .env absent — exécute d’abord resolve_env.sh\\n"
      exit 42
    fi

    # 1) Infra (Traefik + réseau + volumes + DB up)
    bash "/home/adminso/bluegreen_v7_dev/src/scripts/run_infra.sh"

    # 2) WordPress core (containers WP up)
    bash "/home/adminso/bluegreen_v7_dev/src/scripts/run_wordpress_core.sh"

    # 3) Bootstrap WP (idempotent)
    #    Doit gérer "déjà installé" sans fail.
    bash "/home/adminso/bluegreen_v7_dev/src/scripts/run_wp_bootstrap.sh"

    printf "[OK] Mode full terminé\\n"
    ;;
"""
new_txt = re.sub(pattern, replacement, txt, flags=re.M)
run_sh.write_text(new_txt)
print("[OK] Bloc full) patché")
PY

chmod +x "$RUN_SH"
printf "[OK] run.sh patché et exécutable\n"
printf "=================================================\n"

printf "[INFO] Revalidation: /home/adminso/tools/run_all_modes_v7.sh\n"
bash /home/adminso/tools/run_all_modes_v7.sh

printf "=================================================\n"
printf "[DONE] PATCH ENABLE FULL\n"
printf "=================================================\n"
