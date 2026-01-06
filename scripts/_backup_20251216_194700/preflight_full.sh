#!/bin/bash
set -euo pipefail

# ------------------------------------------------------------
# PREFLIGHT COMPLET – BLUE/GREEN v6.3.6
# ------------------------------------------------------------

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"   # => src/
PROJECT_ROOT="$(cd "${BASE_DIR}/.." && pwd)"                  # => bg_build_v6_3_6/
LOG_DIR="${PROJECT_ROOT}/logs"
TS="$(date +"%Y-%m-%d_%H-%M-%S")"
LOG_FILE="${LOG_DIR}/preflight_${TS}.log"

mkdir -p "${LOG_DIR}"

log() {
  echo "$@" | tee -a "${LOG_FILE}"
}

log "============================================================"
log "          BLUE/GREEN – PREFLIGHT COMPLET v6.3.6"
log " BASE_DIR      : ${BASE_DIR}"
log " PROJECT_ROOT  : ${PROJECT_ROOT}"
log " LOG_FILE      : ${LOG_FILE}"
log "============================================================"

# ------------------------------------------------------------
# 1. BINAIRE DOCKER / DOCKER COMPOSE
# ------------------------------------------------------------
if command -v docker >/dev/null 2>&1; then
  log "[OK] binaire docker trouvé."
else
  log "[FATAL] docker introuvable dans le PATH."
  exit 1
fi

if docker compose version >/dev/null 2>&1; then
  log "[OK] docker compose (plugin) disponible."
elif command -v docker-compose >/dev/null 2>&1; then
  log "[OK] docker-compose standalone disponible."
else
  log "[FATAL] docker compose / docker-compose introuvable."
  exit 1
fi

# ------------------------------------------------------------
# 2. FICHIERS CŒUR DU PACKAGE
# ------------------------------------------------------------
REQUIRED_FILES=(
  "${BASE_DIR}/docker-compose.app.yml"
  "${BASE_DIR}/docker-compose.traefik.yml"
  "${BASE_DIR}/env_base.env"
  "${BASE_DIR}/global.conf"
)

for f in "${REQUIRED_FILES[@]}"; do
  if [ -f "${f}" ]; then
    log "[OK] Fichier présent : ${f}"
  else
    log "[FATAL] Fichier requis manquant : ${f}"
    exit 1
  fi
done

# ------------------------------------------------------------
# 3. PRÉSENCE DES wp-config.template.php DANS LES SLOTS
# ------------------------------------------------------------
for slot in "wp" "blue/wp" "green/wp"; do
  if [ -f "${BASE_DIR}/${slot}/wp-config.template.php" ]; then
    log "[OK] wp-config.template.php présent dans ${slot}"
  else
    log "[WARN] wp-config.template.php MANQUANT dans ${slot}"
  fi
done

# ------------------------------------------------------------
# 4. VÉRIFICATION .env / secrets.env
# ------------------------------------------------------------
for f in "${BASE_DIR}/.env" "${BASE_DIR}/secrets.env"; do
  if [ -f "${f}" ]; then
    log "[WARN] Fichier déjà présent AVANT installation : ${f}"
  else
    log "[OK] Fichier absent (sera généré au premier run) : ${f}"
  fi
done

# ------------------------------------------------------------
# 5. DROITS D'EXÉCUTION SUR scripts/*.sh
# ------------------------------------------------------------
if [ -d "${BASE_DIR}/scripts" ]; then
  chmod +x "${BASE_DIR}"/scripts/*.sh || true
  log "[OK] Droits d'exécution appliqués sur ${BASE_DIR}/scripts/*.sh"
else
  log "[FATAL] Répertoire scripts/ introuvable dans ${BASE_DIR}"
  exit 1
fi

# ------------------------------------------------------------
# 6. AUDIT SSH / ENV SI PRÉSENT
# ------------------------------------------------------------
if [ -x "${BASE_DIR}/scripts/audit_ssh_env.sh" ]; then
  log "[INFO] Exécution audit_ssh_env.sh (résumé dans ce log)…"
  if "${BASE_DIR}/scripts/audit_ssh_env.sh" >> "${LOG_FILE}" 2>&1; then
    log "[OK] audit_ssh_env.sh terminé (voir détails dans ${LOG_FILE})."
  else
    log "[WARN] audit_ssh_env.sh a retourné un code non nul (voir log)."
  fi
else
  log "[INFO] audit_ssh_env.sh non présent (optionnel)."
fi

log "============================================================"
log "[OK] PREFLIGHT COMPLET TERMINÉ – voir ${LOG_FILE}"
log "============================================================"
