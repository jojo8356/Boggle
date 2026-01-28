import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test comparatif des deux solutions pour le layout shift
/// Option A: Opacity (invisible quand vide)
/// Option B: Container fixe avec placeholder

void main() {
  group('Layout Shift - Comparaison des solutions', () {

    /// Simule le layout actuel (BUGUÉ) - avec if conditionnel
    Widget buildCurrentLayout(List<String> words) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 600,
            child: Column(
              children: [
                // Header fixe
                Container(
                  height: 50,
                  color: Colors.blue[100],
                  child: const Center(child: Text('Timer + Score')),
                ),
                // Grille (Expanded)
                Expanded(
                  child: Container(
                    color: Colors.amber[100],
                    child: const Center(child: Text('GRILLE')),
                  ),
                ),
                // Feedback (toujours présent avec Opacity)
                Opacity(
                  opacity: 1.0,
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.all(6),
                    color: Colors.green[100],
                    child: const Text('Feedback'),
                  ),
                ),
                // BUG: Liste conditionnelle
                if (words.isNotEmpty)
                  Container(
                    constraints: const BoxConstraints(maxHeight: 70),
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.all(6),
                    color: Colors.grey[200],
                    child: Wrap(
                      children: words.map((w) => Chip(label: Text(w))).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    /// Option A: Opacity (invisible quand vide)
    Widget buildOptionA(List<String> words) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 600,
            child: Column(
              children: [
                Container(
                  height: 50,
                  color: Colors.blue[100],
                  child: const Center(child: Text('Timer + Score')),
                ),
                Expanded(
                  child: Container(
                    key: const Key('grid_container_a'),
                    color: Colors.amber[100],
                    child: const Center(child: Text('GRILLE')),
                  ),
                ),
                Opacity(
                  opacity: 1.0,
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.all(6),
                    color: Colors.green[100],
                    child: const Text('Feedback'),
                  ),
                ),
                // OPTION A: Opacity pour cacher
                Opacity(
                  opacity: words.isNotEmpty ? 1.0 : 0.0,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 70, maxHeight: 70),
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.all(6),
                    color: Colors.grey[200],
                    child: words.isEmpty
                        ? const SizedBox.shrink()
                        : Wrap(
                            children: words.map((w) => Chip(label: Text(w))).toList(),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    /// Option B: Container fixe avec placeholder
    Widget buildOptionB(List<String> words) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 600,
            child: Column(
              children: [
                Container(
                  height: 50,
                  color: Colors.blue[100],
                  child: const Center(child: Text('Timer + Score')),
                ),
                Expanded(
                  child: Container(
                    key: const Key('grid_container_b'),
                    color: Colors.amber[100],
                    child: const Center(child: Text('GRILLE')),
                  ),
                ),
                Opacity(
                  opacity: 1.0,
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.all(6),
                    color: Colors.green[100],
                    child: const Text('Feedback'),
                  ),
                ),
                // OPTION B: Container toujours visible avec placeholder
                Container(
                  constraints: const BoxConstraints(minHeight: 70, maxHeight: 70),
                  margin: const EdgeInsets.all(4),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: words.isEmpty
                      ? Center(
                          child: Text(
                            'Vos mots apparaîtront ici',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: words.map((w) => Chip(label: Text(w))).toList(),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    testWidgets('CURRENT (bugué): Layout shift quand premier mot ajouté', (tester) async {
      // État initial: pas de mots
      await tester.pumpWidget(buildCurrentLayout([]));
      await tester.pumpAndSettle();

      final gridFinder = find.text('GRILLE');
      final initialSize = tester.getSize(gridFinder);
      print('📏 [CURRENT] Grille SANS mots: $initialSize');

      // Ajouter un mot
      await tester.pumpWidget(buildCurrentLayout(['MOT']));
      await tester.pumpAndSettle();

      final afterSize = tester.getSize(gridFinder);
      print('📏 [CURRENT] Grille AVEC mot: $afterSize');

      final heightDiff = initialSize.height - afterSize.height;
      print('⚠️  [CURRENT] Différence de hauteur: ${heightDiff.abs()}px');

      // On s'attend à un shift (c'est le bug!)
      if (heightDiff.abs() > 1) {
        print('❌ [CURRENT] LAYOUT SHIFT DÉTECTÉ: ${heightDiff.abs()}px');
      }
    });

    testWidgets('OPTION A (Opacity): Pas de layout shift', (tester) async {
      await tester.pumpWidget(buildOptionA([]));
      await tester.pumpAndSettle();

      final gridFinder = find.byKey(const Key('grid_container_a'));
      final initialSize = tester.getSize(gridFinder);
      print('📏 [OPTION A] Grille SANS mots: $initialSize');

      await tester.pumpWidget(buildOptionA(['MOT']));
      await tester.pumpAndSettle();

      final afterSize = tester.getSize(gridFinder);
      print('📏 [OPTION A] Grille AVEC mot: $afterSize');

      final heightDiff = initialSize.height - afterSize.height;
      print('📊 [OPTION A] Différence de hauteur: ${heightDiff.abs()}px');

      expect(
        afterSize.height,
        equals(initialSize.height),
        reason: 'Option A ne devrait pas avoir de layout shift',
      );
      print('✅ [OPTION A] Pas de layout shift!');
    });

    testWidgets('OPTION B (Placeholder): Pas de layout shift', (tester) async {
      await tester.pumpWidget(buildOptionB([]));
      await tester.pumpAndSettle();

      final gridFinder = find.byKey(const Key('grid_container_b'));
      final initialSize = tester.getSize(gridFinder);
      print('📏 [OPTION B] Grille SANS mots: $initialSize');

      await tester.pumpWidget(buildOptionB(['MOT']));
      await tester.pumpAndSettle();

      final afterSize = tester.getSize(gridFinder);
      print('📏 [OPTION B] Grille AVEC mot: $afterSize');

      final heightDiff = initialSize.height - afterSize.height;
      print('📊 [OPTION B] Différence de hauteur: ${heightDiff.abs()}px');

      expect(
        afterSize.height,
        equals(initialSize.height),
        reason: 'Option B ne devrait pas avoir de layout shift',
      );
      print('✅ [OPTION B] Pas de layout shift!');
    });

    testWidgets('Comparaison visuelle: Option A vs Option B (état vide)', (tester) async {
      print('\n========== COMPARAISON VISUELLE (ÉTAT VIDE) ==========');

      // Option A - état vide
      await tester.pumpWidget(buildOptionA([]));
      await tester.pumpAndSettle();

      // Trouver les widgets Opacity
      final opacityWidgets = find.byType(Opacity);
      final opacityCount = opacityWidgets.evaluate().length;
      print('👁️  [OPTION A] Nombre de widgets Opacity: $opacityCount');
      print('   → Zone mots invisible avec opacity=0');
      print('   → L\'utilisateur ne voit rien, espace "vide"');

      // Option B - état vide
      await tester.pumpWidget(buildOptionB([]));
      await tester.pumpAndSettle();

      final placeholderText = find.text('Vos mots apparaîtront ici');
      expect(placeholderText, findsOneWidget);
      print('👁️  [OPTION B] Zone mots: VISIBLE avec placeholder');
      print('   → L\'utilisateur voit "Vos mots apparaîtront ici"');

      print('\n========== VERDICT UX ==========');
      print('Option A: Minimaliste, moins de bruit visuel');
      print('Option B: Informatif, guide l\'utilisateur');
    });

    testWidgets('Test avec plusieurs mots', (tester) async {
      final manyWords = ['MOT', 'TEST', 'CHAT', 'CHIEN', 'ARBRE'];

      print('\n========== TEST AVEC ${manyWords.length} MOTS ==========');

      // Option A
      await tester.pumpWidget(buildOptionA(manyWords));
      await tester.pumpAndSettle();
      final sizeA = tester.getSize(find.byKey(const Key('grid_container_a')));
      print('📏 [OPTION A] Grille avec ${manyWords.length} mots: $sizeA');

      // Option B
      await tester.pumpWidget(buildOptionB(manyWords));
      await tester.pumpAndSettle();
      final sizeB = tester.getSize(find.byKey(const Key('grid_container_b')));
      print('📏 [OPTION B] Grille avec ${manyWords.length} mots: $sizeB');

      expect(sizeA, equals(sizeB), reason: 'Les deux options doivent avoir la même taille de grille');
      print('✅ Tailles identiques entre les deux options');
    });
  });
}
