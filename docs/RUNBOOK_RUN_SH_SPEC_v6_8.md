# RUNBOOK — Spécification de run.sh (Entrypoint Unique)

## Rôle
Ce document spécifie le comportement **normatif et opposable** du script `run.sh`,
unique point d’entrée du BlueGreen Orchestrator ZIP.

Aucun autre script ne doit être exécuté directement.

---

## Principes non négociables
- Un seul entrypoint : `run.sh`
- Aucun script autonome
- Aucune détection implicite
- Aucune action destructive par défaut
- Tout passe par configuration + validation

---

## Ordre d’exécution obligatoire

1. Chargement de `global.conf`
2. Validation des invariants globaux
3. Validation de `INSTALL_MODE`
4. Chargement de `site.conf`
5. Validation du profil et des modules
6. Application du DRY_RUN
7. Dispatch des modules
8. Reporting & exit code

---

## Commandes supportées

```bash
./run.sh dry-run
./run.sh apply
./run.sh rollback
./run.sh status
```

Toute autre commande → **exit 64 (usage error)**.

---

## Étape 1 — Chargement de global.conf

```bash
source ./global.conf
```

Vérifications :
- fichier présent
- variables requises définies
- aucune variable inconnue

Erreur → **exit 42**

---

## Étape 2 — Validation INSTALL_MODE

Valeurs autorisées :
- SERVER_NEUF
- PROJET_UNIQUE
- MULTI_PROJETS

Si absent ou invalide → **exit 42**

---

## Étape 3 — Chargement site.conf

```bash
source ./sites/$SITE_KEY/site.conf
```

Vérifications :
- SITE_KEY défini
- fichier présent
- PROFILE valide
- MODULES_ENABLED cohérents avec GLOBAL_CAPABILITIES

Erreur → **exit 65**

---

## Étape 4 — DRY_RUN

Règles :
- DRY_RUN actif par défaut
- `apply` désactive explicitement le DRY_RUN
- `dry-run` force DRY_RUN

Variable finale :
```bash
EFFECTIVE_DRY_RUN=true|false
```

---

## Étape 5 — Dispatch des modules

Pour chaque module activé :
```bash
scripts/<module>/run.sh
```

Chaque module :
- reçoit EFFECTIVE_DRY_RUN
- n’a aucun accès global
- ne peut appeler d’autres modules

---

## Étape 6 — Rollback

Commande :
```bash
./run.sh rollback
```

Conditions :
- uniquement si un état précédent existe
- jamais automatique
- toujours journalisé

---

## Étape 7 — Reporting

À la fin :
- résumé des actions
- état Blue / Green
- logs horodatés

---

## Exit codes normalisés

| Code | Signification |
|----|-------------|
| 0  | Succès |
| 42 | Violation de règle / sécurité |
| 64 | Mauvaise commande |
| 65 | Configuration invalide |
| 70 | Erreur interne |

---

## Interdictions formelles

`run.sh` ne doit jamais :
- modifier `/home`, `/root`, `~/.ssh`, `/etc/ssh`
- appeler `docker system prune`
- deviner l’état du serveur
- exécuter un script non référencé

---

## Lien documentaire
- ADR-0001 (Non-destructive default)
- ADR-0002 (Cockpit safe vs admin)
- 03_GLOBAL_CONF_SPEC.md
- 03_SITE_CONF_SPEC.md

---

## Principe final

> Si ce comportement n’est pas décrit ici,
> alors `run.sh` n’a pas le droit de le faire.

