# Froggle - Composants UI

[Retour a l'index](./index.md)

---

## Carte des Ecrans

```
┌─────────────────────────────────────────────────────────────┐
│                        HomeScreen                            │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Logo + Titre "Froggle"                             │    │
│  │  [Nom du joueur - editable]                         │    │
│  │                                                     │    │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐             │    │
│  │  │  Solo   │  │ Creer   │  │Rejoindre│             │    │
│  │  │         │  │ partie  │  │         │             │    │
│  │  └─────────┘  └─────────┘  └─────────┘             │    │
│  │                                                     │    │
│  │  [Stats] [Params] [Auth]                           │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
         │              │              │
         ▼              ▼              ▼
    GameScreen     LobbyScreen    LobbyScreen
                    (host)         (join)
```

---

## Ecrans Detailles

### HomeScreen

**Navigation:** Point d'entree de l'application

```
┌─────────────────────────────────────┐
│  [Settings]              [Auth]     │
├─────────────────────────────────────┤
│                                     │
│           🐸 FROGGLE               │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  Nom: [Joueur 1    ] [Edit] │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │      🎮 Jouer Solo          │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │    🌐 Creer une partie      │    │
│  │    📶 WiFi Direct           │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │    🔗 Rejoindre             │    │
│  │    [Adresse: _______ ]      │    │
│  └─────────────────────────────┘    │
│                                     │
│  [📊 Stats]                         │
└─────────────────────────────────────┘
```

---

### LobbyScreen

**Navigation:** Depuis HomeScreen (creer/rejoindre)

```
┌─────────────────────────────────────┐
│  ← Retour    Salle d'attente        │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────┐    │
│  │  Info de connexion          │    │
│  │  IP: 192.168.1.42:8080     │    │
│  └─────────────────────────────┘    │
│                                     │
│  Joueurs (2/6)                      │
│  ┌─────────────────────────────┐    │
│  │ 🟢 Joueur 1  [HOST] [VOUS]  │    │
│  │ 🟢 Joueur 2                 │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │    ▶ Demarrer la partie     │    │  (Host only)
│  └─────────────────────────────┘    │
│                                     │
│  "En attente du lancement..."       │  (Client)
└─────────────────────────────────────┘
```

---

### GameScreen

**Navigation:** Depuis LobbyScreen ou HomeScreen (solo)

```
┌─────────────────────────────────────┐
│  Froggle                   [02:45]  │
│              [3 mots | +5 pts]      │
├─────────────────────────────────────┤
│                                     │
│      ┌───┬───┬───┬───┐              │
│      │ F │ R │ O │ G │              │
│      ├───┼───┼───┼───┤              │
│      │ G │ L │ E │ S │              │
│      ├───┼───┼───┼───┤              │
│      │ A │ T │ I │ N │              │
│      ├───┼───┼───┼───┤              │
│      │ M │ O │ T │ S │              │
│      └───┴───┴───┴───┘              │
│                                     │
│       [ ✓ ]        [ ✗ ]            │
│                                     │
│  Vos mots:                          │
│  [FROG] [GRENOUILLE] [MOT]          │
└─────────────────────────────────────┘
```

---

### ResultsScreen

**Navigation:** Depuis GameScreen (fin de timer)

```
┌─────────────────────────────────────┐
│  Resultats                          │
├─────────────────────────────────────┤
│  ┌─────────────────────────────┐    │
│  │  Grille de la manche        │    │
│  │  [4x4 grid avec highlight]  │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │   Manche 1 terminee!        │    │
│  └─────────────────────────────┘    │
│                                     │
│  Classement                         │
│  ┌─────────────────────────────┐    │
│  │ 🥇 Joueur 1  +12  [35 pts]  │ ▼  │
│  │ 🥈 Joueur 2  +8   [28 pts]  │ ▼  │
│  └─────────────────────────────┘    │
│                                     │
│  Vos mots                           │
│  [FROG +1] [MOT +1] [RATS ~~]       │
│                                     │
│  ▶ Mots que vous avez manques       │
│                                     │
│  [ 🔄 Rejouer cette grille ]        │
│  [    Nouvelle partie?     ]        │
│  [      Quitter            ]        │
└─────────────────────────────────────┘
```

---

### SettingsScreen

**Navigation:** Depuis HomeScreen

```
┌─────────────────────────────────────┐
│  ← Retour         Parametres        │
├─────────────────────────────────────┤
│                                     │
│  Duree de la partie                 │
│  ┌─────────────────────────────┐    │
│  │  Duree actuelle: 3 min      │    │
│  │                             │    │
│  │  [1m] [1.5m] [2m] [3m*]     │    │
│  │  [4m] [5m]                  │    │
│  └─────────────────────────────┘    │
│                                     │
│  Zoom de la grille                  │
│  ┌─────────────────────────────┐    │
│  │  Zoom: 100%                 │    │
│  │  [────────●────────]        │    │
│  │  50%              150%      │    │
│  └─────────────────────────────┘    │
│                                     │
│  Apercu:                            │
│  ┌───────────┐                      │
│  │ F R O     │                      │
│  │ G G L     │                      │
│  │ E ! !     │                      │
│  └───────────┘                      │
└─────────────────────────────────────┘
```

---

### AuthScreen

**Navigation:** Depuis HomeScreen

```
┌─────────────────────────────────────┐
│            (gradient bg)            │
│                                     │
│              👤                     │
│           Connexion                 │
│                                     │
│  ┌─────────────────────────────┐    │
│  │                             │    │
│  │  👤 [Nom d'utilisateur   ]  │    │
│  │                             │    │
│  │  🔒 [Mot de passe     ] 👁  │    │
│  │                             │    │
│  │  ┌─────────────────────┐    │    │
│  │  │    Se connecter     │    │    │
│  │  └─────────────────────┘    │    │
│  │                             │    │
│  │  Pas de compte? S'inscrire  │    │
│  └─────────────────────────────┘    │
│                                     │
│     Continuer sans compte           │
└─────────────────────────────────────┘
```

---

### StatsScreen

**Navigation:** Depuis HomeScreen

```
┌─────────────────────────────────────┐
│  ← Retour        Statistiques       │
├─────────────────────────────────────┤
│            (gradient bg)            │
│                                     │
│  ┌──────────┐  ┌──────────┐         │
│  │ 🎮 15    │  │ 🏆 8     │         │
│  │ Parties  │  │ Victoires│         │
│  └──────────┘  └──────────┘         │
│  ┌──────────┐  ┌──────────┐         │
│  │ % 53.3%  │  │ ⭐ 42    │         │
│  │ Win rate │  │ Best     │         │
│  └──────────┘  └──────────┘         │
│  ┌──────────┐  ┌──────────┐         │
│  │ 📈 28.5  │  │ 📝 156   │         │
│  │ Avg score│  │ Mots     │         │
│  └──────────┘  └──────────┘         │
│                                     │
│  Historique des parties             │
│  ┌─────────────────────────────┐    │
│  │ 🏆 Multi (1/4) 28/01  35pts │    │
│  │ 🎮 Solo       27/01  28pts │    │
│  │ 🎮 Multi (2/3) 27/01  22pts │    │
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

---

## Widgets Reutilisables

### BoggleGrid

**Usage:** GameScreen, ResultsScreen

```
Proprietes:
- letters: List<String>      // 16 lettres
- highlightedPath: List<int> // Chemin a surligner
- isHighlightValid: bool     // Vert ou rouge
- onPathSelected: Function   // Callback soumission
- initialZoom: double        // Niveau de zoom

Interactions:
- Tap sur cellule: Ajoute/retire du chemin
- Drag: Trace un chemin continu
- Bouton vert: Valide le mot
- Bouton rouge: Efface la selection
```

---

### TimerWidget

**Usage:** GameScreen

```
Proprietes:
- remainingSeconds: int
- isRunning: bool

Comportement:
- Affiche MM:SS
- Bleu si > 30s
- Rouge si <= 30s
```

---

### ScoreDisplay

**Usage:** GameScreen

```
Proprietes:
- currentScore: int   // Points cette manche
- totalScore: int     // Score cumule
- wordCount: int      // Nombre de mots

Affichage:
"3 mots | +5 pts"
```

---

### PlayerList

**Usage:** LobbyScreen, GameScreen

```
Proprietes:
- players: List<Player>
- currentPlayerId: String?
- showScores: bool
- showVoteStatus: bool

Elements par joueur:
- Icone d'etat (connecte/pret/jouant/deconnecte)
- Nom
- Badge HOST si applicable
- Badge VOUS si joueur local
- Score (optionnel)
- Vote status (optionnel)
```

---

### WordList / SimpleWordList

**Usage:** GameScreen, ResultsScreen

```
WordList:
- Liste detaillee avec points
- Indication doublons/invalides

SimpleWordList:
- Chips compacts
- Pour affichage rapide
```

---

## Theme et Couleurs

### Palette Principale

| Usage | Couleur |
|-------|---------|
| Primary | Purple (`Colors.purple`) |
| Secondary | Blue (`Colors.blue`) |
| Success | Green (`Colors.green`) |
| Error | Red (`Colors.red`) |
| Warning | Amber (`Colors.amber`) |
| Grid | Brown (`Colors.brown`) |

### Composants

| Composant | Couleur |
|-----------|---------|
| AppBar | Purple |
| Grille fond | Brown[100] |
| Cellule normale | Amber[100] |
| Cellule selectionnee | Blue[200/400] |
| Cellule highlight valid | Green[300] |
| Cellule highlight invalid | Red[300] |
| Timer normal | Blue |
| Timer alerte | Red |
| Mot valide | Green chip |
| Mot doublon | Grey chip |
| Mot invalide | Red chip |

---

## Voir Aussi

- [Composants](./component-inventory.md)
- [Architecture](./architecture.md)
