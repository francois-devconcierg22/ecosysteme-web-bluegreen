#!/bin/bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "blue" > "${BASE_DIR}/current_slot"
echo "[OK] Slot BLUE activé"
