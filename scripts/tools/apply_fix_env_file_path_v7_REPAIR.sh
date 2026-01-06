#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/home/adminso/bluegreen_v7_dev"
COMPOSE_DIR="$BASE_DIR/src"
RUNTIME_REAL="$BASE_DIR/tmp/runtime.env"

log(){ echo "[REPAIR] $*"; }
fail(){ echo "[FATAL] $*" >&2; exit 1; }

echo "============================================================"
echo " REPAIR ENV_FILE PATH — BLUEGREEN v7"
echo "============================================================"

[[ -f "$RUNTIME_REAL" ]] || fail "runtime.env introuvable: $RUNTIME_REAL"

# Fichiers actifs uniquement (on EXCLUT les backups)
mapfile -t FILES < <(find "$COMPOSE_DIR" -maxdepth 1 -type f -name 'docker-compose*.yml' ! -name '*.bak.*' -print | sort)
[[ "${#FILES[@]}" -gt 0 ]] || fail "Aucun docker-compose*.yml actif trouvé dans $COMPOSE_DIR"

TS="$(date +%Y%m%d-%H%M%S)"
for f in "${FILES[@]}"; do
  cp "$f" "$f.bak.repair.$TS"
done
log "Backups repair créés (*.bak.repair.$TS)"

echo
log "Avant (lignes env_file + lignes runtime.env) :"
for f in "${FILES[@]}"; do
  echo "----- $f"
  grep -nE 'env_file:|runtime\.env' "$f" || true
done

# Normalisation robuste : on ne modifie QUE les entrées listées sous env_file
python3 - <<'PY'
import re, sys, pathlib

base = pathlib.Path("/home/adminso/bluegreen_v7_dev/src")
files = sorted([p for p in base.glob("docker-compose*.yml") if ".bak." not in p.name and ".bak.repair." not in p.name])

def normalize_envfile_block(lines):
    out = []
    i = 0
    while i < len(lines):
        line = lines[i]
        out.append(line)
        # détecte un bloc "env_file:" puis normalise les items "- ..."
        if re.match(r'^\s*env_file:\s*$', line):
            i += 1
            while i < len(lines) and re.match(r'^\s*-\s*', lines[i]):
                item = lines[i]
                # remplace toute variante pointant vers tmp/runtime.env par ../tmp/runtime.env
                # couvre: ./tmp/runtime.env, tmp/runtime.env, /tmp/runtime.env, ../tmp/runtime.env,
                # et les corruptions type .../..../tmp/runtime.env (suite de points et /)
                item_norm = re.sub(
                    r'(^\s*-\s*)(["\']?)\s*(?:\.+/)+tmp/runtime\.env\s*\2\s*$',
                    r'\1\2../tmp/runtime.env\2\n',
                    item
                )
                item_norm = re.sub(
                    r'(^\s*-\s*)(["\']?)\s*(?:\./)?tmp/runtime\.env\s*\2\s*$',
                    r'\1\2../tmp/runtime.env\2\n',
                    item_norm
                )
                item_norm = re.sub(
                    r'(^\s*-\s*)(["\']?)\s*/tmp/runtime\.env\s*\2\s*$',
                    r'\1\2../tmp/runtime.env\2\n',
                    item_norm
                )
                # si déjà correct, on laisse tel quel
                out.append(item_norm)
                i += 1
            continue
        i += 1
    return out

for p in files:
    txt = p.read_text(encoding="utf-8")
    lines = txt.splitlines(keepends=True)
    new_lines = normalize_envfile_block(lines)
    p.write_text("".join(new_lines), encoding="utf-8")

PY

echo
log "Après normalisation (lignes env_file + runtime.env) :"
for f in "${FILES[@]}"; do
  echo "----- $f"
  grep -nE 'env_file:|runtime\.env' "$f" || true
done

# Vérification stricte : chaque bloc env_file doit référencer ../tmp/runtime.env
echo
log "Vérification stricte des chemins env_file…"
for f in "${FILES[@]}"; do
  # On vérifie uniquement les lignes "- ..." qui suivent env_file
  awk '
    $0 ~ /^[[:space:]]*env_file:[[:space:]]*$/ {inblock=1; next}
    inblock && $0 ~ /^[[:space:]]*-[[:space:]]*/ {
      gsub(/^[[:space:]]*-[[:space:]]*/, "", $0)
      gsub(/["'\''[:space:]]/, "", $0)
      if ($0 != "../tmp/runtime.env") { bad=1; print "[BAD] " FILENAME ":" NR ": " $0 }
      next
    }
    inblock { inblock=0 }
    END { if (bad) exit 2 }
  ' "$f" || fail "env_file invalide dans $f (voir lignes [BAD] ci-dessus)"
done
log "OK — tous les env_file pointent vers ../tmp/runtime.env"

echo
log "Relance stack (app)"
docker compose -f "$COMPOSE_DIR/docker-compose.app.yml" down -v
docker network rm src_default 2>/dev/null || true
docker compose -f "$COMPOSE_DIR/docker-compose.app.yml" up -d

echo "============================================================"
echo "[OK] REPAIR TERMINÉ — compose corrigés + stack relancée"
echo "============================================================"
