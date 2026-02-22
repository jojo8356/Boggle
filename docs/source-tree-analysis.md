# Froggle - Analyse de l'Arborescence Source

[Retour a l'index](./index.md)

---

## Structure Globale

```
Froggle/
├── lib/                          # Code source Dart principal
│   ├── main.dart                 # Point d'entree de l'application
│   ├── config/                   # Configuration du jeu
│   ├── models/                   # Modeles de donnees
│   ├── screens/                  # Ecrans de l'application
│   ├── services/                 # Services et logique metier
│   │   └── connection/           # Abstraction des connexions
│   ├── utils/                    # Utilitaires
│   └── widgets/                  # Composants UI reutilisables
├── assets/                       # Ressources statiques
├── test/                         # Tests unitaires et widgets
├── android/                      # Configuration Android native
├── ios/                          # Configuration iOS native
├── linux/                        # Configuration Linux native
├── macos/                        # Configuration macOS native
├── windows/                      # Configuration Windows native
├── web/                          # Configuration Web
├── docs/                         # Documentation du projet
├── pubspec.yaml                  # Dependances et configuration Flutter
└── README.md                     # Documentation principale
```

---

## Repertoire `lib/` - Detail

### Point d'Entree

| Fichier | Lignes | Description |
|---------|--------|-------------|
| `main.dart` | ~50 | Initialisation de l'app, configuration des providers |

### Configuration (`config/`)

| Fichier | Lignes | Description |
|---------|--------|-------------|
| `game_config.dart` | ~25 | Constantes du jeu (taille grille, duree, points) |

### Modeles (`models/`)

| Fichier | Lignes | Description |
|---------|--------|-------------|
| `game.dart` | ~100 | Etat complet d'une partie |
| `player.dart` | ~60 | Donnees d'un joueur |
| `word.dart` | ~40 | Mot trouve avec metadonnees |
| `game_result.dart` | ~80 | Resultats de fin de partie |
| `user.dart` | ~30 | Utilisateur authentifie |
| `match_record.dart` | ~50 | Historique d'une partie jouee |

### Ecrans (`screens/`)

| Fichier | Lignes | Description |
|---------|--------|-------------|
| `home_screen.dart` | ~400 | Ecran d'accueil, selection mode |
| `lobby_screen.dart` | ~240 | Salle d'attente multijoueur |
| `game_screen.dart` | ~350 | Ecran de jeu principal |
| `results_screen.dart` | ~1300 | Resultats detailles, mots manques |
| `settings_screen.dart` | ~195 | Parametres utilisateur |
| `auth_screen.dart` | ~190 | Connexion/inscription |
| `stats_screen.dart` | ~300 | Statistiques du joueur |

### Services (`services/`)

| Fichier | Lignes | Description |
|---------|--------|-------------|
| `game_provider.dart` | ~450 | Gestion d'etat centrale |
| `dictionary_service.dart` | ~100 | Chargement et recherche dictionnaire |
| `game_logic_service.dart` | ~250 | Validation mots, calcul chemins |
| `settings_service.dart` | ~80 | Preferences persistantes |
| `auth_service.dart` | ~100 | Authentification utilisateurs |
| `database_service.dart` | ~200 | Persistance SQLite |

### Connexions (`services/connection/`)

| Fichier | Lignes | Description |
|---------|--------|-------------|
| `connection_interface.dart` | ~30 | Interface abstraite |
| `internet_connection.dart` | ~200 | Implementation WebSocket |
| `wifi_direct_connection.dart` | ~150 | Implementation WiFi Direct |
| `wifi_direct_connection_stub.dart` | ~30 | Stub pour plateformes non supportees |

### Utilitaires (`utils/`)

| Fichier | Lignes | Description |
|---------|--------|-------------|
| `constants.dart` | ~20 | Enums et constantes globales |
| `letter_distribution.dart` | ~45 | Des du Boggle et generation grille |
| `platform_utils.dart` | ~30 | Detection de plateforme |

### Widgets (`widgets/`)

| Fichier | Lignes | Description |
|---------|--------|-------------|
| `boggle_grid.dart` | ~500 | Grille interactive avec drag/tap |
| `timer_widget.dart` | ~50 | Affichage compte a rebours |
| `word_input.dart` | ~120 | Champ de saisie de mots |
| `word_list.dart` | ~130 | Liste des mots trouves |
| `player_list.dart` | ~180 | Liste des joueurs |
| `score_display.dart` | ~55 | Badge de score |

---

## Repertoire `assets/`

| Fichier | Description |
|---------|-------------|
| `dictionnaire_fr.txt` | Dictionnaire francais principal |
| `mots_pluriels.txt` | Formes plurielles |
| `mots_conjugues.txt` | Formes conjuguees |

---

## Repertoire `test/`

| Fichier | Description |
|---------|-------------|
| `widget_test.dart` | Test widget de base Flutter |

---

## Fichiers de Configuration

| Fichier | Description |
|---------|-------------|
| `pubspec.yaml` | Dependances Flutter et metadonnees |
| `pubspec.lock` | Versions verrouillees des dependances |
| `analysis_options.yaml` | Configuration du linter Dart |

---

## Statistiques du Code

| Categorie | Fichiers | Lignes (approx.) |
|-----------|----------|------------------|
| Models | 6 | ~360 |
| Screens | 7 | ~2975 |
| Services | 6 | ~1180 |
| Connexions | 4 | ~410 |
| Widgets | 6 | ~1035 |
| Utils | 3 | ~95 |
| Config | 1 | ~25 |
| **Total lib/** | **33** | **~6080** |

---

## Dependances entre Modules

```
main.dart
    │
    ├── screens/*
    │       │
    │       ├── services/game_provider.dart
    │       │       │
    │       │       ├── models/*
    │       │       ├── services/connection/*
    │       │       ├── services/dictionary_service.dart
    │       │       └── services/game_logic_service.dart
    │       │
    │       ├── services/auth_service.dart
    │       │       └── services/database_service.dart
    │       │
    │       ├── services/settings_service.dart
    │       │
    │       └── widgets/*
    │               └── models/*
    │
    └── utils/*
            └── config/*
```

---

## Points d'Attention

### Fichiers Volumineux
- `results_screen.dart` (~1300 lignes) - Pourrait etre decoupe en sous-composants
- `boggle_grid.dart` (~500 lignes) - Logique complexe de selection

### Fichiers Non Utilises
- Aucun fichier orphelin detecte

### Tests
- Couverture de tests minimale (1 fichier de test)
- Recommandation: Ajouter des tests pour les services critiques

---

## Voir Aussi

- [Architecture](./architecture.md)
- [Composants](./component-inventory.md)
