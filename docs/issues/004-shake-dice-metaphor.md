# Issue #4 : Metaphore du Secouage des Des

**Branche:** `fix/ux-shake-dice-metaphor`
**Priorite:** P2 (Moyenne)
**Reporter:** Mme Pavochko (utilisatrice anonyme)
**Assignee:** Marco (Flutter Expert)

---

## Probleme

> "Et le pire : ou est le bouton pour secouer les des ?! Dans le vrai Boggle, on secoue ! Ici, je cherche encore..."
> — Mme Pavochko

### Contexte
- Le Boggle physique a un geste iconique : SECOUER la boite
- Dans Froggle, la grille apparait simplement
- Pas de connexion emotionnelle avec le jeu original
- Le geste de "nouvelle partie" est un simple bouton

### Impact Utilisateur
- Nostalgie brisee pour les joueurs de Boggle classique
- Experience moins immersive
- Manque de satisfaction tactile

---

## Solution Proposee

### 1. Geste de secouage physique
```dart
// lib/widgets/shake_detector.dart (NOUVEAU)
import 'package:sensors_plus/sensors_plus.dart';

class ShakeDetector extends StatefulWidget {
  final VoidCallback onShake;

  // Detecte les mouvements brusques du telephone
  // Seuil : acceleration > 15 m/s²
}
```

### 2. Animation de secouage de la grille
```dart
// lib/widgets/boggle_grid.dart
// Quand on secoue ou appuie sur le bouton :
// 1. Les lettres "sautent" de leurs cases
// 2. Animation de melange (0.5s)
// 3. Nouvelles lettres "tombent" en place
class GridShakeAnimation extends StatefulWidget {
  // Utilise Transform + AnimationController
}
```

### 3. Bouton "Secouer" visuel
```dart
// lib/screens/home_screen.dart
// Remplacer "Nouvelle partie" par un bouton stylise
ElevatedButton.icon(
  icon: Icon(Icons.casino), // Icone de de
  label: Text('Secouer !'),
  onPressed: () => _shakeAndStart(),
)
```

### 4. Son de des qui roulent (optionnel)
```dart
// lib/services/audio_service.dart (NOUVEAU)
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  Future<void> playDiceSound() async {
    await _player.play(AssetSource('sounds/dice_roll.mp3'));
  }
}
```

### 5. Vibration lors du secouage
```dart
// Feedback haptique quand on secoue
Vibration.vibrate(pattern: [0, 50, 50, 50, 50, 50]);
```

---

## Fichiers a Creer/Modifier

| Fichier | Action |
|---------|--------|
| `lib/widgets/shake_detector.dart` | CREER - Detection secouage |
| `lib/widgets/grid_shake_animation.dart` | CREER - Animation grille |
| `lib/services/audio_service.dart` | CREER - Service audio |
| `lib/screens/home_screen.dart` | Bouton "Secouer" |
| `lib/screens/results_screen.dart` | Geste secouer pour rejouer |
| `assets/sounds/dice_roll.mp3` | AJOUTER - Son de des |
| `pubspec.yaml` | Ajouter sensors_plus, audioplayers |

---

## Interactions

### Sur HomeScreen (nouvelle partie)
```
[Appuie "Secouer !"] ou [Secoue le telephone]
           |
           v
[Animation + Son + Vibration]
           |
           v
[Nouvelle grille generee]
           |
           v
[Navigation vers GameScreen]
```

### Sur ResultsScreen (rejouer)
```
[Appuie "Rejouer"] ou [Secoue le telephone]
           |
           v
[Animation de la grille affichee]
           |
           v
[Nouvelle partie]
```

---

## Animation de Secouage (Detail)

```dart
// Sequence d'animation (500ms total)
// 0-100ms   : Lettres sautent (scale 1.0 -> 0.8, rotation random)
// 100-300ms : Position aleatoire (offset random)
// 300-500ms : Nouvelles lettres tombent (scale 0.8 -> 1.0, bounce)

class LetterShakeAnimation extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform(
          transform: Matrix4.identity()
            ..translate(_offsetX.value, _offsetY.value)
            ..rotateZ(_rotation.value)
            ..scale(_scale.value),
          child: child,
        );
      },
    );
  }
}
```

---

## Criteres d'Acceptation

- [ ] Secouer le telephone genere une nouvelle grille
- [ ] Un bouton "Secouer !" est visible sur l'ecran d'accueil
- [ ] Une animation de melange des lettres s'affiche
- [ ] Un son de des accompagne le secouage (desactivable)
- [ ] Une vibration accompagne le secouage (desactivable)
- [ ] Mme Pavochko retrouve le plaisir de "secouer les des"

---

## Tests

```dart
test('[P2] devrait detecter un secouage', () {
  // Mock accelerometer events
});

testWidgets('[P2] devrait afficher animation de secouage', (tester) async {
  // Trigger shake animation
  // Verify letters animate
});
```

---

## Notes

### Accessibilite
- Le geste de secouage doit etre OPTIONNEL
- Le bouton doit toujours etre disponible
- Option dans les parametres : "Activer detection de secouage"

### Performance
- L'animation doit etre fluide (60 FPS)
- Utiliser `const` constructors
- Precharger les sons
