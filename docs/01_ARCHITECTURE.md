# 01 — ARCHITECTURE BLUEGREEN v6.7 (RÉELLE)

## Objectif
Décrire l’architecture **réellement validée en production**.

## Principes structurants
- Blue / Green strict
- **1 PROJECT_ID = 1 stack**
- 1 base de données par stack
- Isolation totale (containers, réseaux, volumes)

## Traefik
Deux modes supportés :
- Traefik embarqué dans la stack
- Traefik externe mutualisé

Les deux sont supportés **sans hypothèse serveur vierge**.

## Ce qui a échoué en v7 (et est désormais interdit)
- Nettoyage serveur global
- Suppression Docker non ciblée
- Reconfiguration SSH
- Hypothèse “serveur vierge permanent”

## Contrainte clé multi-BlueGreen
Un serveur peut héberger **N stacks BlueGreen**.

Conséquence directe :
- Aucun script ne doit impacter autre chose que son PROJECT_ID
- Le ménage global est interdit
- Le ménage doit être **conditionnel et ciblé**

## Rôle de global.conf
global.conf est la **seule source de vérité**.
Les scripts exécutent.  
Ils ne décident jamais.
