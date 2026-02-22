# Issue #2 : Onboarding - Tutoriel Interactif

**Branche:** `fix/ux-onboarding-tutorial`
**Priorite:** P0 (Critique)
**Reporter:** Mme Pavochko (utilisatrice anonyme)
**Assignee:** Marco (Flutter Expert)

---

## Probleme

> "Je ne comprends pas comment selectionner les mots ! J'ai tape sur les lettres, rien ne se passe. Puis j'ai fait glisser mon doigt et... ah ! Ca marche ! Mais personne ne m'a explique ca !"
> — Mme Pavochko

### Contexte
- AUCUN tutoriel n'existe dans l'application
- L'interaction drag-to-select est invisible pour les nouveaux utilisateurs
- Les boutons valider/annuler apparaissent sans explication

### Impact Utilisateur
- "Moment de friction fatale" - beaucoup abandonnent ici
- Confusion sur les regles du jeu (longueur min, adjacence)
- Utilisateurs decouvrent les fonctionnalites par accident

---

## Solution Proposee

### 1. Tutoriel au premier lancement
```dart
// lib/screens/tutorial_screen.dart (NOUVEAU)
class TutorialScreen extends StatefulWidget {
  // 4 etapes avec animations
  // 1. "Bienvenue dans Froggle !"
  // 2. "Glissez votre doigt pour former des mots"
  // 3. "Validez avec le bouton vert"
  // 4. "Trouvez un maximum de mots en 3 minutes !"
}
```

### 2. Overlay d'aide contextuelle
```dart
// Au premier jeu, afficher des bulles d'aide
class HelpOverlay extends StatelessWidget {
  // Bulle pointant vers la grille : "Glissez pour selectionner"
  // Bulle pointant vers le timer : "Temps restant"
  // Bulle pointant vers le score : "Vos points"
}
```

### 3. Animation de demonstration
```dart
// Animation montrant un doigt qui trace un mot
class DemoAnimation extends StatefulWidget {
  // Montre visuellement comment tracer "MOT" sur la grille
  // Se joue automatiquement au premier lancement
}
```

### 4. Bouton "?" permanent
```dart
// Ajouter un bouton aide sur GameScreen
IconButton(
  icon: Icon(Icons.help_outline),
  onPressed: () => _showQuickHelp(context),
)
```

### 5. Preference "Ne plus afficher"
```dart
// lib/services/settings_service.dart
bool get hasSeenTutorial => _prefs.getBool('has_seen_tutorial') ?? false;
Future<void> setTutorialSeen() => _prefs.setBool('has_seen_tutorial', true);
```

---

## Fichiers a Creer/Modifier

| Fichier | Action |
|---------|--------|
| `lib/screens/tutorial_screen.dart` | CREER - Ecran tutoriel |
| `lib/widgets/help_overlay.dart` | CREER - Overlay d'aide |
| `lib/widgets/demo_animation.dart` | CREER - Animation demo |
| `lib/screens/home_screen.dart` | Rediriger vers tutoriel si premier lancement |
| `lib/screens/game_screen.dart` | Ajouter bouton aide |
| `lib/services/settings_service.dart` | Ajouter preference tutoriel |
| `lib/main.dart` | Verifier si tutoriel vu |

---

## Flux Utilisateur

```
Premier lancement
       |
       v
[TutorialScreen] --> 4 etapes avec "Suivant"
       |
       v
[HomeScreen] --> Jeu normal
       |
       v
[GameScreen] --> Overlay d'aide (premiere fois)
       |
       v
Jeu normal (aide accessible via bouton ?)
```

---

## Criteres d'Acceptation

- [ ] Un tutoriel s'affiche au premier lancement
- [ ] Le tutoriel explique comment tracer des mots (avec animation)
- [ ] Le tutoriel explique les regles (3 lettres min, adjacence)
- [ ] Un bouton "?" permet de revoir l'aide a tout moment
- [ ] La preference "tutoriel vu" est sauvegardee
- [ ] Mme Pavochko comprend comment jouer des le debut

---

## Tests

```dart
test('[P0] devrait detecter le premier lancement', () {
  final settings = SettingsService();
  expect(settings.hasSeenTutorial, isFalse);
});

testWidgets('[P0] devrait afficher le tutoriel au premier lancement', (tester) async {
  // ...
  expect(find.text('Bienvenue'), findsOneWidget);
});
```
