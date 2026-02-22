# Froggle - Vue d'Ensemble du Projet

[Retour a l'index](./index.md)

---

## Description

**Froggle** est une application de jeu de Boggle multijoueur en francais, developpee avec Flutter. Le jeu permet aux utilisateurs de trouver des mots dans une grille de lettres 4x4 en un temps limite.

---

## Objectifs du Projet

1. Offrir une experience de jeu de Boggle fluide et intuitive
2. Permettre le jeu multijoueur via plusieurs methodes de connexion
3. Supporter plusieurs plateformes (mobile, desktop, web)
4. Proposer un dictionnaire francais complet pour la validation des mots
5. Suivre les statistiques et performances des joueurs

---

## Fonctionnalites

### Gameplay

| Fonctionnalite | Description |
|----------------|-------------|
| **Grille de lettres** | Grille 4x4 generee aleatoirement avec des des officiels du Boggle |
| **Selection par glissement** | Tracer un chemin sur la grille pour former des mots |
| **Selection par tap** | Cliquer sur les lettres adjacentes une par une |
| **Timer** | Compte a rebours de 3 minutes par defaut (configurable) |
| **Validation temps reel** | Les mots sont valides instantanement |
| **Calcul des points** | Points bases sur la longueur du mot (3-4: 1pt, 5: 2pts, 6: 3pts, 7: 5pts, 8+: 11pts) |

### Modes de Jeu

| Mode | Description |
|------|-------------|
| **Solo** | Jouer seul, rejouer la meme grille pour s'ameliorer |
| **Multijoueur Internet** | Creer ou rejoindre une partie via WebSocket |
| **Multijoueur WiFi Direct** | Connexion directe entre appareils (mobile uniquement) |

### Gestion des Joueurs

- Systeme d'authentification locale (inscription/connexion)
- Profils utilisateurs avec statistiques
- Historique des parties jouees
- Classement en fin de partie

### Resultats et Statistiques

- Affichage du classement a la fin de chaque manche
- Liste des mots trouves par chaque joueur
- Mots en double (annules entre joueurs)
- Mots invalides marques en rouge
- Decouverte des mots manques
- Visualisation du chemin de chaque mot sur la grille
- Acces aux definitions via CNRTL

---

## Regles du Jeu

### Formation des Mots
1. Les mots doivent contenir au minimum **3 lettres**
2. Chaque lettre ne peut etre utilisee qu'**une seule fois** par mot
3. Les lettres doivent etre **adjacentes** (horizontalement, verticalement ou diagonalement)
4. Les mots doivent exister dans le **dictionnaire francais**

### Scoring en Multijoueur
- Les mots trouves par **plusieurs joueurs** sont **annules** (0 points)
- Seuls les mots **uniques** rapportent des points
- Le joueur avec le plus de points gagne

### Barème des Points

| Longueur | Points |
|----------|--------|
| 3-4 lettres | 1 |
| 5 lettres | 2 |
| 6 lettres | 3 |
| 7 lettres | 5 |
| 8+ lettres | 11 |

---

## Plateformes Supportees

| Plateforme | Statut | Connexions Disponibles |
|------------|--------|------------------------|
| Android | Supporte | Internet, WiFi Direct, Bluetooth |
| iOS | Supporte | Internet, Bluetooth |
| macOS | Supporte | Internet, Bluetooth |
| Linux | Supporte | Internet, Bluetooth |
| Windows | Supporte | Internet |
| Web | Supporte | Internet |

---

## Dictionnaire

Le jeu utilise un dictionnaire francais complet stocke localement:
- `dictionnaire_fr.txt` - Liste principale des mots valides
- `mots_pluriels.txt` - Formes plurielles
- `mots_conjugues.txt` - Formes conjuguees

Les mots sont charges en memoire au demarrage pour une validation rapide.

---

## Flux Utilisateur Principal

```
[Ecran d'accueil]
       |
       v
[Choix du mode] --> [Solo] --> [Jeu] --> [Resultats]
       |                                      |
       v                                      v
[Multijoueur]                           [Rejouer / Accueil]
       |
       v
[Creer / Rejoindre]
       |
       v
[Salle d'attente]
       |
       v
[Jeu multijoueur]
       |
       v
[Resultats] --> [Vote nouvelle partie]
```

---

## Voir Aussi

- [Architecture](./architecture.md)
- [Composants](./component-inventory.md)
