# 03 — GLOBAL.CONF SPECIFICATION (CANONIQUE)

## Rôle
Spécifier la liste des variables autorisées. Tout comportement structurant doit être piloté par `global.conf`.

---

## Variables structurantes minimales
### Identité / isolation
- `PROJECT_ID` (string) : clé primaire universelle

### Modes / gouvernance
- `INSTALL_MODE` (enum) : `SERVER_NEUF | PROJET_UNIQUE | MULTI_PROJETS`

### Domaines / routage (exemples)
- `DOMAIN_BLUE` (string)
- `DOMAIN_GREEN` (string)
- Préfixe préprod : **`test`** (ex : `test.example.com`)

---

## Règles
- Toute variable ajoutée doit être :
  - déclarée ici
  - documentée (type, rôle, impact)
  - référencée dans le changelog

---

## Extrait recommandé (global.conf)
```conf
# =========================
# IDENTITÉ PROJET
# =========================
PROJECT_ID="conciergerie"

# =========================
# MODE D'INSTALLATION
# =========================
INSTALL_MODE="PROJET_UNIQUE"   # SERVER_NEUF | PROJET_UNIQUE | MULTI_PROJETS

# =========================
# DOMAINES
# =========================
DOMAIN_BLUE="example.com"
DOMAIN_GREEN="test.example.com"
---

## INSTALL_MODE — Verrou d’exécution destructif

```ini
INSTALL_MODE="SERVER_NEUF"   # SERVER_NEUF | PROJET_UNIQUE | MULTI_PROJETS
PROJECT_ID="exemple"

Cette variable conditionne **toute action destructrice** du socle BlueGreen.

### Règle absolue

- `global.conf` est la **seule source de vérité**
- Aucun script n’a le droit :
  - d’inférer un mode
  - d’en inventer un
  - de contourner cette variable

### Comportement obligatoire

- Si `INSTALL_MODE` est **absent** → arrêt immédiat (`exit 42`)
- Si `INSTALL_MODE` est **invalide** → arrêt immédiat (`exit 42`)
- Toute action destructrice sans validation explicite du mode est **interdite**

### Statut

Cette règle est **bloquante, non négociable et opposable**.  
Tout script qui ne la respecte pas est considéré comme **invalide**.
