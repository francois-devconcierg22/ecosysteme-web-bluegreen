# 01 — ARCHITECTURE BLUEGREEN v6.7

## Objectif
Décrire l’architecture réellement validée en v6.7.

## Principes structurants
- Blue / Green strict
- 1 PROJECT_ID = 1 stack
- 1 Traefik par stack (mode standalone)
- Aucune mutualisation forcée
- Isolation stricte réseau / volumes

## Règles clés
- Aucun nettoyage serveur global
- Aucun impact sur les autres stacks
- Toute ressource est préfixée PROJECT_ID

## Ce que v6.7 FAIT
- Installer une stack BlueGreen autonome
- Gérer backup / switch / update
- Préparer le multi-stack

## Ce que v6.7 NE FAIT PAS
- Multi-site automatique
- Cockpit graphique
- Nettoyage agressif serveur
