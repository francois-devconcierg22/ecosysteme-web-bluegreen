# 01 — ARCHITECTURE BLUEGREEN (v6.7 validée + trajectoire v8)

## Rôle
Décrire l’architecture réellement validée en v6.7 et cadrer la trajectoire industrielle vers v8 multi-stacks.

---

## A. Architecture v6.7 (référence stable)
### A1. Périmètre
- Conçue pour : **serveur dédié** OU **périmètre strictement isolé**
- Hypothèse opérationnelle : **un seul projet Blue/Green sur le serveur**

### A2. Composants
- 1 stack Blue/Green : services applicatifs + volumes + réseau (préfixés/isolés)
- 1 Traefik (embarqué ou équivalent du mode v6.7)
- Scripts d’install/run : orchestrent la création, le démarrage et les checks

### A3. Clé primaire de cohérence
- `PROJECT_ID` est la clé primaire universelle.
- Toute ressource non préfixée par `PROJECT_ID` est un **bug**.

### A4. Nettoyage (v6.7)
- Le nettoyage ne doit pas être “global implicite”.
- En v6.7, le nettoyage acceptable est **scopé au projet** (PROJET_UNIQUE).

---

## B. Ce que v6.7 implique concrètement
### B1. Ce qu’il faut arrêter (interdit)
- ménage serveur automatique au début du flux standard
- hypothèse “serveur vierge” non déclarée
- cleanup implicite (sans mode et sans consentement)

### B2. Ce qu’il faut finaliser (sans refactor massif)
- Documenter explicitement : “v6.7 suppose serveur dédié OU périmètre isolé”
- Extraire le ménage global du flux standard : scripts séparés
- Rendre les opérations destructives explicites : `INSTALL_MODE` + confirmation humaine

---

## C. Trajectoire v8 : Multi-stacks (N projets + 1 Traefik shared)
### C1. Objectif v8
- Un serveur peut héberger **N projets** Blue/Green isolés
- Un Traefik unique “shared” route vers les stacks via labels
- Aucune action destructrice ne doit dépasser le `PROJECT_ID`

### C2. Principes v8
- `INSTALL_MODE=MULTI_PROJETS` interdit tout ménage global
- toutes les ressources sont nommées/préfixées
- chaque projet a son propre `.env/runtime` (ou équivalent) sans collision

### C3. Conséquence de gouvernance
- v6.7 reste la base “mono-stack propre”
- v8 est un chantier distinct : **pas de rétrofit brutal** de v6.7

---

## D. SSH et OS : frontière non négociable
- Les scripts applicatifs ne doivent pas modifier l’OS hors scripts dédiés.
- Le ménage applicatif ne doit jamais toucher :
  - `/home`, `~/.ssh`, `/etc/ssh`, `/root`
- L’accès SSH ne doit jamais pouvoir être cassé par un “cleanup”.
