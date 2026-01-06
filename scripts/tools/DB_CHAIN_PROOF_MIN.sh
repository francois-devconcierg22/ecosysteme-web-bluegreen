#!/bin/bash
set -euo pipefail

ROOT="/home/adminso/bluegreen_v7_dev"
ENV_FILE="$ROOT/.env"
OUT="$ROOT/DB_CHAIN_PROOF_MIN_$(date +%Y%m%d_%H%M%S).txt"

echo "=== DB CHAIN PROOF (MINIMAL) ===" | tee "$OUT"
echo "DATE : $(date)" | tee -a "$OUT"
echo "ROOT : $ROOT" | tee -a "$OUT"
echo "ENV  : $ENV_FILE" | tee -a "$OUT"
echo | tee -a "$OUT"

echo "--- .env content (DB vars only) ---" | tee -a "$OUT"
grep -E '^(WORDPRESS_DB_|MYSQL_)' "$ENV_FILE" \
  | sed -E 's/(PASSWORD=).*/\1<masked>/' \
  | tee -a "$OUT"
echo | tee -a "$OUT"

echo "--- Docker env : wp-blue ---" | tee -a "$OUT"
docker inspect wp-blue --format '{{range .Config.Env}}{{println .}}{{end}}' \
  | grep -E '^(WORDPRESS_DB_|MYSQL_)' \
  | sed -E 's/(PASSWORD=).*/\1<masked>/' \
  | tee -a "$OUT"
echo | tee -a "$OUT"

echo "--- wp-config.php (wp-blue) ---" | tee -a "$OUT"
docker exec wp-blue sh -c \
  "grep -E 'DB_NAME|DB_USER|DB_PASSWORD|DB_HOST' /var/www/html/wp-config.php" \
  | tee -a "$OUT"

echo | tee -a "$OUT"
echo "--- MySQL auth test (WP user) ---" | tee -a "$OUT"

set -a
. "$ENV_FILE"
set +a

if docker exec bg-db mysql -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" \
  -e "SELECT 1;" "$WORDPRESS_DB_NAME" >/dev/null 2>&1; then
  echo "[OK] WP user can authenticate to MySQL" | tee -a "$OUT"
else
  echo "[FAIL] WP user cannot authenticate to MySQL" | tee -a "$OUT"
fi

echo "=== END ===" | tee -a "$OUT"
