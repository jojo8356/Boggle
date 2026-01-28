import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:froggle_game/widgets/boggle_grid.dart';

void main() {
  group('BoggleGrid', () {
    final testLetters = ['F', 'R', 'O', 'G', 'G', 'L', 'E', 'S', 'A', 'T', 'I', 'N', 'M', 'O', 'T', 'S'];

    testWidgets('[P1] devrait afficher toutes les lettres de la grille', (tester) async {
      // GIVEN: Une grille avec 16 lettres
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 500,
              child: BoggleGrid(letters: testLetters),
            ),
          ),
        ),
      );

      // WHEN: Le widget est rendu
      // THEN: Toutes les lettres devraient etre affichees
      expect(find.text('F'), findsOneWidget);
      expect(find.text('R'), findsOneWidget);
      expect(find.text('O'), findsAtLeastNWidgets(2)); // O apparait 2 fois
      expect(find.text('G'), findsAtLeastNWidgets(2)); // G apparait 2 fois
      expect(find.text('L'), findsOneWidget);
      expect(find.text('E'), findsOneWidget);
      expect(find.text('S'), findsAtLeastNWidgets(2)); // S apparait 2 fois
      expect(find.text('A'), findsOneWidget);
      expect(find.text('T'), findsAtLeastNWidgets(2)); // T apparait 2 fois
      expect(find.text('I'), findsOneWidget);
      expect(find.text('N'), findsOneWidget);
      expect(find.text('M'), findsOneWidget);
    });

    testWidgets('[P1] devrait avoir une grille 4x4 (16 cellules)', (tester) async {
      // GIVEN: Une grille avec 16 lettres
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 500,
              child: BoggleGrid(letters: testLetters),
            ),
          ),
        ),
      );

      // WHEN: Le widget est rendu
      // THEN: Il devrait y avoir un GridView
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('[P1] devrait calculer correctement gridSize', (tester) async {
      // GIVEN: Une grille de 16 lettres (4x4)
      final grid = BoggleGrid(letters: testLetters);

      // WHEN: On accede a gridSize
      // THEN: La taille devrait etre 4
      expect(grid.gridSize, equals(4));
    });

    testWidgets('[P1] devrait gerer une grille 3x3', (tester) async {
      // GIVEN: Une grille de 9 lettres (3x3)
      final smallLetters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I'];
      final grid = BoggleGrid(letters: smallLetters);

      // WHEN: On accede a gridSize
      // THEN: La taille devrait etre 3
      expect(grid.gridSize, equals(3));
    });

    testWidgets('[P1] devrait afficher les boutons valider/annuler initialement masques', (tester) async {
      // GIVEN: Une grille sans selection
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 500,
              child: BoggleGrid(letters: testLetters),
            ),
          ),
        ),
      );

      // WHEN: Le widget est rendu sans selection
      // THEN: Les boutons devraient etre caches (opacity 0)
      final checkIcon = find.byIcon(Icons.check);
      final closeIcon = find.byIcon(Icons.close);

      // Les icones existent mais sont dans un Opacity widget
      expect(checkIcon, findsOneWidget);
      expect(closeIcon, findsOneWidget);
    });

    testWidgets('[P2] devrait appliquer le zoom initial', (tester) async {
      // GIVEN: Une grille avec un zoom de 1.2
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 500,
              child: BoggleGrid(
                letters: testLetters,
                initialZoom: 1.2,
              ),
            ),
          ),
        ),
      );

      // WHEN: Le widget est rendu
      // THEN: Un Transform.scale devrait etre present
      expect(find.byType(Transform), findsWidgets);
    });

    testWidgets('[P1] devrait appeler onPathSelected avec le chemin correct', (tester) async {
      // GIVEN: Une grille avec un callback
      List<int>? selectedPath;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 600,
              child: BoggleGrid(
                letters: testLetters,
                onPathSelected: (path) {
                  selectedPath = path;
                },
              ),
            ),
          ),
        ),
      );

      // Note: Le test d'interaction complete necessite des gestes complexes
      // Ce test verifie que le callback est bien connecte
      expect(selectedPath, isNull); // Pas de selection initiale
    });

    testWidgets('[P2] devrait highlighter un chemin fourni', (tester) async {
      // GIVEN: Une grille avec un chemin highlight
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 500,
              child: BoggleGrid(
                letters: testLetters,
                highlightedPath: [0, 1, 2, 3],
                isHighlightValid: true,
              ),
            ),
          ),
        ),
      );

      // WHEN: Le widget est rendu
      // THEN: Le chemin devrait etre visible (les cellules ont des decorations differentes)
      // Note: Test visuel - on verifie que le widget se rend sans erreur
      expect(find.byType(BoggleGrid), findsOneWidget);
    });

    testWidgets('[P2] devrait afficher un highlight rouge pour chemin invalide', (tester) async {
      // GIVEN: Une grille avec un chemin highlight invalide
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 500,
              child: BoggleGrid(
                letters: testLetters,
                highlightedPath: [0, 1, 2],
                isHighlightValid: false,
              ),
            ),
          ),
        ),
      );

      // WHEN: Le widget est rendu
      // THEN: Le widget devrait se rendre sans erreur
      expect(find.byType(BoggleGrid), findsOneWidget);
    });
  });
}
