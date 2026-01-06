#!/bin/bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "green" > "${BASE_DIR}/current_slot"
echo "[OK] Slot GREEN activé"
