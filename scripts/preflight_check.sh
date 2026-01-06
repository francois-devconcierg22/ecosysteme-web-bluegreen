#!/bin/bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

ERRORS=0
WARNINGS=0

info()    { echo "[INFO] $*"; }
warning() { echo "[WARNING] $*"; WARNINGS=$((WARNINGS+1)); }
critical(){ echo "[CRITICAL] $*"; ERRORS=$((ERRORS+1)); }

info "Vérification des répertoires..."

for dir in blue blue/wp green green/wp traefik traefik/dynamic scripts wp; do
  if [ ! -d "${BASE_DIR}/${dir}" ]; then
    critical "Répertoire manquant : ${dir}"
  fi
done

[ -f "${BASE_DIR}/run.sh" ]           || critical "Fichier manquant : run.sh"
[ -f "${BASE_DIR}/global.conf" ]      || critical "Fichier manquant : global.conf"
[ -f "${BASE_DIR}/wp/wp-config.template.php" ] || critical "wp-config.template.php manquant"
[ -f "${BASE_DIR}/scripts/download_wordpress.sh" ] || critical "download_wordpress.sh manquant"

if [ ! -f "${BASE_DIR}/env.example" ]; then
  warning "env.example absent – non bloquant"
fi

info "Vérification des dépendances système..."

if ! command -v docker >/dev/null 2>&1; then
  critical "Docker n est pas installé"
fi

if command -v docker >/dev/null 2>&1; then
  info "Docker version détectée : $(docker --version)"
fi

if ! docker info >/dev/null 2>&1; then
  critical "Docker daemon inaccessible"
fi

if ! command -v curl >/dev/null 2>&1; then
  critical "curl n est pas installé"
fi

info "Vérification des ports 80 et 443..."
for port in 80 443; do
  if ss -lnt "( sport = :${port} )" | grep -q LISTEN; then
    warning "Port ${port} déjà utilisé"
  fi
done

info "Vérification de la configuration Traefik..."
[ -f "${BASE_DIR}/traefik/traefik.yml" ] || critical "traefik/traefik.yml manquant"

if [ ! -d "${BASE_DIR}/traefik/dynamic" ]; then
  critical "Répertoire traefik/dynamic manquant"
else
  if [ ! -f "${BASE_DIR}/traefik/dynamic/wordpress.yml" ]; then
    warning "traefik/dynamic/wordpress.yml manquant (Traefik démarrera mais ne routera pas vers WordPress)"
  fi
fi

info "Vérification du slot courant..."
if [ ! -f "${BASE_DIR}/current_slot" ]; then
  echo "blue" > "${BASE_DIR}/current_slot"
  warning "Fichier current_slot manquant, définition blue"
fi

SLOT="$(tr -d ' \n\r' < "${BASE_DIR}/current_slot" || echo "blue")"
if [ "${SLOT}" != "blue" ] && [ "${SLOT}" != "green" ]; then
  echo "blue" > "${BASE_DIR}/current_slot"
  warning "Slot courant invalide, reset à blue"
fi

echo "------------------------------------------------------------"
echo " Résultat PREFLIGHT"
echo "   Erreurs critiques : ${ERRORS}"
echo "   Warnings          : ${WARNINGS}"
echo "------------------------------------------------------------"

if [ "${ERRORS}" -gt 0 ]; then
  echo "[FATAL] Le preflight a détecté des erreurs critiques."
  echo "        Arrêt immédiat de l installation."
  exit 1
fi

echo "[OK] Preflight terminé avec succès."
