#!/bin/bash
set -e
BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
sudo chown -R adminso:adminso "$BASE_DIR"
sudo chmod -R 755 "$BASE_DIR"
