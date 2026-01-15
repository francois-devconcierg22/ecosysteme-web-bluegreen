# ADR-0005 — Logs, Audit & Observability

## Statut
ACCEPTÉ

---

## Contexte
Le produit BlueGreen Orchestrator ZIP est destiné à des environnements
où la confiance, la traçabilité et la capacité d’audit sont essentielles
(clients finaux, agences, exploitation).

Sans règles explicites, les logs deviennent incomplets, non exploitables
ou juridiquement inopposables.

---

## Décision
La journalisation, l’audit et l’observabilité sont des **capacités natives**
du produit, mais **jamais implicites**.

Principes :
- aucune action réelle sans trace
- aucune trace sans horodatage
- aucune suppression automatique de logs
- audit lisible par un tiers

---

## Niveaux de logs

Niveaux autorisés :
- DEBUG
- INFO
- WARN
- ERROR

Le niveau par défaut est :
```conf
LOG_LEVEL="INFO"
```

---

## Journalisation obligatoire

Toute action réelle doit produire :
- un identifiant d’exécution unique
- un horodatage ISO-8601
- l’action demandée
- le résultat (succès / échec)
- le mode (DRY_RUN / APPLY)

---

## Audit

Un audit correspond à :
- une action explicite
- une configuration donnée
- un résultat observable

Les audits doivent être :
- persistants
- consultables
- exportables (texte / archive)

---

## Observabilité minimale

Le produit doit exposer au minimum :
- état Blue / Green
- dernière action exécutée
- dernière bascule
- dernière sauvegarde

Aucune métrique système globale n’est requise par défaut.

---

## Accès aux logs

- mode SAFE : lecture seule
- mode ADMIN : lecture + export

Aucun accès en écriture depuis le cockpit.

---

## Conséquences

### Avantages
- conformité exploitation
- confiance client
- diagnostic facilité
- valeur commerciale accrue

### Contraintes
- stockage requis
- discipline de développement

---

## Lien documentaire
- ADR-0001
- ADR-0002
- ADR-0003
- ADR-0004
- 03_GLOBAL_CONF_SPEC.md

---

## Date
2026-01-15

