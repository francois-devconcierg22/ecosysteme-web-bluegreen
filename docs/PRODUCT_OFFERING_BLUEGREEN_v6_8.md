# PRODUCT OFFERING — BlueGreen Orchestrator v6.8

## Objectif du document
Définir un **découpage clair, vendable et évolutif** des offres commerciales
basées sur le produit BlueGreen Orchestrator ZIP.

Ce document fait le lien entre :
- les capacités techniques (ADR, runbooks, modules),
- les besoins clients,
- la stratégie de monétisation.

---

## Principes commerciaux structurants

1. Le produit est **modulaire**
2. Chaque offre correspond à un **périmètre maîtrisé**
3. Aucune offre n’expose un risque client
4. Les upsells sont **naturels et progressifs**
5. La valeur est lisible sans jargon technique

---

## Vue d’ensemble des offres

| Offre | Cible | Risque | Objectif |
|-----|------|-------|---------|
| Infra-Only | TPE / site vitrine | Très faible | Socle fiable |
| Infra + Cockpit SAFE | Clients finaux | Faible | Transparence |
| Blue/Green Complet | PME / agences | Moyen maîtrisé | Zéro downtime |
| Sécurité & Backup | Clients exigeants | Très faible | Sérénité |
| WordPress Industrialisé | Entrepreneurs | Moyen | Gain de temps |
| Landing & Paiement | Vente directe | Faible | Conversion |

---

## Offre 1 — Infra-Only (Socle)

### Contenu
- Orchestrateur ZIP
- Traefik + HTTPS
- DRY_RUN par défaut
- Logs & audit
- RUNBOOK infra-only

### Inclus
- Installation
- Validation
- Documentation

### Exclu
- WordPress
- Blue/Green applicatif
- Cockpit ADMIN

### Valeur client
> “Un serveur propre, sécurisé, prêt pour évoluer.”

---

## Offre 2 — Infra + Cockpit SAFE

### Contenu
- Offre Infra-Only
- Cockpit SAFE
- Accès lecture + dry-run
- Logs visibles client

### Valeur client
> “Je vois ce qui se passe, sans pouvoir casser.”

---

## Offre 3 — Blue/Green Complet

### Contenu
- Deux environnements (Blue / Green)
- Bascule sans downtime
- Rollback explicite
- Cockpit ADMIN (opérateur)
- ADR-0003 appliquée

### Valeur client
> “Je mets à jour sans stress, sans coupure.”

---

## Offre 4 — Sécurité & Backup

### Contenu
- Backup volumes / DB
- Restore ciblé
- Manifeste & traçabilité
- RUNBOOK backup/restore

### Valeur client
> “Je peux revenir en arrière à tout moment.”

---

## Offre 5 — WordPress Industrialisé

### Contenu
- Installation WordPress
- Plugins standards (SEO, cache, sécurité, forms)
- Intégration Blue/Green
- Documentation d’usage

### Valeur client
> “Un WordPress prêt à l’emploi, propre et maintenable.”

---

## Offre 6 — Landing Page & Paiement

### Contenu
- Landing page standardisée
- FluentForms
- Stripe
- Parcours de paiement

### Valeur client
> “Je vends immédiatement, sans bricolage.”

---

## Upsells naturels

- Passage SAFE → ADMIN
- Activation Blue/Green
- Ajout backup
- Ajout WordPress
- Ajout landing

---

## Ce que le produit ne vend PAS

- Hébergement mutualisé
- Développement spécifique non cadré
- Accès root client
- Maintenance implicite

---

## Alignement documentaire

Chaque offre s’appuie sur :
- PRD BlueGreen Orchestrator ZIP
- ADR-0001 → ADR-0005
- RUNBOOKs correspondants
- GLOBAL / SITE conf

---

## Principe final

> Le client achète une **capacité maîtrisée**,  
> pas une complexité technique.

Ce découpage garantit :
- sécurité
- lisibilité
- rentabilité
- évolutivité produit

