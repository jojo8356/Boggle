import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:froggle_game/widgets/timer_widget.dart';

void main() {
  group('TimerWidget', () {
    testWidgets('[P2] devrait afficher le temps correctement en format MM:SS', (tester) async {
      // GIVEN: Un timer avec 125 secondes (2:05)
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TimerWidget(remainingSeconds: 125),
          ),
        ),
      );

      // WHEN: Le widget est rendu
      // THEN: Le temps devrait etre affiche au format "02:05"
      expect(find.text('02:05'), findsOneWidget);
    });

    testWidgets('[P2] devrait afficher 00:00 pour zero secondes', (tester) async {
      // GIVEN: Un timer a zero
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TimerWidget(remainingSeconds: 0),
          ),
        ),
      );

      // WHEN: Le widget est rendu
      // THEN: Le temps devrait etre "00:00"
      expect(find.text('00:00'), findsOneWidget);
    });

    testWidgets('[P2] devrait afficher l\'icone timer', (tester) async {
      // GIVEN: Un timer widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TimerWidget(remainingSeconds: 60),
          ),
        ),
      );

      // WHEN: Le widget est rendu
      // THEN: L'icone timer devrait etre presente
      expect(find.byIcon(Icons.timer), findsOneWidget);
    });

    testWidgets('[P2] devrait avoir une couleur bleue quand temps > 30s', (tester) async {
      // GIVEN: Un timer avec plus de 30 secondes
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TimerWidget(remainingSeconds: 60),
          ),
        ),
      );

      // WHEN: Le widget est rendu
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(TimerWidget),
          matching: find.byType(Container).first,
        ),
      );

      // THEN: La decoration devrait utiliser une couleur bleue
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.blue[100]));
    });

    testWidgets('[P2] devrait avoir une couleur rouge quand temps <= 30s', (tester) async {
      // GIVEN: Un timer avec 30 secondes ou moins
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TimerWidget(remainingSeconds: 25),
          ),
        ),
      );

      // WHEN: Le widget est rendu
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(TimerWidget),
          matching: find.byType(Container).first,
        ),
      );

      // THEN: La decoration devrait utiliser une couleur rouge
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.red[100]));
    });

    testWidgets('[P2] devrait gerer les grandes valeurs de temps', (tester) async {
      // GIVEN: Un timer avec beaucoup de temps (10 minutes)
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TimerWidget(remainingSeconds: 600),
          ),
        ),
      );

      // WHEN: Le widget est rendu
      // THEN: Le temps devrait etre affiche correctement
      expect(find.text('10:00'), findsOneWidget);
    });
  });
}
