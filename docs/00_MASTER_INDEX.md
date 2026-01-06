# 00 — MASTER INDEX (SOURCE DE VÉRITÉ)

## Rôle
Point d’entrée unique. Toute décision structurante doit être traçable ici et dans les documents normatifs associés.
Le ZIP est un artefact. La vérité du projet est dans la documentation versionnée.

## État actuel
- Référence validée : **v6.7 (infra-only stable)**
- Doctrine : **mono-stack propre** (1 serveur = 1 Blue/Green = 1 projet)
- Objectif suivant : **v8 multi-stacks** (N projets + 1 Traefik “shared”)

## Décisions actées (résumé exécutif)
### A. Ménage / nettoyage
- Le ménage est une **capacité**, pas un comportement par défaut.
- **Interdit** : ménage serveur implicite au début d’un `run.sh`.
- **Obligatoire** : ménage explicite via mode d’installation (**INSTALL_MODE**) et scripts dédiés.

### B. INSTALL_MODE (verrou)
On introduit un mode explicite **avant toute action destructive**. Valeurs strictes :
- `SERVER_NEUF`
- `PROJET_UNIQUE`
- `MULTI_PROJETS`

Si absent ou invalide → **STOP (exit 42)**.

### C. SSH (safe)
- La préparation SSH peut rester dans le ZIP.
- Le problème v7 provenait du **nettoyage serveur** (périmètre trop large), pas du fait “SSH dans le ZIP”.
- Le ménage ne doit jamais toucher à `/home`, `~/.ssh`, `/etc/ssh`.

## Ordre de lecture obligatoire (humain + IA)
1. **02_NORMES_ET_CONVENTIONS.md** (verrous, interdictions, méthode)
2. **01_ARCHITECTURE.md** (v6.7 mono-stack + trajectoire v8 multi)
3. **03_GLOBAL_CONF_SPEC.md** (variables autorisées, INSTALL_MODE)
4. **05_AGENT_GUIDE.md** (workflow, discipline, “pain → rule”)
5. **06_RELEASE_PROCESS.md** (release ZIP + checklist)
6. **04_CHANGELOG.md** (traçabilité)

## “Découvert par la douleur” = règle écrite (méthode verrouillée)
À partir de maintenant :
> Tout ce qui a été découvert par la douleur devient une règle écrite.

L’implémentation suit toujours : **Doc → Code → Tests → Changelog → Release**.

## Documents legacy (non sources de vérité)
- `docs/ARCHITECTURE.md`
- `docs/DECISIONS.md`
- `docs/RUNBOOK.md`

Ils restent pour historique, mais ne doivent pas guider une décision.
