#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(pwd)"
OUT_DIR="_env_audit"
REPORT="${OUT_DIR}/generator_audit_report.txt"

mkdir -p "${OUT_DIR}"

echo "==================================================" > "${REPORT}"
echo " AUDIT DES SCRIPTS GENERATEURS – BLUEGREEN" >> "${REPORT}"
echo " Racine : ${ROOT_DIR}" >> "${REPORT}"
echo " Date   : $(date)" >> "${REPORT}"
echo "==================================================" >> "${REPORT}"
echo >> "${REPORT}"

#############################################
# Analyse script par script
#############################################

find . -type f -name "*.sh" | sort | while read -r script; do
  issues=()

  # 1) Heredoc dynamique
  if grep -Eq 'cat\s+<<EOF' "$script"; then
    issues+=("HEREDOC_DYNAMIC → remplacer par écriture ligne par ligne (write_env)")
  fi

  # 2) source env_base.env
  if grep -Eq 'source .*env_base\.env' "$script"; then
    issues+=("SOURCE_TEMPLATE → env_base.env ne doit jamais être source")
  fi

  # 3) echo VAR=$VAR
  if grep -Eq 'echo\s+[A-Z0-9_]+=\\$[A-Z0-9_]+' "$script"; then
    issues+=("UNQUOTED_ENV_WRITE → utiliser quote_env / write_env")
  fi

  # 4) sed -i avec variables
  if grep -Eq 'sed\s+-i.*\\$[A-Z0-9_]+' "$script"; then
    issues+=("SED_DYNAMIC → vérifier échappement / quoting")
  fi

  # 5) envsubst
  if grep -Eq 'envsubst' "$script"; then
    issues+=("ENV_SUBST → usage à contrôler strictement")
  fi

  # Rapport
  echo "----------------------------------------------" >> "${REPORT}"
  echo "SCRIPT : ${script}" >> "${REPORT}"

  if [[ "${#issues[@]}" -eq 0 ]]; then
    echo "STATUT : OK (aucune action requise)" >> "${REPORT}"
  else
    echo "STATUT : A MODIFIER" >> "${REPORT}"
    for issue in "${issues[@]}"; do
      echo " - ${issue}" >> "${REPORT}"
    done
  fi

  echo >> "${REPORT}"

done

#############################################
# Résumé synthétique
#############################################

echo "==================================================" >> "${REPORT}"
echo " FIN DE L’AUDIT" >> "${REPORT}"
echo "==================================================" >> "${REPORT}"

echo
echo "[OK] Audit terminé."
echo "Rapport généré : ${REPORT}"
