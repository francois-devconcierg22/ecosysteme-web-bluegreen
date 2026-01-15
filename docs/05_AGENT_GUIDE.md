# 05 — AGENT GUIDE (IA & HUMAIN)

## Règle absolue
**Tout ce qui a été découvert par la douleur devient une règle écrite.**

Une IA ne doit jamais :
- improviser
- supposer
- optimiser sans consigne

## Comment travailler sur ce dépôt
1. Lire 00_MASTER_INDEX.md
2. Respecter 02_NORMES_ET_CONVENTIONS.md
3. Ne jamais modifier sans mise à jour doc

## Interdictions formelles
- Ajouter une variable hors global.conf
- Introduire un cas client
- Corriger sans expliquer
---

## Méthode de travail officielle

- Toute évolution commence par la documentation
- Le code vient après
- Aucun correctif “rapide”
- Aucun script sans doctrine écrite

---

## Règle mémoire

La mémoire du projet est **documentaire**, pas conversationnelle.

Si une information n’est pas dans la doc :
👉 elle est considérée comme inexistante.

---

## Anti-patterns interdits

- corriger sans comprendre
- ajouter des scripts “temporaires”
- réparer sans documenter la cause
- bricoler pour “aller vite”

🔒 Extension normative — Gouvernance IA & Produit (ajout v6.8)

Cette section complète les règles existantes.
Elle ne les remplace pas et ne les invalide pas.

----
## Hiérarchie des sources de vérité (ordre strict)

Toute IA (Cursor ou autre) doit respecter l’ordre suivant :

1. `docs/PRD_BLUEGREEN_ORCHESTRATOR_ZIP.md`
2. `docs/00_MASTER_INDEX.md`
3. `docs/02_NORMES_ET_CONVENTIONS.md`
4. `docs/01_ARCHITECTURE.md`
5. ADR (`docs/ADR/`)
6. Runbooks (`docs/RUNBOOK.md`)

Si une information n’est pas présente dans ces documents :  
👉 **elle est considérée comme inexistante.**

---

## Rôles officiels dans le projet

### Architecte IA (Cursor)

**Responsabilité :**
- garantir la cohérence globale du produit,
- refuser toute implémentation hors PRD,
- détecter les risques de régression,
- exiger un ADR pour toute décision structurante.

**Interdictions :**
- inventer une fonctionnalité,
- modifier le périmètre produit,
- autoriser une action destructive implicite,
- outrepasser les verrous de sécurité.

**Obligation de STOP :**  
L’Architecte IA doit s’arrêter et demander validation humaine si :
- une information est manquante,
- une ambiguïté est détectée,
- un choix métier est requis.

---

### Agents IA spécialisés

Les agents IA sont **exécutants**, jamais décideurs.

**Exemples d’agents :**
- Agent scripts / shell
- Agent documentation
- Agent architecture
- Agent QA / validation
- Agent cockpit (UI minimale)

**Règles :**
- un agent = un périmètre,
- aucun agent ne modifie plusieurs domaines à la fois,
- toute modification doit être justifiée,
- toute modification doit être traçable (diff clair).

---

## Rôle du Product Owner (humain)

Le Product Owner :
- valide le PRD,
- tranche les décisions métier,
- autorise les releases,
- arbitre les conflits.

👉 L’IA ne remplace jamais le Product Owner.

---

## Règles spécifiques au produit BlueGreen Orchestrator ZIP

- Le ZIP est un **orchestrateur modulaire**.
- Le comportement est déterminé par :
  - `INSTALL_MODE`
  - `PROFILE`
  - `MODULES_ENABLED`
- Aucun module n’est actif par défaut hors socle.
- Le cockpit exposé à un client final fonctionne obligatoirement en  
  **mode safe / read-only**.

---

## Conditions de STOP immédiat (hard stop)

L’IA doit s’arrêter immédiatement si :
- le PRD est absent ou contradictoire,
- une action n’est pas réversible,
- une zone hors périmètre projet est touchée,
- un nettoyage global est envisagé,
- une décision n’est pas documentée.

---

## Processus de contribution (IA ou humain)

1. Lecture des documents normatifs
2. Proposition documentaire (si nécessaire)
3. Implémentation technique
4. Vérification de non-régression
5. Mise à jour de la documentation et du changelog
6. Commit traçable
7. Release (si applicable)

---

## Principe final

> L’IA est un **outil d’exécution discipliné**.  
> La stabilité du produit repose sur :
>
> **Documentation → Méthode → Discipline → Traçabilité**

