#!/usr/bin/env bash
set -euo pipefail

fatal() { echo "[FATAL] $*" >&2; exit 1; }
info() { echo "[INFO] $*"; }

info "Preflight GLOBAL — infra uniquement"

command -v docker >/dev/null || fatal "Docker non installé"

docker version >/dev/null || fatal "Docker non fonctionnel"

for port in 80 443; do
  if ss -lnt | awk '{print $4}' | grep -q ":$port$"; then
    info "Port $port occupé (OK si Traefik)"
  fi
done

info "Preflight GLOBAL OK"
