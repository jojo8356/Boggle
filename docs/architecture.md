# Froggle - Architecture Technique

[Retour a l'index](./index.md)

---

## Vue d'Ensemble

Froggle utilise une architecture en couches avec separation des responsabilites:

```
┌─────────────────────────────────────────────────────────┐
│                      Presentation                        │
│  (screens/, widgets/)                                   │
├─────────────────────────────────────────────────────────┤
│                    State Management                      │
│  (GameProvider via Provider)                            │
├─────────────────────────────────────────────────────────┤
│                    Business Logic                        │
│  (services/)                                            │
├─────────────────────────────────────────────────────────┤
│                    Data Layer                            │
│  (models/, DatabaseService)                             │
├─────────────────────────────────────────────────────────┤
│                 Connection Abstraction                   │
│  (services/connection/)                                 │
└─────────────────────────────────────────────────────────┘
```

---

## Couches Applicatives

### 1. Presentation Layer (`screens/`, `widgets/`)

Responsable de l'affichage et des interactions utilisateur.

**Ecrans:**
- `HomeScreen` - Ecran d'accueil avec selection du mode de jeu
- `LobbyScreen` - Salle d'attente multijoueur
- `GameScreen` - Ecran de jeu principal
- `ResultsScreen` - Resultats de fin de partie
- `SettingsScreen` - Configuration du jeu
- `AuthScreen` - Authentification utilisateur
- `StatsScreen` - Statistiques du joueur

**Widgets:**
- `BoggleGrid` - Grille de lettres interactive
- `TimerWidget` - Affichage du compte a rebours
- `WordInput` - Saisie de mots au clavier
- `WordList` - Liste des mots trouves
- `PlayerList` - Liste des joueurs
- `ScoreDisplay` - Affichage du score

### 2. State Management (`GameProvider`)

Le `GameProvider` est le coeur de la gestion d'etat:

```dart
class GameProvider extends ChangeNotifier {
  Game? _game;                    // Etat du jeu actuel
  ConnectionInterface? _connection; // Connexion active
  String? _currentPlayerId;       // ID du joueur local

  // Methodes principales
  Future<void> initConnection(...);  // Initialiser la connexion
  void startGame();                   // Demarrer le jeu
  void submitWord(String word);       // Soumettre un mot
  void endGame();                     // Terminer la partie
}
```

**Pattern utilise:** Provider avec `ChangeNotifier`

### 3. Business Logic (`services/`)

| Service | Responsabilite |
|---------|----------------|
| `GameLogicService` | Validation des mots, calcul des chemins, recherche exhaustive |
| `DictionaryService` | Chargement et recherche dans le dictionnaire |
| `SettingsService` | Gestion des preferences utilisateur |
| `AuthService` | Authentification et gestion des utilisateurs |
| `DatabaseService` | Persistance SQLite |

### 4. Connection Layer (`services/connection/`)

Abstraction des methodes de connexion via interface:

```dart
abstract class ConnectionInterface {
  Stream<Map<String, dynamic>> get messageStream;
  String? get connectionInfo;

  Future<void> startHost(String playerName);
  Future<void> joinGame(String hostAddress, String playerName);
  void sendMessage(Map<String, dynamic> message);
  void dispose();
}
```

**Implementations:**
- `InternetConnection` - WebSocket via serveur relay
- `WifiDirectConnection` - Connexion P2P directe (mobile)
- `WifiDirectConnectionStub` - Stub pour plateformes non supportees

---

## Modele de Donnees

### Entites Principales

```
┌─────────────┐       ┌─────────────┐
│    Game     │ 1───* │   Player    │
├─────────────┤       ├─────────────┤
│ id          │       │ id          │
│ state       │       │ name        │
│ grid        │       │ score       │
│ roundNumber │       │ isHost      │
│ players[]   │       │ foundWords[]│
│ allWords[]  │       │ state       │
│ timeLeft    │       └─────────────┘
└─────────────┘
        │
        │ *
        ▼
┌─────────────┐
│    Word     │
├─────────────┤
│ text        │
│ playerId    │
│ points      │
│ isDuplicate │
│ isInvalid   │
│ timestamp   │
└─────────────┘
```

### Modeles de Persistance

```
┌─────────────┐       ┌───────────────┐
│    User     │ 1───* │  MatchRecord  │
├─────────────┤       ├───────────────┤
│ id          │       │ id            │
│ username    │       │ userId        │
│ passwordHash│       │ playedAt      │
│ createdAt   │       │ score         │
└─────────────┘       │ wordsFound    │
                      │ validWords    │
                      │ rank          │
                      │ totalPlayers  │
                      │ isWin         │
                      │ isSolo        │
                      └───────────────┘
```

---

## Configuration

### GameConfig (`lib/config/game_config.dart`)

```dart
class GameConfig {
  static const int gridSize = 4;              // Taille de la grille
  static const int gameDurationSeconds = 180; // Duree en secondes
  static const int maxPlayers = 6;            // Max joueurs
  static const int minWordLength = 3;         // Longueur min mot

  static int getPoints(int wordLength) {...}  // Calcul points
}
```

### SettingsService (Preferences utilisateur)

- Duree de partie configurable (60s - 300s)
- Zoom de la grille (0.5x - 1.5x)
- Persistance via `shared_preferences`

---

## Flux de Communication Multijoueur

### Messages Reseau

| Type | Direction | Description |
|------|-----------|-------------|
| `player_joined` | Host -> All | Nouveau joueur connecte |
| `game_start` | Host -> All | Demarrage du jeu avec grille |
| `word_submitted` | Player -> Host | Mot soumis par un joueur |
| `word_broadcast` | Host -> All | Diffusion du mot valide |
| `game_end` | Host -> All | Fin de la partie |
| `vote_new_game` | Player -> Host | Vote pour nouvelle partie |
| `new_game` | Host -> All | Nouvelle partie demarre |

### Protocole de Jeu

```
1. Connexion
   Client ──[join]──> Host
   Host ──[player_joined]──> All Clients

2. Demarrage
   Host ──[game_start + grid]──> All Clients

3. Gameplay
   Client ──[word_submitted]──> Host
   Host: Valide le mot
   Host ──[word_broadcast]──> All Clients

4. Fin de partie
   Timer expire
   Host ──[game_end + results]──> All Clients

5. Replay
   Client ──[vote_new_game]──> Host
   Tous votes? Host ──[new_game]──> All
```

---

## Algorithmes Cles

### Validation de Chemin

```dart
// Verifie qu'un chemin forme le mot sur la grille
bool isValidPath(List<String> grid, List<int> path, String word) {
  // 1. Verifier que le chemin a la bonne longueur
  // 2. Verifier que chaque case est adjacente a la precedente
  // 3. Verifier que les lettres correspondent au mot
}
```

### Recherche de Tous les Mots Possibles

```dart
// DFS pour trouver tous les mots formables dans la grille
List<String> findAllPossibleWords(List<String> grid) {
  // Pour chaque case de depart:
  //   DFS recursif avec backtracking
  //   Pruning via prefixes du dictionnaire (Trie)
  //   Collecter les mots valides
}
```

### Generation de Grille

```dart
// Utilise les 16 des officiels du Boggle francais
List<String> generateGrid(int size) {
  // 1. Melanger les 16 des
  // 2. Lancer chaque de (choisir une face)
  // 3. Retourner la grille
}
```

---

## Decisions Architecturales

### Pourquoi Provider?

- Simplicite d'integration avec Flutter
- Pas de boilerplate excessif
- Suffisant pour la taille du projet
- Bonne performance pour les mises a jour frequentes

### Pourquoi SQLite?

- Persistance locale sans serveur
- Support multi-plateforme via sqflite
- Requetes SQL pour statistiques complexes

### Pourquoi Interface de Connexion?

- Decouplage des methodes de transport
- Facilite l'ajout de nouveaux modes (Bluetooth prevu)
- Testabilite amelioree

---

## Voir Aussi

- [Composants](./component-inventory.md)
- [Modeles de donnees](./data-models.md)
