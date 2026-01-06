# 03 — GLOBAL.CONF (SPÉCIFICATION CANONIQUE)

## Rôle
Centraliser **toutes les décisions structurantes**.

global.conf existe pour :
- éviter les décisions implicites
- permettre le multi-BlueGreen
- rendre les scripts stupides et sûrs

## Variables structurantes validées v6.7 (extrait)
- PROJECT_ID
- INSTALL_MODE
- DOMAIN_BLUE
- DOMAIN_GREEN
- DB_NAME
- DB_USER
- DB_PASSWORD

## Règle absolue
Toute variable hors global.conf est interdite.
