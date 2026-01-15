# RUNBOOK — Backup & Restore v6.8

## Objectif
Effectuer des sauvegardes et restaurations contrôlées
dans le cadre du BlueGreen Orchestrator ZIP.

---

## Pré-requis
- Orchestrateur installé
- Accès opérateur
- Espace disque suffisant

---

## Sauvegarde (DRY_RUN)

```bash
./run.sh backup --dry-run
```

Vérifier :
- périmètre listé
- aucun impact système
- manifest généré

---

## Sauvegarde réelle

```bash
./run.sh backup
```

Résultat :
- archive créée
- ID de sauvegarde retourné
- logs persistés

---

## Restauration (simulation)

```bash
./run.sh restore --id <BACKUP_ID> --dry-run
```

---

## Restauration réelle

```bash
./run.sh restore --id <BACKUP_ID>
```

Règles :
- restauration ciblée
- aucune bascule automatique
- validation post-restore requise

---

## Vérifications post-restauration
- intégrité des volumes
- état Blue / Green
- services accessibles

---

## Rollback de restauration
Une restauration est elle-même réversible
si un état précédent existe.

---

