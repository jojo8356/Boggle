# Issue #3 : Feedback de Fin de Partie

**Branche:** `fix/ux-game-end-feedback`
**Priorite:** P1 (Haute)
**Reporter:** Mme Pavochko (utilisatrice anonyme)
**Assignee:** Marco (Flutter Expert)

---

## Probleme

> "Quand le temps est fini, l'ecran change tout seul, je ne sais meme pas ce qui s'est passe. Ou sont mes mots ? J'ai perdu ?"
> — Mme Pavochko

### Contexte
- La transition vers `ResultsScreen` est instantanee
- Pas d'animation de fin de partie
- Pas de son ou vibration
- L'utilisateur est "teleporte" sans comprendre

### Impact Utilisateur
- Sentiment de confusion et de perte de controle
- Pas de moment de celebration ou de deception
- Experience emotionnelle plate

---

## Solution Proposee

### 1. Compte a rebours final dramatique
```dart
// lib/widgets/timer_widget.dart
// Quand < 10 secondes :
// - Animation de pulsation
// - Couleur rouge intense
// - Son optionnel de tic-tac
if (remainingSeconds <= 10) {
  return AnimatedContainer(
    duration: Duration(milliseconds: 500),
    // Pulsation scale 1.0 -> 1.1 -> 1.0
  );
}
```

### 2. Ecran de transition "Temps ecoule !"
```dart
// lib/screens/game_end_transition.dart (NOUVEAU)
class GameEndTransition extends StatefulWidget {
  // Affiche pendant 2-3 secondes :
  // - "TEMPS ECOULE !"
  // - Animation de sablier
  // - Resume rapide : "X mots trouves"
  // - Transition fluide vers ResultsScreen
}
```

### 3. Animation d'entree des resultats
```dart
// lib/screens/results_screen.dart
// Animer l'apparition des elements :
// 1. Grille apparait (fade in)
// 2. Classement slide depuis le bas
// 3. Mots apparaissent un par un
```

### 4. Feedback visuel selon performance
```dart
// Selon le score :
// - Excellent (>30 pts) : Confettis, "Incroyable !"
// - Bon (15-30 pts) : Etoiles, "Bien joue !"
// - Moyen (<15 pts) : Encouragement, "Pas mal, reessayez !"
```

### 5. Vibration haptique (mobile)
```dart
// Vibration courte a la fin du temps
import 'package:vibration/vibration.dart';
if (await Vibration.hasVibrator()) {
  Vibration.vibrate(duration: 200);
}
```

---

## Fichiers a Creer/Modifier

| Fichier | Action |
|---------|--------|
| `lib/screens/game_end_transition.dart` | CREER - Ecran transition |
| `lib/widgets/timer_widget.dart` | Animation fin de temps |
| `lib/screens/results_screen.dart` | Animations d'entree |
| `lib/widgets/confetti_widget.dart` | CREER - Effet confettis |
| `lib/screens/game_screen.dart` | Naviguer via transition |
| `pubspec.yaml` | Ajouter package vibration (optionnel) |

---

## Flux de Fin de Partie

```
Timer = 10s
    |
    v
[Animation pulsation rouge]
    |
    v
Timer = 0s + Vibration
    |
    v
[GameEndTransition] "TEMPS ECOULE !" (2s)
    |
    v
[ResultsScreen avec animations]
    |
    v
[Confettis si bon score]
```

---

## Criteres d'Acceptation

- [ ] Le timer pulse et devient rouge dans les 10 dernieres secondes
- [ ] Un ecran "Temps ecoule !" s'affiche pendant 2 secondes
- [ ] Les resultats apparaissent avec des animations fluides
- [ ] Un feedback visuel (confettis/etoiles) s'affiche selon le score
- [ ] Mme Pavochko comprend que la partie est finie

---

## Tests

```dart
testWidgets('[P1] devrait afficher animation quand timer < 10s', (tester) async {
  await tester.pumpWidget(TimerWidget(remainingSeconds: 5));
  // Verifier animation
});

testWidgets('[P1] devrait naviguer via GameEndTransition', (tester) async {
  // Verifier que la transition s'affiche
});
```
