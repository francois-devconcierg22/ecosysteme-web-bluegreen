# RUNBOOK — Installation Infra-Only v6.8

## Objectif
Installer le socle BlueGreen **sans WordPress**,
sans toucher aux données existantes,
en respectant la non-destructivité par défaut.

---

## Pré-requis
- Serveur Linux (Ubuntu recommandé)
- Docker + Docker Compose
- Accès SSH opérateur

---

## Étape 1 — Préparation

```bash
cd /srv
mkdir -p bluegreen
cd bluegreen
```

---

## Étape 2 — Déploiement du ZIP

```bash
unzip bluegreen-orchestrator-v6.8.zip
cd bluegreen-orchestrator
```

---

## Étape 3 — Configuration globale

Créer `global.conf` :

```conf
PROJECT_ID="infra-demo"
INSTALL_MODE="PROJET_UNIQUE"
GLOBAL_DRY_RUN_DEFAULT="true"
```

---

## Étape 4 — Configuration site

```conf
SITE_KEY="infra-demo"
SITE_DOMAIN="example.com"
PROFILE="infra-only"

MODULES_ENABLED=(
  "infra"
  "audit"
  "logs"
)
```

---

## Étape 5 — Dry-run obligatoire

```bash
./run.sh dry-run
```

Vérifier :
- aucune suppression
- aucune écriture système
- logs conformes

---

## Étape 6 — Exécution réelle (si validé)

```bash
./run.sh apply
```

---

## Validation finale
- Traefik actif
- Routes Blue/Green visibles
- Logs disponibles
- Cockpit en mode SAFE

---

## Rollback
```bash
./run.sh rollback
```

