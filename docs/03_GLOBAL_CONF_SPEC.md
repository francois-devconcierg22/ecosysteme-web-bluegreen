# 03 --- GLOBAL.CONF SPECIFICATION (CANONIQUE)

## Rôle

Spécifier la liste des variables autorisées. Tout comportement
structurant doit être piloté par `global.conf`.

------------------------------------------------------------------------

## Variables structurantes minimales

### Identité / isolation

-   `PROJECT_ID` (string) : clé primaire universelle

### Modes / gouvernance

-   `INSTALL_MODE` (enum) :
    `SERVER_NEUF | PROJET_UNIQUE | MULTI_PROJETS`

### Domaines / routage (exemples)

-   `DOMAIN_BLUE` (string)
-   `DOMAIN_GREEN` (string)
-   Préfixe préprod : **`test`** (ex : `test.example.com`)

------------------------------------------------------------------------

## Règles

-   Toute variable ajoutée doit être :
    -   déclarée ici
    -   documentée (type, rôle, impact)
    -   référencée dans le changelog

------------------------------------------------------------------------

## Extrait recommandé (global.conf)

``` conf
# =========================
# IDENTITÉ PROJET
# =========================
PROJECT_ID="conciergerie"

# =========================
# MODE D'INSTALLATION
# =========================
INSTALL_MODE="PROJET_UNIQUE"   # SERVER_NEUF | PROJET_UNIQUE | MULTI_PROJETS

# =========================
# DOMAINES
# =========================
DOMAIN_BLUE="example.com"
DOMAIN_GREEN="test.example.com"
```

------------------------------------------------------------------------

## INSTALL_MODE --- Verrou d'exécution destructif

``` ini
INSTALL_MODE="SERVER_NEUF"   # SERVER_NEUF | PROJET_UNIQUE | MULTI_PROJETS
PROJECT_ID="exemple"
```

Cette variable conditionne **toute action destructrice** du socle
BlueGreen.

### Règle absolue

-   `global.conf` est la **seule source de vérité**
-   Aucun script n'a le droit :
    -   d'inférer un mode
    -   d'en inventer un
    -   de contourner cette variable

### Comportement obligatoire

-   Si `INSTALL_MODE` est **absent** → arrêt immédiat (`exit 42`)
-   Si `INSTALL_MODE` est **invalide** → arrêt immédiat (`exit 42`)
-   Toute action destructrice sans validation explicite du mode est
    **interdite**

### Statut

Cette règle est **bloquante, non négociable et opposable**.\
Tout script qui ne la respecte pas est considéré comme **invalide**.

------------------------------------------------------------------------

## Extension normative --- Invariants globaux produit (ajout v6.8)

> Cette section complète la spécification canonique existante.\
> Elle ne modifie ni ne contredit aucune règle précédente.

------------------------------------------------------------------------

## Portée de `global.conf`

Le fichier `global.conf` définit **ce que le produit BlueGreen a le
droit de faire au niveau global**, indépendamment de tout projet ou
client.

Il est : - unique, - versionné avec le produit, - supérieur à tout
`site.conf`.

------------------------------------------------------------------------

## Relation avec `site.conf`

-   `global.conf` définit les **capacités autorisées**
-   `site.conf` définit les **capacités activées**

Règle stricte :

> Une capacité absente ou interdite dans `global.conf` ne peut jamais
> être activée par `site.conf`.

------------------------------------------------------------------------

## Capacités globales autorisées (produit)

``` conf
GLOBAL_CAPABILITIES=(
  "infra"
  "bluegreen"
  "rollback"
  "audit"
  "logs"
  "cockpit"
  "wordpress"
)
```

-   Liste **déclarative**
-   Aucune activation implicite
-   Toute capacité absente est **interdite**

------------------------------------------------------------------------

## DRY_RUN --- Comportement global par défaut

``` conf
GLOBAL_DRY_RUN_DEFAULT="true"
```

### Règles

-   aucune action réelle sans désactivation explicite
-   toute action réelle doit être :
    -   intentionnelle
    -   traçable
    -   conforme à l'ADR-0001

------------------------------------------------------------------------

## Périmètre global autorisé

``` conf
PROJECTS_ROOT="/srv/bluegreen"
```

Toute opération hors de ce périmètre est **interdite**.

------------------------------------------------------------------------

## Zones globales strictement interdites

Aucune action du produit ne doit toucher à : - `/home` - `/root` -
`~/.ssh` - `/etc/ssh` - firewall (`ufw`, `iptables`) - Docker global non
ciblé (`prune`, suppressions larges)

Ces interdictions sont **absolues et non contournables**.

------------------------------------------------------------------------

## Cockpit --- contraintes globales

``` conf
COCKPIT_MODES_ALLOWED=(
  "safe"
  "admin"
)
```

### Règles

-   le mode `safe` est **obligatoire** pour toute exposition client
    final
-   le cockpit :
    -   ne contient aucune logique métier
    -   ne prend aucune décision
    -   déclenche uniquement des scripts existants

------------------------------------------------------------------------

## Version produit (informative)

``` conf
BLUEGREEN_VERSION="6.8"
```

-   valeur informative uniquement
-   utilisée pour audit, support et traçabilité
-   n'entraîne aucun comportement automatique

------------------------------------------------------------------------

## Interdictions formelles (rappel)

Le fichier `global.conf` ne doit jamais : - contenir de secrets -
contenir des valeurs client - inclure de logique conditionnelle -
référencer des chemins dynamiques - exécuter ou inclure des scripts

------------------------------------------------------------------------

## Évolution du contrat

Toute modification de `global.conf` : - doit être documentée ici - doit
être référencée dans le changelog - nécessite un ADR si impact
comportemental - prime sur toute configuration projet

------------------------------------------------------------------------

## Principe de clôture

> `global.conf` définit **les limites du produit**.\
> Ce qui n'est pas autorisé ici est **interdit partout**.

