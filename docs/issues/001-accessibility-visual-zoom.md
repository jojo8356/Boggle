# Issue #1 : Accessibilite Visuelle - Zoom de Grille

**Branche:** `fix/ux-accessibility-visual-zoom`
**Priorite:** P0 (Critique)
**Reporter:** Mme Pavochko (utilisatrice anonyme)
**Assignee:** Marco (Flutter Expert)

---

## Probleme

> "Les lettres sont TROP PETITES ! Meme avec mes lunettes, je dois plisser les yeux."
> — Mme Pavochko, 67 ans

### Contexte
- Une option de zoom existe dans `SettingsScreen` (0.5x - 1.5x)
- Mais les utilisateurs ne la trouvent PAS
- Le zoom par defaut (1.0) est insuffisant pour les seniors

### Impact Utilisateur
- Seniors (public cible du Boggle) ne peuvent pas jouer confortablement
- Abandon de l'application apres quelques minutes
- Frustration et mauvaise experience

---

## Solution Proposee

### 1. Zoom par defaut plus grand
```dart
// lib/services/settings_service.dart
// Changer la valeur par defaut
static const double defaultGridZoom = 1.2; // etait 1.0
```

### 2. Bouton de zoom rapide sur l'ecran de jeu
```dart
// lib/screens/game_screen.dart
// Ajouter un bouton flottant pour ajuster le zoom rapidement
FloatingActionButton(
  mini: true,
  child: Icon(Icons.zoom_in),
  onPressed: () => _showZoomSlider(context),
)
```

### 3. Detection automatique de la taille d'ecran
```dart
// Ajuster le zoom automatiquement selon la taille de l'ecran
double getRecommendedZoom(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  if (screenWidth < 400) return 1.3; // Petits telephones
  if (screenWidth < 600) return 1.1; // Telephones normaux
  return 1.0; // Tablettes
}
```

### 4. Option "Mode Senior" dans les parametres
- Checkbox qui active :
  - Zoom 1.4x
  - Police plus grande partout
  - Contraste augmente

---

## Fichiers a Modifier

| Fichier | Modification |
|---------|--------------|
| `lib/services/settings_service.dart` | Augmenter zoom par defaut |
| `lib/screens/game_screen.dart` | Ajouter bouton zoom rapide |
| `lib/screens/settings_screen.dart` | Ajouter "Mode Senior" |
| `lib/widgets/boggle_grid.dart` | Supporter zoom dynamique |

---

## Criteres d'Acceptation

- [ ] Le zoom par defaut est 1.2x au lieu de 1.0x
- [ ] Un bouton de zoom rapide est visible sur l'ecran de jeu
- [ ] Le zoom s'ajuste automatiquement selon la taille d'ecran
- [ ] Une option "Mode Senior" est disponible dans les parametres
- [ ] Mme Pavochko peut lire les lettres sans plisser les yeux

---

## Tests

```dart
test('[P0] devrait avoir un zoom par defaut de 1.2', () {
  final settings = SettingsService();
  expect(settings.gridZoom, equals(1.2));
});

testWidgets('[P0] devrait afficher le bouton zoom sur GameScreen', (tester) async {
  // ...
  expect(find.byIcon(Icons.zoom_in), findsOneWidget);
});
```
