#!/bin/bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <url>"
  exit 1
fi

URL="$1"

HTTP_CODE=$(curl -k -o /dev/null -s -w "%{http_code}" "${URL}")

if [ "${HTTP_CODE}" -ge 200 ] && [ "${HTTP_CODE}" -lt 400 ]; then
  echo "[OK] ${URL} → HTTP ${HTTP_CODE}"
  exit 0
else
  echo "[CRITICAL] ${URL} → HTTP ${HTTP_CODE}"
  exit 1
fi
