#!/usr/bin/env bash
set -euo pipefail

fatal() { echo "[FATAL] $*" >&2; exit 1; }

# Charger la conf (déjà résolue par run.sh)
: "${PROJECT_INSTALL_PROFILE:?}"
: "${ENABLE_WORDPRESS:?}"
: "${WP_AUTO_INSTALL:?}"
: "${ENABLE_TLS:?}"
: "${BLUEGREEN_ENABLED:?}"

############################################
# ENUM VALIDATIONS
############################################

case "$PROJECT_INSTALL_PROFILE" in
  infra_only|infra_wp|full|backup|update) ;;
  *) fatal "PROJECT_INSTALL_PROFILE invalide: $PROJECT_INSTALL_PROFILE" ;;
esac

case "$ENABLE_TLS" in true|false) ;; *) fatal "ENABLE_TLS invalide";; esac
case "$ENABLE_WORDPRESS" in true|false) ;; *) fatal "ENABLE_WORDPRESS invalide";; esac
case "$WP_AUTO_INSTALL" in true|false) ;; *) fatal "WP_AUTO_INSTALL invalide";; esac
case "$WP_DEBUG" in true|false) ;; *) fatal "WP_DEBUG invalide";; esac
case "$DEBUG_INTERACTIVE" in true|false) ;; *) fatal "DEBUG_INTERACTIVE invalide";; esac
case "$ENABLE_BACKUPS" in true|false) ;; *) fatal "ENABLE_BACKUPS invalide";; esac
case "$BLUEGREEN_ENABLED" in true|false) ;; *) fatal "BLUEGREEN_ENABLED invalide";; esac

case "$DEFAULT_ACTIVE_SLOT" in blue|green) ;; *) fatal "DEFAULT_ACTIVE_SLOT invalide";; esac
case "$DB_ENGINE" in mysql|mariadb) ;; *) fatal "DB_ENGINE invalide";; esac
case "$WP_ENV" in production|staging|development) ;; *) fatal "WP_ENV invalide";; esac

############################################
# COHERENCE RULES
############################################

if [[ "$PROJECT_INSTALL_PROFILE" == "infra_only" && "$WP_AUTO_INSTALL" == "true" ]]; then
  fatal "WP_AUTO_INSTALL interdit en infra_only"
fi

if [[ "$WP_AUTO_INSTALL" == "true" && "$PROJECT_INSTALL_PROFILE" != "full" ]]; then
  fatal "WP_AUTO_INSTALL autorisé uniquement en mode full"
fi

if [[ "$ENABLE_WORDPRESS" == "false" && "$PROJECT_INSTALL_PROFILE" =~ ^(infra_wp|full)$ ]]; then
  fatal "ENABLE_WORDPRESS=false incompatible avec $PROJECT_INSTALL_PROFILE"
fi

echo "[OK] global.conf valide"
