# 02 — NORMES ET CONVENTIONS (VERROUILLÉ)

## Normes techniques
- PROJECT_ID est obligatoire
- Aucun nom non préfixé
- global.conf = source de vérité
- Aucun script ne décide seul

## Norme SSH
- SSH préparé à l’installation
- Jamais modifié lors des updates
- Aucun script ne casse l’accès SSH

## Norme serveur
- Pas de purge globale
- Pas de docker system prune automatique
- Mode SERVEUR_NEUF explicite si nécessaire

## Norme travail
- Tout est rejouable
- Tout est documenté
- Pas de quick fix
