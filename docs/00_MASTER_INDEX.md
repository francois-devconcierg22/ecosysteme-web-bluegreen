# 00 — MASTER INDEX (SOURCE DE VÉRITÉ)

> ⚠️ Ce document est le point d’entrée unique de la documentation.
> Le ZIP est un artefact de livraison.
> La vérité du projet réside exclusivement dans la documentation versionnée.

---

## Rôle du document

Ce fichier définit :
- la hiérarchie documentaire officielle,
- les règles d’usage de la documentation,
- les verrous méthodologiques du projet.

Toute décision structurante doit être traçable :
1. ici (référence),
2. dans un document normatif associé (ADR, PRD, etc.).

---

## État actuel du produit

- **Version de référence validée** : v6.7  
  → statut : **infra-only stable**
- **Doctrine actuelle** : mono-stack propre  
  → 1 serveur = 1 Blue/Green = 1 projet
- **Trajectoire produit** :  
  v6.8 / v6.9 → stabilisation & sécurisation  
  v8 → **multi-stacks (N projets + 1 Traefik shared)**

---

## Décisions structurantes actées (résumé exécutif)

### A. Ménage / Nettoyage

- Le ménage est une **capacité**, jamais un comportement par défaut.
- **Interdit** : ménage serveur implicite au lancement d’un script.
- **Obligatoire** : ménage explicite, isolé, via scripts dédiés.

---

### B. INSTALL_MODE (verrou non contournable)

Toute action potentiellement destructive exige un mode explicite :

Valeurs autorisées :
- `SERVER_NEUF`
- `PROJET_UNIQUE`
- `MULTI_PROJETS`

Si `INSTALL_MODE` est absent ou invalide → **STOP immédiat (exit 42)**.

---

### C. SSH (clarification)

- La préparation SSH peut exister dans le ZIP.
- Le problème historique v7 provenait du **périmètre de nettoyage**, pas du SSH.
- **Interdiction absolue** de toucher à :
  - `/home`
  - `~/.ssh`
  - `/etc/ssh`

---

## Ordre de lecture obligatoire (humains & IA)

1. `02_NORMES_ET_CONVENTIONS.md`
2. `01_ARCHITECTURE.md`
3. `03_GLOBAL_CONF_SPEC.md`
4. `05_AGENT_GUIDE.md`
5. `06_RELEASE_PROCESS.md`
6. `04_CHANGELOG.md`

Toute implémentation doit respecter cet ordre logique.

---

## Principe méthodologique fondamental

> **Tout ce qui a été découvert par la douleur devient une règle écrite.**

Cycle immuable :
**Documentation → Code → Tests → Changelog → Release**

---

# Hiérarchie documentaire officielle

## 1. Vision Produit & Périmètre

- 📄 **PRD — Product Requirements Document**  
  → `docs/PRD_BLUEGREEN_CORE.md`

---

## 2. Architecture Générale & Invariants

- 🏗️ **Architecture Blue/Green**  
  → `docs/01_ARCHITECTURE.md`

- 🔒 **Normes, interdictions, verrous**  
  → `docs/02_NORMES_ET_CONVENTIONS.md`

---

## 3. Configuration & Contrats

- ⚙️ **Spécification `global.conf`**  
  → `docs/03_GLOBAL_CONF_SPEC.md`

- 🧩 **Spécification `site.conf`**  
  → `docs/03_SITE_CONF_SPEC.md`

---

## 4. Décisions d’Architecture (ADR)

- 🧠 **Index des ADR**  
  → `docs/ADR/INDEX.md`

- 📌 **Décisions actives & historiques**  
  → `docs/ADR/`

---

## 5. Procédures Opérationnelles

- ▶️ **RUNBOOK principal**  
  → `docs/RUNBOOK.md`

- 🔁 **Rollback / recovery**  
  → `docs/runbooks/`

⚠️ Les runbooks ne doivent contenir **aucune décision d’architecture**.

---

## 6. Release, Versioning & Qualité

- 🏷️ **Changelog**  
  → `docs/04_CHANGELOG.md`

- 🚀 **Process de release**  
  → `docs/06_RELEASE_PROCESS.md`

---

## 7. Audits & États

- 🔍 **Audit état v6.7 (baseline)**  
  → `docs/audit/AUDIT_STATE_V6_7.md`

- 📊 **Audits ultérieurs**  
  → `docs/audit/`

---

## 8. Gouvernance & Usage de l’IA

- 🤖 **Guide des agents IA (Cursor)**  
  → `docs/05_AGENT_GUIDE.md`

- 👤 **Product Owner & validation humaine**  
  (décrit dans le PRD et le guide agent)

---

## 9. Historique & Évolution

- 🧭 **Roadmap versions**  
  → `docs/ROADMAP.md`

- 🗂️ **Documents legacy (historique uniquement)**  
  - `docs/ARCHITECTURE.md`
  - `docs/DECISIONS.md`
  - `docs/RUNBOOK.md`

⚠️ Ces documents ne doivent **jamais** guider une décision nouvelle.

---

## Règles documentaires fondamentales

1. Ajout uniquement (jamais suppression).
2. Toute évolution est datée et contextualisée.
3. Toute décision → ADR.
4. Toute procédure → RUNBOOK.
5. Le MASTER INDEX est mis à jour à chaque ajout officiel.

> Toute information non localisable depuis ce document
> n’est pas considérée comme officielle.

