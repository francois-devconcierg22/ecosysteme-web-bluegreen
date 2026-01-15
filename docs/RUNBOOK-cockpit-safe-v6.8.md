# RUNBOOK — Cockpit SAFE v6.8

## Objectif
Définir les usages autorisés du cockpit en **mode SAFE**,
exposé à un client final sans risque opérationnel.

---

## Principes
- lecture seule par défaut
- aucune action destructive
- aucune modification de configuration
- aucune bascule réelle

---

## Accès autorisés

Le cockpit SAFE permet :
- consultation état Blue / Green
- consultation version produit
- consultation dernière release
- consultation logs
- exécution de DRY_RUN uniquement

---

## Actions autorisées

```text
status
dry-run
view-logs
view-audit
```

Aucune autre action n’est autorisée.

---

## Actions interdites

- apply
- rollback
- backup
- restore
- modification configuration
- accès admin

Toute tentative → refus explicite + log.

---

## Traçabilité

Chaque interaction cockpit SAFE :
- est horodatée
- est journalisée
- est liée à un utilisateur logique

---

## Sécurité

- aucune clé sensible exposée
- aucune commande shell directe
- aucun script autonome

---

## Validation

Le cockpit SAFE est conforme si :
- aucune action réelle n’est possible
- aucun état système n’est modifiable
- les logs sont lisibles mais non modifiables

---

## Lien documentaire
- ADR-0002
- ADR-0005
- RUNBOOK_RUN_SH_SPEC_v6_8.md

---

