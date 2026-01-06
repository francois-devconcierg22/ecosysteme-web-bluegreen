#!/bin/bash
set -euo pipefail

HOME_DIR="${HOME}"
KEEP_ZIP="bluegreen_v6_3_5.zip"
ARCHIVE="${HOME_DIR}/archive"
TS=$(date +"%Y-%m-%d_%H-%M-%S")
DEST="${ARCHIVE}/root_cleanup_${TS}"

mkdir -p "${DEST}"

echo "============================================================"
echo "  BLUE/GREEN – SAFE ROOT CLEANUP"
echo "============================================================"
echo "Home   : ${HOME_DIR}"
echo "Keep   : ${KEEP_ZIP}"
echo "Target : ${DEST}"
echo "------------------------------------------------------------"

# NE PAS toucher aux fichiers cachés (.ssh, .config, .docker, etc.)
for item in "${HOME_DIR}"/*; do
    [ -e "$item" ] || continue
    name="$(basename "$item")"

    case "$name" in
        "${KEEP_ZIP}" | "archive")
            continue
            ;;
        *)
            mv "$item" "${DEST}/" && \
              echo "[MOVE] ${name} -> ${DEST}" || \
              echo "[WARN] Impossible de déplacer ${name}"
            ;;
    esac
done

echo "------------------------------------------------------------"
echo "[OK] Cleanup terminé."
echo "État final du HOME :"
ls -al "${HOME_DIR}"
echo "------------------------------------------------------------"
echo "Contenu de l'archive :"
ls -al "${DEST}"
echo "============================================================"

