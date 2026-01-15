# PRD — BlueGreen Orchestrator ZIP

## 1. Objectif Produit

BlueGreen Orchestrator ZIP est un orchestrateur d’infrastructure et de déploiement
basé sur le principe Blue/Green, livrable sous forme de ZIP installable,
permettant d’activer des capacités techniques modulaires selon l’offre vendue
au client.

Le produit vise :
- la **fiabilité opérationnelle** (zéro downtime, rollback immédiat),
- la **sécurité** (aucune action destructive implicite),
- la **traçabilité complète** (audit, logs, historique),
- la **rentabilité** (un ZIP unique, plusieurs offres commerciales).

Le ZIP n’est pas la source de vérité.
La source de vérité est la **documentation versionnée**.

---

## 2. Problème à Résoudre

Les développeurs, agences et entrepreneurs rencontrent les problèmes suivants :

- peur de casser un site en production,
- absence de rollback simple et rapide,
- scripts artisanaux non traçables,
- installations dépendantes de l’état du serveur,
- maintenance coûteuse et non standardisée,
- difficulté à proposer une offre “pro” à leurs clients finaux.

---

## 3. Cibles Produit

### 3.1 Cible primaire
- Freelances
- Agences web
- Entrepreneurs techniques

### 3.2 Cible secondaire
- Clients finaux (via cockpit en mode safe / read-only)

---

## 4. Principe Fondamental du Produit

> **Un seul ZIP, plusieurs produits.**

Le ZIP contient :
- un **socle obligatoire**,
- des **modules activables**,
- des **profils d’installation**.

Le comportement du ZIP est **strictement déterminé par configuration**
(`INSTALL_MODE`, `PROFILE`, `MODULES_ENABLED`).

---

## 5. Périmètre Fonctionnel (IN)

### 5.1 Socle obligatoire (toujours actif)

Le socle BlueGreen est toujours présent, quelle que soit l’offre vendue.

Fonctionnalités :
- Infrastructure Docker
- Blue/Green applicatif
- Bascule contrôlée
- Rollback immédiat
- HTTPS automatique (Traefik / Let’s Encrypt)
- Logs techniques
- Traçabilité des actions
- DRY_RUN par défaut
- INSTALL_MODE obligatoire

Aucun CMS n’est imposé par le socle.

---

### 5.2 Audit & DRY-RUN (clarification)

#### Objectif
Permettre de **voir exactement ce qui va se passer avant toute action réelle**.

#### Portée
- Audit **du périmètre projet**, pas du serveur global
- Audit **de l’installation ou de l’action demandée**

#### Exemples d’audit :
- “Quels volumes vont être créés ?”
- “Quels services Docker vont être lancés ?”
- “Quels fichiers vont être modifiés dans le projet ?”
- “Quel environnement sera actif après la bascule ?”

#### Exclusions
- Pas d’audit de sécurité serveur
- Pas d’audit OS global
- Pas d’audit de conformité réglementaire

---

### 5.3 Logs & traçabilité

Fonctionnalités :
- Journalisation horodatée des actions
- Historique des bascules Blue/Green
- Historique des installations et mises à jour
- Corrélation action ↔ résultat

Les logs sont :
- lisibles par un humain,
- exploitables par un cockpit,
- non destructifs.

---

### 5.4 Mode “Read-Only / Safe”

Fonctionnalité clé pour clients finaux.

Caractéristiques :
- consultation de l’état Blue/Green,
- visualisation des logs,
- visualisation de l’environnement actif,
- audit des actions possibles,

Restrictions :
- aucune action destructive,
- aucune bascule,
- aucun déploiement.

Le mode safe est **obligatoire** pour toute exposition client.

---

## 6. Cockpit (Surcouche UI)

### 6.1 Objectif
Fournir une interface minimale au-dessus des scripts existants.

### 6.2 Règles
- Le cockpit **n’exécute rien directement**.
- Il déclenche des commandes existantes.
- Il respecte strictement le mode (safe / admin).

### 6.3 Fonctionnalités minimales
- état Blue ou Green actif,
- bouton bascule (admin only),
- visualisation des logs,
- audit des actions (dry-run),
- verrouillage par rôle.

---

## 7. Modules Optionnels (activables)

### 7.1 Module WordPress

Statut :
- inclus dans le ZIP
- **désactivé par défaut**

Activation via :
- `MODE=WORDPRESS`
- ou profil d’installation

Fonctionnalités :
- installation WordPress
- intégration Blue/Green
- gestion DB et volumes
- compatible rollback

---

### 7.2 Plugins WordPress standards

Objectif :
- réduire le temps de paramétrage
- standardiser les projets

Caractéristiques :
- plugins gratuits
- populaires
- figés et versionnés
- documentés

Aucun plugin arbitraire client n’est autorisé par défaut.

---

### 7.3 Plugins “landing page standard”

Objectif :
- permettre la création industrielle de landing pages

Inclus :
- formulaires
- briques indispensables à une landing standard

Exclusions :
- plugins métier spécifiques
- plugins payants client

---

## 8. Hors Périmètre (OUT)

Le BlueGreen Orchestrator ZIP ne fait jamais :

- import CSV générique
- nettoyage serveur global
- modification SSH
- modification firewall
- installation de plugins arbitraires client
- logique marketing avancée
- paiement Stripe direct (ZIP séparé)

---

## 9. ZIP Séparé — Landing Page Business

La landing page avec :
- FluentForms
- Stripe
- tunnel de vente

fait l’objet :
- d’un **ZIP distinct**
- d’une **offre commerciale distincte**
- d’un cycle de maintenance séparé

---

## 10. Architecture Conceptuelle du ZIP

orchestrator.zip
├── core/
│ ├── infra
│ ├── bluegreen
│ ├── rollback
│ ├── audit
│ ├── logs
│ └── safe-mode
│
├── modules/
│ ├── wordpress
│ ├── wp-plugins-standard
│ ├── cockpit
│
├── profiles/
│ ├── infra-only.conf
│ ├── pro.conf
│ ├── wordpress.conf
│
└── run.sh

---

## 11. Exigences Non Fonctionnelles

### Sécurité
- DRY_RUN par défaut
- INSTALL_MODE obligatoire
- périmètre strict projet
- aucune action silencieuse

### Fiabilité
- idempotence des scripts
- rollback documenté
- comportement déterministe

### Traçabilité
- logs persistants
- audits écrits
- documentation à jour

---

## 12. Critères d’Acceptation (Definition of Done)

Une version est valide si :
- le PRD est respecté,
- le socle fonctionne sans module,
- chaque module est activable indépendamment,
- le mode safe empêche toute action destructive,
- un audit précède toute action réelle,
- la documentation est alignée.

---

## 13. Règles d’Interprétation pour l’IA

- Le PRD prime sur tout autre document.
- En cas d’ambiguïté → STOP et question.
- Aucune hypothèse implicite n’est autorisée.
- Toute décision nouvelle exige un ADR.

---

## 14. Trajectoire Produit

- v6.7 : infra-only stable
- v6.8 : sécurisation + audit + DRY_RUN
- v6.9 : cockpit + modules
- v7.x : stabilisation produit
- v8.x : multi-stacks + Traefik shared

