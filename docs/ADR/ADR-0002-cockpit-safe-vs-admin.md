# ADR-0002 — Cockpit Safe vs Admin

## Statut
ACCEPTÉ

---

## Contexte
Le produit BlueGreen Orchestrator ZIP expose des capacités sensibles
(déploiement, rollback, bascule Blue/Green).
Une interface cockpit est souhaitée, y compris pour des clients finaux.

Sans séparation stricte des droits, un cockpit représente un risque majeur.

---

## Décision
Le cockpit est scindé en **deux modes exclusifs** :
- `safe`
- `admin`

Aucun autre mode n’est autorisé.

---

## Mode SAFE (client final)

Objectif :
- visibilité
- audit
- déclenchement contrôlé

Caractéristiques :
- lecture seule par défaut
- actions limitées à des commandes **non destructives**
- aucune modification de configuration
- aucune écriture système

Exemples autorisés :
- état Blue / Green
- dernière release
- logs
- dry-run
- rollback simulé

---

## Mode ADMIN (opérateur)

Objectif :
- exploitation
- maintenance
- incident

Caractéristiques :
- accès complet aux commandes
- exécution réelle possible
- réservé à l’opérateur
- jamais exposé publiquement

---

## Règles de sécurité
- `safe` obligatoire pour toute exposition client
- `admin` jamais exposé sur Internet
- le cockpit ne contient aucune logique métier
- le cockpit déclenche uniquement des scripts existants

---

## Conséquences
- réduction du risque client
- cockpit vendable comme valeur ajoutée
- conformité avec ADR-0001

---

## Date
2026-01-15

