# Froggle

Un jeu de Boggle multijoueur en français, développé avec Flutter.

## Fonctionnalités

### Gameplay
- Grille 4x4 (16 lettres) avec distribution pondérée pour le français
- Timer de 3 minutes par manche
- Validation instantanée des mots avec feedback visuel
- Dictionnaire français complet (~336 000 mots)
- Sélection tactile des lettres par glissement sur la grille

### Multijoueur
- Jusqu'à 6 joueurs simultanés
- 3 modes de connexion :
  - **Internet** : WebSocket peer-to-peer (un joueur héberge)
  - **Bluetooth** : Connexion BLE entre appareils
  - **WiFi Direct** : Sans routeur, connexion directe P2P

### Règles du jeu
- Former des mots en reliant des lettres adjacentes (horizontale, verticale, diagonale)
- Chaque lettre ne peut être utilisée qu'une fois par mot
- Minimum 3 lettres par mot
- Les accents sont ignorés (E = É = È = Ê)

### Système de points
| Longueur | Points |
|----------|--------|
| 3-4 lettres | 1 |
| 5 lettres | 2 |
| 6 lettres | 3 |
| 7 lettres | 5 |
| 8+ lettres | 11 |

### Fin de manche
- Les mots trouvés par plusieurs joueurs sont barrés et ne rapportent aucun point
- Affichage du classement et des scores cumulés
- Nouvelle partie uniquement si tous les joueurs votent pour

## Installation

### Prérequis
- Flutter SDK >= 3.9.2
- Android Studio / Xcode pour le développement mobile

### Lancer le projet
```bash
# Cloner le projet
git clone <repo-url>
cd Froggle

# Installer les dépendances
flutter pub get

# Lancer l'application
flutter run
```

## Architecture

```
lib/
├── main.dart                     # Point d'entrée
├── models/                       # Modèles de données
│   ├── player.dart
│   ├── game.dart
│   ├── word.dart
│   └── game_result.dart
├── services/                     # Logique métier
│   ├── dictionary_service.dart   # Gestion du dictionnaire
│   ├── game_logic_service.dart   # Validation des mots
│   ├── game_provider.dart        # State management
│   └── connection/               # Modules de connexion
│       ├── connection_interface.dart
│       ├── internet_connection.dart
│       ├── bluetooth_connection.dart
│       └── wifi_direct_connection.dart
├── screens/                      # Écrans de l'app
│   ├── home_screen.dart
│   ├── lobby_screen.dart
│   ├── game_screen.dart
│   └── results_screen.dart
├── widgets/                      # Composants UI
│   ├── boggle_grid.dart
│   ├── timer_widget.dart
│   ├── word_input.dart
│   ├── word_list.dart
│   ├── score_display.dart
│   └── player_list.dart
└── utils/
    ├── constants.dart
    └── letter_distribution.dart
```

## Permissions requises

### Android
- `INTERNET` - Connexion réseau
- `BLUETOOTH`, `BLUETOOTH_SCAN`, `BLUETOOTH_CONNECT` - Mode Bluetooth
- `ACCESS_WIFI_STATE`, `CHANGE_WIFI_STATE` - Mode WiFi Direct
- `ACCESS_FINE_LOCATION` - Requis pour WiFi Direct et BLE

### iOS
Les permissions sont configurées dans `Info.plist`.

## Technologies utilisées

- **Flutter** - Framework UI cross-platform
- **Provider** - State management
- **flutter_blue_plus** - Bluetooth Low Energy
- **flutter_p2p_connection** - WiFi Direct P2P
- **web_socket_channel** - WebSocket pour le mode Internet

## Licence

MIT
