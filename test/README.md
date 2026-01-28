# Tests Froggle

Ce repertoire contient les tests automatises pour l'application Froggle.

## Structure des Tests

```
test/
├── services/                    # Tests unitaires des services
│   ├── game_logic_service_test.dart
│   ├── dictionary_service_test.dart
│   └── auth_service_test.dart
├── models/                      # Tests des modeles de donnees
│   └── game_test.dart
├── widgets/                     # Tests des widgets Flutter
│   ├── boggle_grid_test.dart
│   └── timer_widget_test.dart
├── utils/                       # Tests des utilitaires
│   └── letter_distribution_test.dart
└── widget_test.dart             # Test smoke de l'application

integration_test/
└── app_test.dart                # Tests d'integration
```

## Execution des Tests

### Tous les tests unitaires et widget

```bash
flutter test
```

### Tests d'un fichier specifique

```bash
flutter test test/services/game_logic_service_test.dart
```

### Tests par priorite

```bash
# Tests P0 (critiques)
flutter test --tags P0

# Tests P1 (haute priorite)
flutter test --tags P1
```

### Tests d'integration

```bash
flutter test integration_test/app_test.dart
```

### Tests avec couverture

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Convention de Priorite

Chaque test est marque avec une priorite dans son nom:

| Tag | Priorite | Description | Execution |
|-----|----------|-------------|-----------|
| `[P0]` | Critique | Chemins critiques, doivent toujours passer | Chaque commit |
| `[P1]` | Haute | Fonctionnalites importantes | PR vers main |
| `[P2]` | Moyenne | Cas limites, variations | Nightly |
| `[P3]` | Basse | Nice-to-have | On-demand |

## Patterns de Test

### Format Given-When-Then

Tous les tests suivent le format Given-When-Then:

```dart
test('[P0] devrait valider un chemin adjacent', () {
  // GIVEN: Un chemin pour le mot "FROG"
  final path = [0, 1, 2, 3];

  // WHEN: On verifie si le chemin est valide
  final result = gameLogicService.isValidPath(grid, path, 'FROG');

  // THEN: Le chemin devrait etre valide
  expect(result, isTrue);
});
```

### Widget Tests

```dart
testWidgets('[P1] devrait afficher le temps', (tester) async {
  // GIVEN: Un timer widget
  await tester.pumpWidget(MaterialApp(
    home: TimerWidget(remainingSeconds: 60),
  ));

  // WHEN: Le widget est rendu
  // THEN: Le temps devrait etre affiche
  expect(find.text('01:00'), findsOneWidget);
});
```

## Services Testes

### GameLogicService
- Validation des chemins sur la grille
- Conversion chemin vers mot
- Recherche de chemins pour un mot
- Detection d'adjacence

### DictionaryService
- Validation des mots
- Regles de longueur minimale

### AuthService
- Hachage de mots de passe
- Validation des entrees

## Modeles Testes

### Game
- Creation de partie
- Gestion des joueurs
- Transitions d'etat
- Calcul des points

### Player
- Creation de joueur
- Gestion du score
- Liste des mots trouves

### Word
- Creation de mot
- Points effectifs (doublons, invalides)

## Widgets Testes

### BoggleGrid
- Affichage des lettres
- Calcul de la taille de grille
- Highlighting des chemins

### TimerWidget
- Affichage du temps MM:SS
- Changement de couleur (alerte < 30s)

## Ajout de Nouveaux Tests

1. Creer le fichier dans le bon repertoire
2. Suivre le format Given-When-Then
3. Ajouter le tag de priorite `[P0]`, `[P1]`, `[P2]`, ou `[P3]`
4. Executer le test localement avant de commit
