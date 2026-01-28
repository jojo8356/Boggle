import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:froggle_game/core/widgets/circular_action_button.dart';

void main() {
  group('CircularActionButton', () {
    testWidgets('[P0] devrait afficher l\'icone correctement', (tester) async {
      // GIVEN: Un bouton avec l'icone play_arrow
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircularActionButton(
              onTap: () {},
              icon: Icons.play_arrow,
              color: Colors.blue,
            ),
          ),
        ),
      );

      // WHEN: Le widget est rendu
      // THEN: L'icone devrait etre affichee
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('[P0] devrait appeler onTap quand on appuie', (tester) async {
      // GIVEN: Un bouton avec un callback
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircularActionButton(
              onTap: () {
                tapped = true;
              },
              icon: Icons.play_arrow,
              color: Colors.blue,
            ),
          ),
        ),
      );

      // WHEN: On appuie sur le bouton
      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      // THEN: Le callback devrait avoir ete appele
      expect(tapped, isTrue);
    });

    testWidgets('[P1] devrait avoir l\'icone en blanc', (tester) async {
      // GIVEN: Un bouton circulaire
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircularActionButton(
              onTap: () {},
              icon: Icons.check,
              color: Colors.green,
            ),
          ),
        ),
      );

      // WHEN: Le widget est rendu
      // THEN: L'icone devrait etre blanche
      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color, equals(Colors.white));
    });

    testWidgets('[P1] devrait avoir un Container circulaire', (tester) async {
      // GIVEN: Un bouton circulaire
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircularActionButton(
              onTap: () {},
              icon: Icons.close,
              color: Colors.red,
            ),
          ),
        ),
      );

      // WHEN: Le widget est rendu
      // THEN: Le Container devrait avoir une forme circulaire
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.shape, equals(BoxShape.circle));
    });

    testWidgets('[P1] devrait appliquer un iconSize personnalise', (tester) async {
      // GIVEN: Un bouton avec une taille d'icone de 64
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircularActionButton(
              onTap: () {},
              icon: Icons.star,
              color: Colors.amber,
              iconSize: 64,
            ),
          ),
        ),
      );

      // WHEN: Le widget est rendu
      // THEN: L'icone devrait avoir une taille de 64
      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.size, equals(64));
    });

    testWidgets('[P2] devrait supporter onTap null sans crash', (tester) async {
      // GIVEN: Un bouton avec onTap null
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircularActionButton(
              onTap: null,
              icon: Icons.block,
              color: Colors.grey,
            ),
          ),
        ),
      );

      // WHEN: On appuie sur le bouton
      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      // THEN: Aucune erreur ne devrait se produire
      expect(find.byType(CircularActionButton), findsOneWidget);
    });
  });
}
