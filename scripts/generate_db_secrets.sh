#!/usr/bin/env bash
set -euo pipefail

SECRETS="/home/adminso/bluegreen_v7_dev/tmp/db_secrets.env"

echo "[SECRETS] Génération db_secrets.env (v7)"

DB_NAME="wordpress"
DB_USER="wp_user"
DB_PASSWORD="$(openssl rand -hex 12)"
MYSQL_ROOT_PASSWORD="$(openssl rand -hex 24)"

printf "%s\n" \
"DB_NAME=$DB_NAME" \
"DB_USER=$DB_USER" \
"DB_PASSWORD=$DB_PASSWORD" \
"MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD" \
> "$SECRETS"

chmod 600 "$SECRETS"

echo "[SECRETS] OK — secrets complets générés"
