import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:froggle_game/core/widgets/word_chip.dart';

void main() {
  group('WordChip', () {
    testWidgets('[P0] devrait afficher le texte correctement', (tester) async {
      // GIVEN: Un WordChip avec le texte "FROG"
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WordChip(text: 'FROG'),
          ),
        ),
      );

      // WHEN: Le widget est rendu
      // THEN: Le texte devrait etre affiche
      expect(find.text('FROG'), findsOneWidget);
    });

    testWidgets('[P0] devrait utiliser les couleurs vertes par defaut', (tester) async {
      // GIVEN: Un WordChip sans couleurs specifiees
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WordChip(text: 'MOT'),
          ),
        ),
      );

      // WHEN: Le widget est rendu
      // THEN: Le Container devrait avoir un fond vert clair et une bordure verte
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.color, equals(Colors.green[100]));
      expect(decoration.border, isNotNull);
      expect(
        (decoration.border as Border).top.color,
        equals(Colors.green[300]),
      );

      // Le texte devrait etre vert fonce
      final text = tester.widget<Text>(find.text('MOT'));
      expect(text.style?.color, equals(Colors.green[800]));
    });

    testWidgets('[P0] devrait changer les couleurs quand isSelected est true', (tester) async {
      // GIVEN: Un WordChip selectionne
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WordChip(text: 'SEL', isSelected: true),
          ),
        ),
      );

      // WHEN: Le widget est rendu
      // THEN: Le Container devrait avoir les couleurs de selection
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.color, equals(Colors.green[300]));
      expect(
        (decoration.border as Border).top.color,
        equals(Colors.green[700]),
      );

      // Le texte devrait etre en gras
      final text = tester.widget<Text>(find.text('SEL'));
      expect(text.style?.fontWeight, equals(FontWeight.bold));
    });

    testWidgets('[P0] devrait appeler onTap quand on appuie', (tester) async {
      // GIVEN: Un WordChip avec un callback onTap
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WordChip(text: 'TAP', onTap: () => tapped = true),
          ),
        ),
      );

      // WHEN: On appuie sur le chip
      await tester.tap(find.text('TAP'));

      // THEN: Le callback devrait etre appele
      expect(tapped, isTrue);
    });

    testWidgets('[P0] ne devrait pas avoir de GestureDetector sans onTap', (tester) async {
      // GIVEN: Un WordChip sans callback
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WordChip(text: 'NO'),
          ),
        ),
      );

      // WHEN: Le widget est rendu
      // THEN: Pas de GestureDetector
      expect(find.byType(GestureDetector), findsNothing);
    });

    testWidgets('[P1] devrait appliquer un backgroundColor personnalise', (tester) async {
      // GIVEN: Un WordChip avec un fond rouge
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WordChip(text: 'TEST', backgroundColor: Colors.red),
          ),
        ),
      );

      // WHEN: Le widget est rendu
      // THEN: Le Container devrait avoir un fond rouge
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.color, equals(Colors.red));
    });

    testWidgets('[P1] devrait appliquer un fontSize personnalise', (tester) async {
      // GIVEN: Un WordChip avec une taille de police de 20
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WordChip(text: 'GRAND', fontSize: 20),
          ),
        ),
      );

      // WHEN: Le widget est rendu
      // THEN: Le texte devrait avoir une taille de 20
      final text = tester.widget<Text>(find.text('GRAND'));
      expect(text.style?.fontSize, equals(20));
    });

    testWidgets('[P1] devrait appliquer textDecoration', (tester) async {
      // GIVEN: Un WordChip avec un texte barre
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WordChip(
              text: 'BARRE',
              textDecoration: TextDecoration.lineThrough,
            ),
          ),
        ),
      );

      // WHEN: Le widget est rendu
      // THEN: Le texte devrait avoir la decoration lineThrough
      final text = tester.widget<Text>(find.text('BARRE'));
      expect(text.style?.decoration, equals(TextDecoration.lineThrough));
    });

    testWidgets('[P1] devrait avoir un padding compact (horizontal: 6, vertical: 4)', (tester) async {
      // GIVEN: Un WordChip standard
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WordChip(text: 'PAD'),
          ),
        ),
      );

      // WHEN: Le widget est rendu
      // THEN: Le padding devrait etre horizontal: 6, vertical: 4
      final container = tester.widget<Container>(find.byType(Container));
      final padding = container.padding as EdgeInsets;

      expect(padding.left, equals(6));
      expect(padding.right, equals(6));
      expect(padding.top, equals(4));
      expect(padding.bottom, equals(4));
    });

    testWidgets('[P1] devrait avoir un borderRadius de 4', (tester) async {
      // GIVEN: Un WordChip standard
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WordChip(text: 'RAD'),
          ),
        ),
      );

      // WHEN: Le widget est rendu
      // THEN: Le borderRadius devrait etre 4
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;

      expect(
        decoration.borderRadius,
        equals(BorderRadius.circular(4)),
      );
    });

    testWidgets('[P2] devrait pouvoir afficher plusieurs WordChips dans un Row', (tester) async {
      // GIVEN: Plusieurs WordChips dans un Row
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                WordChip(text: 'MOT1'),
                WordChip(text: 'MOT2'),
                WordChip(text: 'MOT3'),
              ],
            ),
          ),
        ),
      );

      // WHEN: Les widgets sont rendus
      // THEN: Tous les textes devraient etre affiches
      expect(find.text('MOT1'), findsOneWidget);
      expect(find.text('MOT2'), findsOneWidget);
      expect(find.text('MOT3'), findsOneWidget);
      expect(find.byType(WordChip), findsNWidgets(3));
    });
  });
}
