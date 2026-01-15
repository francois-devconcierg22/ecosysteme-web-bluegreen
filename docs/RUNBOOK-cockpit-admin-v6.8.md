# RUNBOOK — Cockpit ADMIN v6.8

## Objectif
Définir précisément les usages autorisés du **cockpit en mode ADMIN**,
réservé à l’opérateur BlueGreen (toi, agence, exploitation),
avec un pouvoir d’action réel mais strictement encadré.

Ce document complète :
- RUNBOOK-cockpit-safe-v6.8.md
- ADR-0002 (Cockpit safe vs admin)

---

## Principe fondamental

> Le cockpit ADMIN est un **poste d’orchestration**, pas un outil de debug.
> Il déclenche des actions **déjà définies et documentées**, jamais de logique nouvelle.

---

## Accès et périmètre

- Accès réservé à l’opérateur
- Jamais exposé publiquement
- Accès réseau restreint (VPN, IP allowlist, accès local)

---

## Capacités autorisées

Le cockpit ADMIN permet :

- exécution réelle des commandes `run.sh`
- bascule Blue ⇄ Green
- rollback explicite
- déclenchement backup / restore
- consultation complète des logs et audits
- export des journaux

---

## Actions autorisées

```text
status
apply
rollback
backup
restore
view-logs
export-logs
view-audit
```

Chaque action :
- est explicitement demandée
- est journalisée
- inclut le mode (DRY_RUN / APPLY)

---

## Actions interdites

- modification directe de fichiers (`global.conf`, `site.conf`)
- exécution de commandes shell arbitraires
- édition de scripts
- suppression manuelle de volumes
- accès root système

Toute tentative → refus + log ERROR.

---

## Gestion du DRY_RUN

Règles :
- DRY_RUN par défaut
- `apply` désactive explicitement le DRY_RUN
- aucune action réelle sans confirmation opérateur

---

## Sécurité et traçabilité

Chaque action ADMIN génère :
- un identifiant d’exécution
- un horodatage
- l’utilisateur logique
- l’action demandée
- le résultat

Les logs ADMIN sont :
- persistants
- exportables
- non modifiables depuis le cockpit

---

## Scénarios opérateur typiques

### Mise à jour standard
1. dry-run
2. vérification logs
3. apply
4. validation
5. bascule

### Incident en production
1. rollback
2. vérification état
3. analyse logs

---

## Validation du cockpit ADMIN

Le cockpit ADMIN est conforme si :
- aucune action hors run.sh n’est possible
- aucune configuration n’est modifiable
- chaque action est traçable
- aucun comportement implicite n’existe

---

## Lien documentaire

- ADR-0001 — Non-destructive default
- ADR-0002 — Cockpit safe vs admin
- ADR-0003 — Blue/Green flow
- ADR-0005 — Logs & audit
- RUNBOOK_RUN_SH_SPEC_v6_8.md

---

## Principe de clôture

> Le cockpit ADMIN **donne du pouvoir**,  
> mais uniquement dans les limites strictes du produit.

