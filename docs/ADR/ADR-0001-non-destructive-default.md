# ADR-0001 — Non-Destructive Default

## Statut
ACCEPTÉ

---

## Contexte

Les itérations précédentes du projet BlueGreen (notamment les tentatives v7)
ont mis en évidence un risque critique :  
des scripts d’installation ou de maintenance pouvaient effectuer des actions
destructrices implicites (nettoyage serveur trop large, suppression de
répertoires non ciblés, modification de zones sensibles).

Ces incidents ont démontré que :
- la puissance des scripts n’était pas suffisamment bornée,
- l’absence de verrou explicite permettait des comportements dangereux,
- l’état du serveur ne devait **jamais** être supposé.

---

## Problème

Un orchestrateur ZIP capable d’installer, mettre à jour ou maintenir
des environnements Blue/Green ne peut pas se permettre :
- d’interpréter l’environnement,
- de “faire le ménage” de manière implicite,
- de modifier des zones hors périmètre projet.

Sans règle stricte, le risque est :
- perte d’accès serveur,
- indisponibilité client,
- impossibilité de rollback,
- perte de confiance produit.

---

## Décision

Le projet adopte le principe fondamental suivant :

> **Toute action est NON-DESTRUCTIVE par défaut.**

Cela implique que **rien n’est supprimé, modifié ou écrasé**
sans une intention explicite, vérifiable et traçable.

---

## Règles découlant de la décision

### 1. DRY_RUN par défaut

- Toute action doit être simulable.
- Aucune action réelle ne doit s’exécuter sans un DRY_RUN préalable.
- Le DRY_RUN doit décrire précisément :
  - les ressources impactées,
  - les fichiers modifiés,
  - les services concernés.

---

### 2. INSTALL_MODE obligatoire (verrou dur)

Toute exécution du BlueGreen Orchestrator ZIP exige un mode explicite.

Valeurs autorisées :
- `SERVER_NEUF`
- `PROJET_UNIQUE`
- `MULTI_PROJETS`

Comportement :
- `INSTALL_MODE` absent → **STOP immédiat (exit 42)**
- `INSTALL_MODE` invalide → **STOP immédiat (exit 42)**

Aucun comportement par défaut n’est autorisé.

---

### 3. Périmètre strict d’exécution

Les scripts ont le droit d’agir uniquement sur :
- le répertoire projet courant,
- les volumes explicitement déclarés,
- les réseaux Docker explicitement déclarés.

Il est **formellement interdit** de toucher à :
- `/home`
- `~/.ssh`
- `/etc/ssh`
- firewall (ufw, iptables)
- Docker global (prune, rm non ciblé)

---

### 4. Aucun nettoyage implicite

- Le ménage serveur n’est **pas un comportement par défaut**.
- Le ménage est une **capacité optionnelle**, activée uniquement :
  - par un script dédié,
  - avec un mode explicite,
  - documenté.

---

## Conséquences

### Conséquences positives
- Comportement prévisible et auditable
- Réduction drastique du risque serveur
- Confiance accrue des clients et partenaires
- Compatibilité multi-projets

### Contraintes acceptées
- Certaines opérations nécessitent plus de confirmations
- Discipline plus stricte côté implémentation
- Refus de raccourcis techniques dangereux

---

## Alternatives envisagées et rejetées

### Auto-détection de l’état serveur
❌ Rejetée — non déterministe, fragile, non auditable

### Nettoyage serveur conditionnel
❌ Rejetée — périmètre impossible à garantir à 100 %

---

## Lien avec les documents normatifs

Cette ADR est obligatoire pour respecter :
- `docs/PRD_BLUEGREEN_ORCHESTRATOR_ZIP.md`
- `docs/02_NORMES_ET_CONVENTIONS.md`
- `docs/05_AGENT_GUIDE.md`

Toute implémentation qui la contredit est invalide.

---

## Date
2026-01-15

## Auteur
Product Owner — BlueGreen Core

