import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:froggle_game/widgets/score_display.dart';

void main() {
  group('ScoreDisplay', () {
    testWidgets('[P0] devrait afficher le nombre de mots correctement', (tester) async {
      // GIVEN: Un ScoreDisplay avec 5 mots
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreDisplay(
              currentScore: 10,
              totalScore: 50,
              wordCount: 5,
            ),
          ),
        ),
      );

      // WHEN: Le widget est rendu
      // THEN: Le nombre de mots devrait etre affiche
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('[P0] devrait afficher le score actuel correctement', (tester) async {
      // GIVEN: Un ScoreDisplay avec un score de 42
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreDisplay(
              currentScore: 42,
              totalScore: 100,
              wordCount: 8,
            ),
          ),
        ),
      );

      // WHEN: Le widget est rendu
      // THEN: Le score avec le prefixe "+" devrait etre affiche
      expect(find.text('+42'), findsOneWidget);
    });

    testWidgets('[P0] devrait afficher les labels "mots" et "pts"', (tester) async {
      // GIVEN: Un ScoreDisplay standard
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreDisplay(
              currentScore: 10,
              totalScore: 50,
              wordCount: 3,
            ),
          ),
        ),
      );

      // WHEN: Le widget est rendu
      // THEN: Les labels devraient etre presents
      expect(find.text(' mots | '), findsOneWidget);
      expect(find.text(' pts'), findsOneWidget);
    });

    testWidgets('[P1] devrait s\'afficher avec des valeurs a zero', (tester) async {
      // GIVEN: Un ScoreDisplay avec toutes les valeurs a zero
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreDisplay(
              currentScore: 0,
              totalScore: 0,
              wordCount: 0,
            ),
          ),
        ),
      );

      // WHEN: Le widget est rendu
      // THEN: Les valeurs zero devraient etre affichees correctement
      expect(find.text('0'), findsOneWidget);
      expect(find.text('+0'), findsOneWidget);
      expect(find.text(' mots | '), findsOneWidget);
      expect(find.text(' pts'), findsOneWidget);
    });

    testWidgets('[P1] devrait s\'afficher avec de grandes valeurs (999)', (tester) async {
      // GIVEN: Un ScoreDisplay avec de grandes valeurs
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreDisplay(
              currentScore: 999,
              totalScore: 9999,
              wordCount: 999,
            ),
          ),
        ),
      );

      // WHEN: Le widget est rendu
      // THEN: Les grandes valeurs devraient etre affichees correctement
      expect(find.text('999'), findsOneWidget);
      expect(find.text('+999'), findsOneWidget);
    });

    testWidgets('[P2] devrait avoir une decoration avec gradient violet', (tester) async {
      // GIVEN: Un ScoreDisplay standard
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreDisplay(
              currentScore: 10,
              totalScore: 50,
              wordCount: 3,
            ),
          ),
        ),
      );

      // WHEN: Le widget est rendu
      // THEN: Le Container devrait avoir un gradient violet
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      final gradient = decoration.gradient as LinearGradient;

      expect(gradient.colors.length, equals(2));
      expect(gradient.colors[0], equals(Colors.purple[400]));
      expect(gradient.colors[1], equals(Colors.purple[600]));
    });
  });
}
