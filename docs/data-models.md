# Froggle - Modeles de Donnees

[Retour a l'index](./index.md)

---

## Vue d'Ensemble

```
┌─────────────────────────────────────────────────────────────┐
│                    Modeles en Memoire                        │
│  (Etat du jeu actif)                                        │
├─────────────────────────────────────────────────────────────┤
│   Game ──────┬────── Player                                 │
│              │                                              │
│              └────── Word                                   │
│                                                             │
│   GameResult ────── PlayerResult                            │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    Modeles Persistants                       │
│  (Base de donnees SQLite)                                   │
├─────────────────────────────────────────────────────────────┤
│   User ──────────── MatchRecord                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Modeles en Memoire

### Game

**Fichier:** `lib/models/game.dart`
**Description:** Represente l'etat complet d'une partie en cours

```dart
class Game {
  final String id;
  GameState state;           // waiting, playing, finished
  final List<String> grid;   // 16 lettres (4x4)
  final List<Player> players;
  final List<Word> allWords; // Tous les mots soumis
  int roundNumber;
  int timeRemaining;

  // Getters
  bool get isPlaying;
  bool get isFinished;
}
```

| Champ | Type | Description |
|-------|------|-------------|
| `id` | `String` | Identifiant unique de la partie |
| `state` | `GameState` | Etat actuel (waiting/playing/finished) |
| `grid` | `List<String>` | 16 lettres de la grille |
| `players` | `List<Player>` | Joueurs de la partie |
| `allWords` | `List<Word>` | Tous les mots soumis |
| `roundNumber` | `int` | Numero de la manche |
| `timeRemaining` | `int` | Temps restant en secondes |

---

### Player

**Fichier:** `lib/models/player.dart`
**Description:** Represente un joueur dans une partie

```dart
class Player {
  final String id;
  final String name;
  int score;
  bool isHost;
  PlayerState state;         // connected, ready, playing, disconnected
  List<String> foundWords;
  bool votedForNewGame;

  // Methodes
  void addWord(String word);
  void addScore(int points);
}
```

| Champ | Type | Description |
|-------|------|-------------|
| `id` | `String` | Identifiant unique du joueur |
| `name` | `String` | Nom affiche |
| `score` | `int` | Score cumule |
| `isHost` | `bool` | Est l'hote de la partie |
| `state` | `PlayerState` | Etat de connexion |
| `foundWords` | `List<String>` | Mots trouves (texte) |
| `votedForNewGame` | `bool` | A vote pour rejouer |

---

### Word

**Fichier:** `lib/models/word.dart`
**Description:** Represente un mot soumis par un joueur

```dart
class Word {
  final String text;
  final String playerId;
  final int points;
  bool isDuplicate;
  bool isInvalid;
  final DateTime timestamp;

  // Getter
  int get effectivePoints;  // 0 si duplicate ou invalid
}
```

| Champ | Type | Description |
|-------|------|-------------|
| `text` | `String` | Le mot en majuscules |
| `playerId` | `String` | ID du joueur qui l'a soumis |
| `points` | `int` | Points potentiels (selon longueur) |
| `isDuplicate` | `bool` | Trouve par un autre joueur |
| `isInvalid` | `bool` | N'existe pas dans le dictionnaire |
| `timestamp` | `DateTime` | Moment de la soumission |

---

### GameResult

**Fichier:** `lib/models/game_result.dart`
**Description:** Resultats agreges d'une partie

```dart
class GameResult {
  final List<PlayerResult> playerResults;
  final int roundNumber;

  // Methodes
  List<PlayerResult> getRanking();  // Trie par score
}
```

---

### PlayerResult

**Fichier:** `lib/models/game_result.dart`
**Description:** Resultat d'un joueur pour une manche

```dart
class PlayerResult {
  final String playerId;
  final String playerName;
  final List<Word> words;
  final int roundScore;
  final int totalScore;
}
```

| Champ | Type | Description |
|-------|------|-------------|
| `playerId` | `String` | ID du joueur |
| `playerName` | `String` | Nom affiche |
| `words` | `List<Word>` | Mots soumis cette manche |
| `roundScore` | `int` | Points cette manche |
| `totalScore` | `int` | Score cumule |

---

## Modeles Persistants (SQLite)

### User

**Fichier:** `lib/models/user.dart`
**Table:** `users`

```dart
class User {
  final int? id;
  final String username;
  final String passwordHash;
  final DateTime createdAt;

  // Serialisation
  Map<String, dynamic> toMap();
  factory User.fromMap(Map<String, dynamic>);
}
```

**Schema SQL:**
```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  created_at TEXT NOT NULL
);
```

---

### MatchRecord

**Fichier:** `lib/models/match_record.dart`
**Table:** `matches`

```dart
class MatchRecord {
  final int? id;
  final int userId;
  final DateTime playedAt;
  final int score;
  final int wordsFound;
  final int validWords;
  final int rank;
  final int totalPlayers;
  final bool isWin;
  final bool isSolo;
  final int gameDuration;

  // Serialisation
  Map<String, dynamic> toMap();
  factory MatchRecord.fromMap(Map<String, dynamic>);
}
```

**Schema SQL:**
```sql
CREATE TABLE matches (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  played_at TEXT NOT NULL,
  score INTEGER NOT NULL,
  words_found INTEGER NOT NULL,
  valid_words INTEGER NOT NULL,
  rank INTEGER NOT NULL,
  total_players INTEGER NOT NULL,
  is_win INTEGER NOT NULL,
  is_solo INTEGER NOT NULL,
  game_duration INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id)
);
```

---

## Enumerations

### GameState

**Fichier:** `lib/utils/constants.dart`

```dart
enum GameState {
  waiting,   // En attente de joueurs
  playing,   // Partie en cours
  finished   // Partie terminee
}
```

---

### PlayerState

**Fichier:** `lib/utils/constants.dart`

```dart
enum PlayerState {
  connected,    // Connecte, pas encore pret
  ready,        // Pret a jouer
  playing,      // En train de jouer
  disconnected  // Deconnecte
}
```

---

### ConnectionType

**Fichier:** `lib/utils/constants.dart`

```dart
enum ConnectionType {
  internet,    // WebSocket via serveur
  bluetooth,   // Bluetooth (prevu)
  wifiDirect   // WiFi Direct P2P
}
```

---

## Relations entre Modeles

```
Game (1) ─────────< (*) Player
  │
  └───────────────< (*) Word
                         │
                         └── playerId ──> Player.id

User (1) ─────────< (*) MatchRecord
```

---

## Flux de Donnees

### Creation d'une Partie
```
1. GameProvider.initConnection()
   └── Cree Game avec state=waiting
       └── Ajoute Player local

2. Joueurs rejoignent
   └── Ajoute Player a Game.players

3. GameProvider.startGame()
   └── Game.state = playing
   └── Genere Game.grid
   └── Demarre timer
```

### Soumission d'un Mot
```
1. GameProvider.submitWord(text)
   └── Valide dans DictionaryService
   └── Valide chemin dans GameLogicService
   └── Cree Word
   └── Ajoute a Game.allWords
   └── Met a jour Player.score
```

### Fin de Partie
```
1. Timer expire
   └── Game.state = finished
   └── Calcule duplicates dans Game.allWords
   └── Cree GameResult

2. Si User connecte
   └── Cree MatchRecord
   └── Sauvegarde via DatabaseService
```

---

## Voir Aussi

- [Architecture](./architecture.md)
- [Composants](./component-inventory.md)
