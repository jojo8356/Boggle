# Froggle - Inventaire des Composants

[Retour a l'index](./index.md)

---

## Services

### GameProvider

**Fichier:** `lib/services/game_provider.dart`
**Role:** Gestionnaire d'etat central du jeu

| Propriete | Type | Description |
|-----------|------|-------------|
| `game` | `Game?` | Etat actuel de la partie |
| `currentPlayerId` | `String?` | ID du joueur local |
| `currentPlayer` | `Player?` | Joueur local (getter) |
| `connectionInfo` | `String?` | Info de connexion a afficher |

| Methode | Description |
|---------|-------------|
| `initConnection()` | Initialise la connexion (host ou join) |
| `startGame()` | Demarre la partie (host uniquement) |
| `submitWord(String)` | Soumet un mot pour validation |
| `submitWordFromPath(List<int>)` | Soumet un mot via chemin sur grille |
| `voteForNewGame()` | Vote pour relancer une partie |
| `replaySameGrid()` | Rejoue la meme grille (solo) |
| `dispose()` | Libere les ressources |

---

### DictionaryService

**Fichier:** `lib/services/dictionary_service.dart`
**Role:** Gestion du dictionnaire francais

| Methode | Description |
|---------|-------------|
| `loadDictionary()` | Charge le dictionnaire en memoire |
| `isValidWord(String)` | Verifie si un mot existe |
| `getWordsWithPrefix(String)` | Retourne les mots avec un prefixe |

**Assets utilises:**
- `assets/dictionnaire_fr.txt`
- `assets/mots_pluriels.txt`
- `assets/mots_conjugues.txt`

---

### GameLogicService

**Fichier:** `lib/services/game_logic_service.dart`
**Role:** Logique de jeu et validation

| Methode | Description |
|---------|-------------|
| `isValidPath(grid, path, word)` | Valide un chemin sur la grille |
| `findWordPath(grid, word)` | Trouve le chemin d'un mot |
| `findAllPossibleWords(grid)` | Liste tous les mots formables |
| `getWordFromPath(grid, path)` | Convertit un chemin en mot |

---

### SettingsService

**Fichier:** `lib/services/settings_service.dart`
**Role:** Preferences utilisateur persistantes

| Propriete | Type | Description |
|-----------|------|-------------|
| `gameDuration` | `int` | Duree de partie en secondes |
| `gridZoom` | `double` | Niveau de zoom de la grille |

| Constante | Valeur |
|-----------|--------|
| `durationOptions` | [60, 90, 120, 180, 240, 300] |
| `minZoom` | 0.5 |
| `maxZoom` | 1.5 |

---

### AuthService

**Fichier:** `lib/services/auth_service.dart`
**Role:** Authentification des utilisateurs

| Propriete | Type | Description |
|-----------|------|-------------|
| `isLoggedIn` | `bool` | Statut de connexion |
| `currentUser` | `User?` | Utilisateur connecte |

| Methode | Retour | Description |
|---------|--------|-------------|
| `register(username, password)` | `AuthResult` | Inscription |
| `login(username, password)` | `AuthResult` | Connexion |
| `logout()` | `void` | Deconnexion |
| `checkAutoLogin()` | `Future` | Connexion automatique |

---

### DatabaseService

**Fichier:** `lib/services/database_service.dart`
**Role:** Persistance SQLite

**Tables:**
- `users` - Comptes utilisateurs
- `matches` - Historique des parties

| Methode | Description |
|---------|-------------|
| `insertUser(User)` | Creer un utilisateur |
| `getUserByUsername(String)` | Rechercher par nom |
| `insertMatch(MatchRecord)` | Enregistrer une partie |
| `getMatchesByUserId(int)` | Historique d'un joueur |
| `getUserStats(int)` | Statistiques agregees |

---

## Connexions

### ConnectionInterface

**Fichier:** `lib/services/connection/connection_interface.dart`
**Role:** Interface abstraite pour les connexions

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

---

### InternetConnection

**Fichier:** `lib/services/connection/internet_connection.dart`
**Role:** Connexion via WebSocket

**Serveur:** WebSocket relay pour la communication host/clients
**Port:** Configure dans l'implementation

---

### WifiDirectConnection

**Fichier:** `lib/services/connection/wifi_direct_connection.dart`
**Role:** Connexion P2P directe (Android/iOS)

**Dependance:** `flutter_p2p_connection`
**Limitation:** Mobile uniquement

---

## Ecrans

### HomeScreen

**Fichier:** `lib/screens/home_screen.dart`
**Role:** Ecran d'accueil et selection du mode

**Fonctionnalites:**
- Affichage du nom du joueur (avec edition)
- Boutons: Solo, Creer partie, Rejoindre partie
- Acces aux parametres, stats, authentification
- Detection des connexions disponibles par plateforme

---

### LobbyScreen

**Fichier:** `lib/screens/lobby_screen.dart`
**Role:** Salle d'attente multijoueur

**Props:**
| Prop | Type | Description |
|------|------|-------------|
| `connectionType` | `ConnectionType` | Type de connexion |
| `playerName` | `String` | Nom du joueur |
| `isHost` | `bool` | Est-ce l'hote? |
| `hostAddress` | `String?` | Adresse de l'hote (si join) |

**Fonctionnalites:**
- Affichage info de connexion (IP pour l'hote)
- Liste des joueurs connectes
- Bouton "Demarrer" (hote uniquement)
- Navigation automatique quand le jeu demarre

---

### GameScreen

**Fichier:** `lib/screens/game_screen.dart`
**Role:** Ecran de jeu principal

**Composants utilises:**
- `BoggleGrid` - Grille de lettres
- `TimerWidget` - Compte a rebours
- `ScoreDisplay` - Score actuel
- `SimpleWordList` - Mots trouves

**Fonctionnalites:**
- Soumission de mots par grille (drag/tap)
- Timer avec alerte fin de temps
- Affichage feedback mot valide/invalide
- Navigation vers resultats a la fin

---

### ResultsScreen

**Fichier:** `lib/screens/results_screen.dart`
**Role:** Affichage des resultats

**Fonctionnalites:**
- Classement des joueurs
- Liste des mots par joueur (expandable)
- Grille de revision avec highlighting
- Section "Mots manques" (expandable)
- Definitions via CNRTL (double-tap sur mot)
- Bouton "Rejouer meme grille" (solo)
- Vote pour nouvelle partie (multi)
- Sauvegarde automatique en BDD

---

### SettingsScreen

**Fichier:** `lib/screens/settings_screen.dart`
**Role:** Configuration du jeu

**Options:**
- Duree de partie (chips selection)
- Zoom de grille (slider avec apercu)

---

### AuthScreen

**Fichier:** `lib/screens/auth_screen.dart`
**Role:** Authentification

**Modes:**
- Connexion (login)
- Inscription (register)
- Continuer sans compte

---

### StatsScreen

**Fichier:** `lib/screens/stats_screen.dart`
**Role:** Statistiques du joueur

**Metriques affichees:**
- Parties jouees
- Victoires
- Taux de victoire
- Meilleur score
- Score moyen
- Total mots trouves
- Historique des parties

---

## Widgets

### BoggleGrid

**Fichier:** `lib/widgets/boggle_grid.dart`
**Role:** Grille de lettres interactive

| Prop | Type | Description |
|------|------|-------------|
| `letters` | `List<String>` | Lettres de la grille |
| `highlightedPath` | `List<int>` | Chemin a surligner |
| `isHighlightValid` | `bool` | Couleur du highlight |
| `onPathSelected` | `Function?` | Callback soumission |
| `initialZoom` | `double` | Niveau de zoom |

**Interactions:**
- Tap: Selection lettre par lettre
- Drag: Tracer un chemin continu
- Bouton vert: Valider le mot
- Bouton rouge: Effacer la selection

---

### TimerWidget

**Fichier:** `lib/widgets/timer_widget.dart`
**Role:** Affichage du temps restant

| Prop | Type | Description |
|------|------|-------------|
| `remainingSeconds` | `int` | Secondes restantes |
| `isRunning` | `bool` | Timer actif? |

**Comportement:** Devient rouge quand < 30 secondes

---

### WordInput

**Fichier:** `lib/widgets/word_input.dart`
**Role:** Saisie manuelle de mots

| Prop | Type | Description |
|------|------|-------------|
| `onWordSubmitted` | `Function(String)` | Callback |
| `enabled` | `bool` | Champ actif? |

---

### WordList / SimpleWordList

**Fichier:** `lib/widgets/word_list.dart`
**Role:** Affichage des mots trouves

**WordList:** Avec details (points, duplicates)
**SimpleWordList:** Version compacte (chips)

---

### PlayerList

**Fichier:** `lib/widgets/player_list.dart`
**Role:** Liste des joueurs

| Prop | Type | Description |
|------|------|-------------|
| `players` | `List<Player>` | Joueurs |
| `currentPlayerId` | `String?` | Joueur local |
| `showScores` | `bool` | Afficher scores? |
| `showVoteStatus` | `bool` | Afficher votes? |

---

### ScoreDisplay

**Fichier:** `lib/widgets/score_display.dart`
**Role:** Badge de score compact

| Prop | Type | Description |
|------|------|-------------|
| `currentScore` | `int` | Points cette manche |
| `totalScore` | `int` | Score total |
| `wordCount` | `int` | Nombre de mots |

---

## Voir Aussi

- [Architecture](./architecture.md)
- [Modeles de donnees](./data-models.md)
