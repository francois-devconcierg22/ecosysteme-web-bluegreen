# Structure du ZIP — BlueGreen Orchestrator v6.8

## Principe
Le ZIP est un **orchestrateur modulaire**.
Il ne contient aucune donnée client.
Tout est piloté par configuration.

---

## Arborescence de référence

```
bluegreen-orchestrator/
├── run.sh                  # Entrypoint unique
├── global.conf.example
├── docs/
│   ├── 00_MASTER_INDEX.md
│   ├── 03_GLOBAL_CONF_SPEC.md
│   ├── 03_SITE_CONF_SPEC.md
│   ├── RUNBOOK.md
│   └── ADR/
├── scripts/
│   ├── core/
│   ├── audit/
│   ├── bluegreen/
│   ├── rollback/
│   └── cockpit/
├── sites/
│   └── example/
│       └── site.conf.example
├── docker/
│   ├── traefik/
│   └── networks/
└── VERSION
```

---

## Entrypoint `run.sh`

Rôle :
- charger `global.conf`
- valider `INSTALL_MODE`
- charger `site.conf`
- appliquer le DRY_RUN
- déléguer aux scripts

---

## Règles absolues
- un seul entrypoint
- aucun script autonome
- aucune détection implicite
- toute action passe par `run.sh`

---

## Modules
Chaque module :
- est isolé
- activé explicitement
- documenté
- testable indépendamment

---

## Valeur produit
Cette structure permet :
- ventes par modules
- maintenance prévisible
- rollback propre
- cockpit sécurisé

