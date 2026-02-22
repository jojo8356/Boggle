# Froggle - Documentation du Projet

> Jeu de Boggle multijoueur en francais - Application Flutter multi-plateforme

**Derniere mise a jour:** 2026-01-28
**Version de documentation:** 1.0.0

---

## Navigation Rapide

| Document | Description |
|----------|-------------|
| [Vue d'ensemble](./project-overview.md) | Vision globale du projet, objectifs et fonctionnalites |
| [Architecture](./architecture.md) | Architecture technique, patterns et decisions |
| [Arborescence](./source-tree-analysis.md) | Structure des fichiers et organisation du code |
| [Composants](./component-inventory.md) | Inventaire detaille des composants |
| [Modeles de donnees](./data-models.md) | Schemas et modeles de donnees |
| [Composants UI](./ui-components.md) | Widgets et ecrans de l'interface |

---

## Informations du Projet

| Attribut | Valeur |
|----------|--------|
| **Nom** | Froggle |
| **Type** | Application mobile (Flutter) |
| **Langage** | Dart |
| **Framework** | Flutter 3.9.2+ |
| **Gestion d'etat** | Provider |
| **Plateformes** | Android, iOS, macOS, Linux, Windows, Web |

---

## Stack Technique

### Core
- **Flutter** 3.9.2+ - Framework UI multi-plateforme
- **Dart** - Langage de programmation
- **Provider** 6.1.2 - Gestion d'etat reactive

### Connectivite
- **flutter_blue_plus** - Connexion Bluetooth
- **flutter_p2p_connection** - WiFi Direct (mobile)
- **web_socket_channel** - WebSocket pour Internet

### Persistance
- **sqflite** - Base de donnees SQLite locale
- **shared_preferences** - Stockage cle-valeur

### Utilitaires
- **crypto** - Hachage de mots de passe
- **http** - Requetes HTTP
- **uuid** - Generation d'identifiants uniques
- **url_launcher** - Ouverture de liens externes

---

## Demarrage Rapide

```bash
# Cloner le projet
git clone <repository-url>
cd Froggle

# Installer les dependances
flutter pub get

# Lancer l'application
flutter run
```

---

## Structure du Projet

```
lib/
├── main.dart              # Point d'entree
├── config/                # Configuration du jeu
├── models/                # Modeles de donnees
├── screens/               # Ecrans de l'application
├── services/              # Logique metier
│   └── connection/        # Couche de connexion
├── utils/                 # Utilitaires
└── widgets/               # Composants UI reutilisables
```

---

## Fonctionnalites Principales

1. **Jeu de Boggle** - Grille 4x4 avec des lettres, trouver des mots
2. **Multijoueur** - Jouer avec d'autres joueurs via Internet ou WiFi Direct
3. **Mode Solo** - Jouer seul et ameliorer son score
4. **Dictionnaire francais** - Validation des mots en francais
5. **Statistiques** - Suivi des performances et historique des parties
6. **Authentification** - Systeme de comptes utilisateurs local

---

## Liens Utiles

- [README principal](../README.md)
- [Configuration du jeu](./architecture.md#configuration)
- [Guide de contribution](./development-guide.md)
