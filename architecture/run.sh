#!/bin/bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${BASE_DIR}"

echo "============================================================"
echo "      INSTALLATION BLUE/GREEN – CORE v6.3.4 (stable)"
echo "============================================================"

# ------------------------------------------------------------
# 1. PREFLIGHT
# ------------------------------------------------------------
if [ -x "${BASE_DIR}/scripts/preflight_check.sh" ]; then
  "${BASE_DIR}/scripts/preflight_check.sh"
else
  echo "[WARNING] scripts/preflight_check.sh introuvable ou non exécutable."
fi

# ------------------------------------------------------------
# 2. Génération des secrets + .env (ONE-SHOT)
# ------------------------------------------------------------
ENV_FILE="${BASE_DIR}/.env"
SECRETS_FILE="${BASE_DIR}/secrets.env"

if [ -f "${ENV_FILE}" ]; then
  echo "[INFO] .env déjà présent → aucune régénération des secrets."
else
  echo "[INFO] .env absent → génération des secrets + env_base + .env…"

  # 2.1 secrets.env
  if [ -x "${BASE_DIR}/scripts/generate_passwords.sh" ]; then
    "${BASE_DIR}/scripts/generate_passwords.sh"
  else
    echo "[FATAL] scripts/generate_passwords.sh introuvable ou non exécutable."
    exit 1
  fi

  # 2.2 env_base.env depuis global.conf
  if [ -x "${BASE_DIR}/scripts/import_global_conf.sh" ]; then
    "${BASE_DIR}/scripts/import_global_conf.sh"
  else
    echo "[FATAL] scripts/import_global_conf.sh introuvable ou non exécutable."
    exit 1
  fi

  # 2.3 fusion secrets + env_base → .env final
  if [ -x "${BASE_DIR}/scripts/merge_secrets_into_global.sh" ]; then
    "${BASE_DIR}/scripts/merge_secrets_into_global.sh"
  else
    echo "[FATAL] scripts/merge_secrets_into_global.sh introuvable ou non exécutable."
    exit 1
  fi

  if [ ! -f "${ENV_FILE}" ]; then
    echo "[FATAL] .env n'a pas été généré correctement."
    exit 1
  fi
fi

echo "[OK] .env prêt pour le lancement Docker."

# ------------------------------------------------------------
# 3. Téléchargement de WordPress (si nécessaire)
# ------------------------------------------------------------
if [ -x "${BASE_DIR}/scripts/download_wordpress.sh" ]; then
  "${BASE_DIR}/scripts/download_wordpress.sh"
else
  echo "[WARNING] scripts/download_wordpress.sh introuvable ou non exécutable."
fi

# ------------------------------------------------------------
# 4. Application du template wp-config vers blue/green
# ------------------------------------------------------------
if [ -x "${BASE_DIR}/scripts/apply_wp_config_template.sh" ]; then
  "${BASE_DIR}/scripts/apply_wp_config_template.sh"
else
  echo "[FATAL] scripts/apply_wp_config_template.sh introuvable ou non exécutable."
  exit 1
fi

# ------------------------------------------------------------
# 5. Lancement des conteneurs Docker (Traefik + DB + WP)
# ------------------------------------------------------------
echo "------------------------------------------------------------"
echo " Lancement des services Docker (Traefik + DB + WP)…"
echo "------------------------------------------------------------"

docker compose -f docker-compose.traefik.yml -f docker-compose.app.yml up -d

echo "============================================================"
echo " INSTALLATION BLUE/GREEN TERMINÉE – v6.3.4"
echo "============================================================"
echo "Conteneurs actifs (docker ps) :"
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
echo "============================================================"
echo "Étape suivante (dans ce répertoire) :"
echo "  bash scripts/wp_auto_install.sh blue"
echo "  bash scripts/wp_auto_install.sh green"
echo "============================================================"
