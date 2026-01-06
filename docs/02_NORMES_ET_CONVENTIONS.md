# 02 — NORMES ET CONVENTIONS (DOCUMENT DE VERROUILLAGE)

## Principe méthodologique fondamental
**Tout ce qui a été découvert par la douleur devient une règle écrite.**

Si ce n’est pas écrit ici,  
alors ce n’est pas autorisé.

## Normes techniques
- PROJECT_ID est la clé primaire universelle
- Aucun nom non préfixé = bug
- Aucune décision dans les scripts
- global.conf = source de vérité unique

## INSTALL_MODE (obligatoire)
- SERVER_FRESH : serveur neuf
- SERVER_EXISTING : serveur avec stacks existantes

Aucun script ne devine le contexte.

## Interdictions absolues
❌ Nettoyage serveur global  
❌ Suppression Docker non ciblée  
❌ Modification SSH  
❌ Hypothèse “serveur vierge”  
❌ Correctif non documenté  

## Norme de sécurité
La sécurité minimale v6.7 est validée.
Toute évolution sécurité doit être :
- documentée
- optionnelle
- rétrocompatible
