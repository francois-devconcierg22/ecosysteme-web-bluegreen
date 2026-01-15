# ADR-0004 — Backup & Restore Strategy

## Statut
ACCEPTÉ

---

## Contexte
Le BlueGreen Orchestrator ZIP doit garantir la réversibilité complète
des opérations (mises à jour, bascules, incidents).
Un mécanisme de sauvegarde et de restauration est requis,
sans comportement destructif implicite.

---

## Décision
La stratégie de sauvegarde est **explicite, modulaire et traçable**.

Principes :
- aucune sauvegarde automatique implicite
- déclenchement explicite par opérateur
- périmètre strictement déclaré
- restauration toujours manuelle

---

## Périmètre sauvegardé

Selon modules activés :
- volumes applicatifs (Blue / Green)
- bases de données (si applicables)
- configurations projet (hors secrets)

Sont exclus :
- système hôte
- comptes utilisateurs
- clés SSH
- firewall

---

## Types de sauvegardes

- Snapshot logique (volumes Docker)
- Dump applicatif (DB)
- Archive de configuration projet

Chaque type est indépendant et activable par module.

---

## Déclenchement

Commandes autorisées :
```bash
./run.sh backup
./run.sh restore
```

Aucune sauvegarde n’est déclenchée automatiquement par `apply`.

---

## Restauration

Règles :
- restauration ciblée (Blue ou Green)
- jamais en écrasant sans confirmation
- journalisation obligatoire
- DRY_RUN disponible

---

## Traçabilité

Chaque opération produit :
- un identifiant unique
- un horodatage
- un manifeste de contenu

---

## Conséquences

### Avantages
- sécurité accrue
- confiance client
- conformité produit

### Contraintes
- discipline opérateur
- stockage requis

---

## Lien documentaire
- ADR-0001
- ADR-0003
- RUNBOOK_RUN_SH_SPEC_v6_8.md
- 03_GLOBAL_CONF_SPEC.md

---

## Date
2026-01-15

