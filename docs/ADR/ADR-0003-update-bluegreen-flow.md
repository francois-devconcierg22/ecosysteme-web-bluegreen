# ADR-0003 — Update Recette ⇄ Prod (Blue/Green Flow)

## Statut
ACCEPTÉ

---

## Contexte

Le produit BlueGreen Orchestrator ZIP doit permettre :
- des mises à jour **sans interruption de service**,
- des bascules contrôlées **recette → production**,
- des retours arrière **production → recette**,
- une traçabilité complète des actions.

Les itérations précédentes ont montré que des bascules non formalisées
entraînent des risques de régression, d’indisponibilité et de perte de confiance.

---

## Décision

Le flux de mise à jour Blue/Green est **formalisé et verrouillé**.
Aucune bascule implicite n’est autorisée.

Le produit distingue explicitement :
- **Recette (Green)** : environnement de validation
- **Production (Blue)** : environnement exposé

La bascule est une **action explicite**, traçable et réversible.

---

## Définitions

- **Blue** : environnement actuellement en production
- **Green** : environnement de recette / candidat
- **Bascule** : changement de routage Traefik
- **Rollback** : retour à l’état Blue précédent

---

## Règles fondamentales

1. **Pas de déploiement direct en production**
2. Toute mise à jour passe par la recette (Green)
3. La production (Blue) reste intacte jusqu’à validation
4. Une seule bascule à la fois
5. Toute bascule est journalisée

---

## Flux Recette → Production

### Étape 1 — Déploiement en recette (Green)
- Build / update effectué uniquement sur Green
- Aucun impact utilisateur
- DRY_RUN possible

### Étape 2 — Validation
- Tests applicatifs
- Vérification logs
- Vérification santé (HTTP, services)

### Étape 3 — Bascule explicite
- Action manuelle via :
  - `./run.sh apply`
  - ou cockpit (mode admin)
- Mise à jour du routage Traefik
- Aucun redémarrage global

---

## Flux Production → Recette (Rollback)

### Conditions
- Incident détecté
- Régression fonctionnelle
- Décision opérateur

### Procédure
- Exécution explicite :
  ```bash
  ./run.sh rollback
  ```
- Restauration du routage précédent
- Journalisation obligatoire

---

## Sécurité et traçabilité

- Aucune bascule automatique
- Aucune bascule déclenchée par un module
- Seul `run.sh` peut effectuer la bascule
- Logs horodatés et persistants

---

## Conséquences

### Avantages
- Zéro downtime
- Réversibilité garantie
- Exploitation maîtrisée
- Argument commercial fort

### Contraintes
- Discipline opérateur requise
- Validation obligatoire avant bascule

---

## Lien documentaire

- ADR-0001 — Non-destructive default
- ADR-0002 — Cockpit safe vs admin
- RUNBOOK_RUN_SH_SPEC_v6_8.md
- 03_GLOBAL_CONF_SPEC.md
- 03_SITE_CONF_SPEC.md

---

## Date
2026-01-15

## Auteur
Product Owner — BlueGreen Core

