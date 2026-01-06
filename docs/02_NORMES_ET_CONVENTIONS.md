# 02 — NORMES ET CONVENTIONS (VERROUILLÉ)

## Rôle
Empêcher les dérives. Garantir homogénéité, auditabilité, non-régression et reprise par IA sans “mémoire conversationnelle”.

---

## 1. Normes techniques
- `PROJECT_ID` = clé primaire universelle
- Aucun nom non préfixé = bug
- `global.conf` = source de vérité unique (toute variable structurante y est déclarée)
- Aucune décision implicite dans les scripts (toute décision est documentée)

---

## 2. Norme “pain → rule” (méthode verrouillée)
À partir de maintenant :
> Tout ce qui a été découvert par la douleur devient une règle écrite.

Conséquence :
- chaque incident → règle + doc + (si applicable) garde-fou technique
- aucune “réparation” en cascade non documentée (anti-v7)

---

## 3. INSTALL_MODE (verrou obligatoire)
### 3.1 Valeurs autorisées (strict)
- `SERVER_NEUF`
- `PROJET_UNIQUE`
- `MULTI_PROJETS`

Absence ou valeur invalide → **STOP (exit 42)**.

### 3.2 Comportements attendus
#### INSTALL_MODE=SERVER_NEUF
- Ménage global autorisé **mais encadré**
- Confirmation humaine obligatoire + bannière “DESTRUCTIF”
- Log détaillé
- Exécution “bootstrap” (pas dans le run standard)

#### INSTALL_MODE=PROJET_UNIQUE
- Nettoyage autorisé mais **scopé au projet**
- purge limitée aux ressources du même `PROJECT_ID`

#### INSTALL_MODE=MULTI_PROJETS
- Interdiction totale de ménage global
- refus de toute commande Docker “large” non scopée

---

## 4. SSH safe (anti-casse)
- SSH peut rester dans le ZIP (script dédié)
- Nettoyage ne doit jamais toucher : `/home`, `~/.ssh`, `/etc/ssh`, `/root`
- Interdits : `chmod -R`, `chown -R` hors périmètre strict projet
- Tout script destructif doit implémenter les garde-fous INSTALL_MODE

---

## 5. Normes documentaires
- 1 information = 1 fichier de référence
- pas de duplication
- un document “legacy” doit être explicitement déclaré non source de vérité

---

## 6. Normes de travail
- pas de quick fix
- pas de modifications implicites
- tout doit être rejouable
- Doc → Code → Test → Changelog → Release
---

## Principe directeur (gravé)

Tout ce qui a été découvert par la douleur devient une règle écrite.

Aucune exception.
Aucun retour en arrière.
Aucune logique implicite.

---

## Doctrine ménage (v6.7)

### ❌ Ce qu’il est interdit de faire

- ménage serveur implicite
- hypothèse “serveur vierge”
- nettoyage global non documenté
- commandes destructives hors périmètre

---

### ✅ Principe adopté

> **Le ménage est une capacité, pas un comportement par défaut.**

Le ZIP **sait** faire le ménage  
Le ZIP **ne le fait jamais implicitement**

---

## INSTALL_MODE (verrou technique)

Le comportement destructif est conditionné **avant toute action**.

### Valeurs autorisées (strictes)

- `SERVER_NEUF`
- `PROJET_UNIQUE`
- `MULTI_PROJETS`

Toute autre valeur → **STOP immédiat**

---

## Comportement par mode

### 🔥 INSTALL_MODE=SERVER_NEUF
- ménage autorisé
- confirmation humaine obligatoire
- log détaillé
- exécution unique par serveur

### 🟦 INSTALL_MODE=PROJET_UNIQUE (v6.7)
- ménage limité au `PROJECT_ID`
- aucun impact hors périmètre
- mode production standard

### 🟩 INSTALL_MODE=MULTI_PROJETS
- ménage global **interdit**
- actions strictement limitées au projet
- sécurité maximale

---

## Règle non négociable

Sans bloc de validation `INSTALL_MODE`,  
un script est **considéré invalide**.
