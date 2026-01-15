# 03 --- SITE.CONF SPECIFICATION

## Rôle du document

Ce document définit le **contrat de configuration `site.conf`** utilisé
par le BlueGreen Orchestrator ZIP pour activer ou désactiver des modules
fonctionnels selon l'offre vendue à un client.

Ce document est **déclaratif uniquement**. Il ne contient aucune logique
métier ni aucune action.

------------------------------------------------------------------------

## Positionnement dans l'architecture

-   `global.conf` : invariants globaux
-   `site.conf` : configuration **par projet / par client**

Le comportement du ZIP est déterminé par : - le PRD, - `global.conf`, -
`site.conf`.

------------------------------------------------------------------------

## Emplacement standard

Chaque projet possède son propre fichier :

    sites/<site_key>/site.conf

------------------------------------------------------------------------

## Variables obligatoires

### SITE_KEY

Identifiant unique du projet.

``` bash
SITE_KEY="johnbluegreen"
```

------------------------------------------------------------------------

### SITE_DOMAIN

Domaine principal du site.

``` bash
SITE_DOMAIN="johnbluegreen.com"
```

------------------------------------------------------------------------

### INSTALL_MODE

Verrou de sécurité obligatoire.

Valeurs autorisées : - `SERVER_NEUF` - `PROJET_UNIQUE` - `MULTI_PROJETS`

``` bash
INSTALL_MODE="MULTI_PROJETS"
```

------------------------------------------------------------------------

## Profil d'installation

### PROFILE

Détermine **l'offre commerciale activée**.

Valeurs standard : - `infra-only` - `pro` - `wordpress`

``` bash
PROFILE="infra-only"
```

------------------------------------------------------------------------

## Modules activables

### MODULES_ENABLED

Liste explicite des modules autorisés pour ce site.

``` bash
MODULES_ENABLED=(
  "core"
  "audit"
  "logs"
)
```

Tout module non listé est considéré comme **désactivé**.

------------------------------------------------------------------------

## Module WordPress

Activé uniquement si listé dans `MODULES_ENABLED`.

``` bash
WP_ENABLED="true"
WP_VERSION="latest"
```

------------------------------------------------------------------------

## Plugins WordPress standards

Plugins gratuits, figés, documentés.

``` bash
WP_PLUGINS_STANDARD=(
  "seo"
  "cache"
  "security"
  "forms"
)
```

Aucun plugin arbitraire client n'est autorisé par défaut.

------------------------------------------------------------------------

## Cockpit

### COCKPIT_MODE

Niveau d'accès à l'interface.

Valeurs autorisées : - `safe` - `admin`

``` bash
COCKPIT_MODE="safe"
```

Le mode `safe` est obligatoire pour toute exposition client final.

------------------------------------------------------------------------

## Audit & DRY_RUN

### DRY_RUN

Par défaut :

``` bash
DRY_RUN="true"
```

Toute action réelle exige : - désactivation explicite, - validation
préalable, - respect de l'ADR-0001.

------------------------------------------------------------------------

## Interdictions formelles

Le fichier `site.conf` ne doit jamais : - contenir de secrets, -
contenir de logique conditionnelle, - référencer des chemins système
globaux, - déclencher des actions.

------------------------------------------------------------------------

## Évolution du contrat

Toute modification de ce document : - nécessite une mise à jour du PRD
si impact produit, - nécessite un ADR si impact comportemental, - est
versionnée.

------------------------------------------------------------------------

## Lien avec le PRD

Ce document implémente contractuellement : - la modularité du ZIP, - le
découpage des offres, - le cockpit safe, - la non-destructivité par
défaut.

