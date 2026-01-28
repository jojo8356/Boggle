import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:froggle_game/widgets/boggle_grid.dart';

void main() {
  group('BoggleGrid - Test de redimensionnement', () {
    // Grille 4x4 standard
    final testLetters = [
      'A', 'B', 'C', 'D',
      'E', 'F', 'G', 'H',
      'I', 'J', 'K', 'L',
      'M', 'N', 'O', 'P',
    ];

    testWidgets(
      'La grille ne doit PAS se redimensionner quand on sélectionne des lettres',
      (WidgetTester tester) async {
        Size? initialGridSize;
        Size? afterSelectionGridSize;
        final gridKey = GlobalKey();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 600,
                child: BoggleGrid(
                  key: gridKey,
                  letters: testLetters,
                  initialZoom: 1.0,
                  onPathSelected: (_) {},
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Trouver le container de la grille (Container avec couleur brown)
        final gridContainerFinder = find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).color == Colors.brown[100],
        );

        expect(gridContainerFinder, findsOneWidget,
            reason: 'Le container de la grille doit exister');

        // Mesurer la taille initiale
        final initialRenderBox =
            tester.renderObject<RenderBox>(gridContainerFinder);
        initialGridSize = initialRenderBox.size;

        print('📏 Taille initiale de la grille: $initialGridSize');

        // Trouver la première cellule (lettre A)
        final firstCellFinder = find.text('A');
        expect(firstCellFinder, findsOneWidget);

        // Simuler un tap sur la première cellule
        await tester.tap(firstCellFinder);
        await tester.pumpAndSettle();

        print('👆 Tap sur cellule A effectué');

        // Simuler un tap sur la deuxième cellule (B - adjacente)
        final secondCellFinder = find.text('B');
        await tester.tap(secondCellFinder);
        await tester.pumpAndSettle();

        print('👆 Tap sur cellule B effectué');

        // Simuler un tap sur la troisième cellule (C - adjacente)
        final thirdCellFinder = find.text('C');
        await tester.tap(thirdCellFinder);
        await tester.pumpAndSettle();

        print('👆 Tap sur cellule C effectué - mot "ABC" sélectionné');

        // Mesurer la taille après sélection
        final afterRenderBox =
            tester.renderObject<RenderBox>(gridContainerFinder);
        afterSelectionGridSize = afterRenderBox.size;

        print('📏 Taille après sélection: $afterSelectionGridSize');

        // ASSERTION PRINCIPALE: La taille ne doit pas changer
        expect(
          afterSelectionGridSize,
          equals(initialGridSize),
          reason:
              'La grille ne doit PAS se redimensionner après sélection de lettres!\n'
              'Taille initiale: $initialGridSize\n'
              'Taille après: $afterSelectionGridSize',
        );
      },
    );

    testWidgets(
      'La grille ne doit PAS se redimensionner quand les boutons apparaissent/disparaissent',
      (WidgetTester tester) async {
        Size? sizeBeforeButtons;
        Size? sizeWithButtons;
        Size? sizeAfterClear;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 600,
                child: BoggleGrid(
                  letters: testLetters,
                  initialZoom: 1.0,
                  onPathSelected: (_) {},
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Trouver le container de la grille
        final gridContainerFinder = find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).color == Colors.brown[100],
        );

        // Taille AVANT sélection (boutons invisibles)
        sizeBeforeButtons = tester.renderObject<RenderBox>(gridContainerFinder).size;
        print('📏 Taille AVANT boutons: $sizeBeforeButtons');

        // Vérifier que les boutons sont invisibles (Opacity = 0)
        final opacityFinder = find.byType(Opacity);
        final opacityWidget = tester.widget<Opacity>(opacityFinder.first);
        expect(opacityWidget.opacity, equals(0.0),
            reason: 'Les boutons doivent être invisibles au départ');

        // Sélectionner 3 lettres pour faire apparaître les boutons
        await tester.tap(find.text('A'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('B'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();

        // Taille AVEC boutons visibles
        sizeWithButtons = tester.renderObject<RenderBox>(gridContainerFinder).size;
        print('📏 Taille AVEC boutons: $sizeWithButtons');

        // Vérifier que les boutons sont maintenant visibles
        final opacityAfterSelection = tester.widget<Opacity>(opacityFinder.first);
        expect(opacityAfterSelection.opacity, equals(1.0),
            reason: 'Les boutons doivent être visibles après sélection');

        // Cliquer sur le bouton annuler (croix rouge)
        final cancelButton = find.byIcon(Icons.close);
        await tester.tap(cancelButton);
        await tester.pumpAndSettle();

        // Taille APRÈS annulation (boutons invisibles à nouveau)
        sizeAfterClear = tester.renderObject<RenderBox>(gridContainerFinder).size;
        print('📏 Taille APRÈS annulation: $sizeAfterClear');

        // ASSERTIONS: Toutes les tailles doivent être identiques
        expect(
          sizeWithButtons,
          equals(sizeBeforeButtons),
          reason: 'La grille ne doit PAS changer quand les boutons apparaissent!',
        );

        expect(
          sizeAfterClear,
          equals(sizeBeforeButtons),
          reason: 'La grille ne doit PAS changer quand les boutons disparaissent!',
        );
      },
    );

    testWidgets(
      'Mesure du layout shift lors de la validation d\'un mot',
      (WidgetTester tester) async {
        final List<Size> gridSizes = [];
        String? submittedWord;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 600,
                child: BoggleGrid(
                  letters: testLetters,
                  initialZoom: 1.0,
                  onPathSelected: (path) {
                    submittedWord = path.map((i) => testLetters[i]).join();
                    print('✅ Mot soumis: $submittedWord');
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final gridContainerFinder = find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).color == Colors.brown[100],
        );

        // Mesure 1: État initial
        gridSizes.add(tester.renderObject<RenderBox>(gridContainerFinder).size);
        print('📏 [1] Initial: ${gridSizes.last}');

        // Sélectionner ABC
        await tester.tap(find.text('A'));
        await tester.pump();
        gridSizes.add(tester.renderObject<RenderBox>(gridContainerFinder).size);
        print('📏 [2] Après tap A: ${gridSizes.last}');

        await tester.tap(find.text('B'));
        await tester.pump();
        gridSizes.add(tester.renderObject<RenderBox>(gridContainerFinder).size);
        print('📏 [3] Après tap B: ${gridSizes.last}');

        await tester.tap(find.text('C'));
        await tester.pump();
        gridSizes.add(tester.renderObject<RenderBox>(gridContainerFinder).size);
        print('📏 [4] Après tap C: ${gridSizes.last}');

        // Valider le mot (bouton vert)
        final validateButton = find.byIcon(Icons.check);
        await tester.tap(validateButton);
        await tester.pump();
        gridSizes.add(tester.renderObject<RenderBox>(gridContainerFinder).size);
        print('📏 [5] Après validation: ${gridSizes.last}');

        await tester.pumpAndSettle();
        gridSizes.add(tester.renderObject<RenderBox>(gridContainerFinder).size);
        print('📏 [6] Après settle: ${gridSizes.last}');

        // Vérifier que le mot a été soumis
        expect(submittedWord, equals('ABC'));

        // ASSERTION: Toutes les tailles doivent être identiques
        final initialSize = gridSizes.first;
        for (int i = 1; i < gridSizes.length; i++) {
          expect(
            gridSizes[i],
            equals(initialSize),
            reason: 'Layout shift détecté à l\'étape $i!\n'
                'Taille initiale: $initialSize\n'
                'Taille à l\'étape $i: ${gridSizes[i]}',
          );
        }

        print('✅ Aucun layout shift détecté!');
      },
    );
  });
}
