import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test visuel pour comparer les options de la liste de mots
void main() {
  group('Liste des mots - Tests visuels', () {

    /// Version actuelle (problématique) - bloc gris 70px fixe
    Widget buildCurrentVersion(List<String> words) {
      return MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Expanded(child: Container(color: Colors.amber[100])),
              // Version actuelle: bloc gris 70px même vide
              Container(
                constraints: const BoxConstraints(minHeight: 70, maxHeight: 70),
                margin: const EdgeInsets.all(8),
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
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      )
                    : Wrap(
                        children: words.map((w) => Chip(label: Text(w))).toList(),
                      ),
              ),
            ],
          ),
        ),
      );
    }

    /// Option C: SizedBox fixe + container adaptatif
    Widget buildOptionC(List<String> words) {
      return MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Expanded(
                child: Container(
                  key: const Key('grid_c'),
                  color: Colors.amber[100],
                ),
              ),
              // Option C: SizedBox réserve l'espace, container s'adapte
              SizedBox(
                height: 78, // 70 + margins
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: words.isEmpty
                      ? const SizedBox.shrink() // Invisible si vide
                      : Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: SingleChildScrollView(
                            child: Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: words
                                  .map((w) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green[100],
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: Colors.green[300]!),
                                        ),
                                        child: Text(
                                          w,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.green[800],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    /// Option D: Container avec hauteur min mais fond transparent si vide
    Widget buildOptionD(List<String> words) {
      return MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Expanded(
                child: Container(
                  key: const Key('grid_d'),
                  color: Colors.amber[100],
                ),
              ),
              // Option D: Fond visible seulement si mots présents
              Container(
                constraints: const BoxConstraints(minHeight: 70, maxHeight: 70),
                margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  // Fond transparent si vide, gris si mots
                  color: words.isEmpty ? Colors.transparent : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: words.isEmpty
                      ? null
                      : Border.all(color: Colors.grey[300]!),
                ),
                child: words.isEmpty
                    ? const SizedBox.shrink()
                    : SingleChildScrollView(
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: words
                              .map((w) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green[100],
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.green[300]!),
                                    ),
                                    child: Text(
                                      w,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.green[800],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
              ),
            ],
          ),
        ),
      );
    }

    testWidgets('Option C: Pas de layout shift ET pas de bloc vide', (tester) async {
      // État vide
      await tester.pumpWidget(buildOptionC([]));
      await tester.pumpAndSettle();

      final gridEmpty = tester.getSize(find.byKey(const Key('grid_c')));
      print('📏 [OPTION C] Grille SANS mots: $gridEmpty');

      // Vérifier qu'il n'y a pas de container gris visible
      final greyContainer = find.byWidgetPredicate(
        (w) => w is Container &&
               w.decoration is BoxDecoration &&
               (w.decoration as BoxDecoration).color == Colors.grey[100],
      );
      expect(greyContainer, findsNothing, reason: 'Pas de bloc gris quand vide');
      print('✅ [OPTION C] Pas de bloc gris visible quand vide');

      // Avec un mot
      await tester.pumpWidget(buildOptionC(['MOT']));
      await tester.pumpAndSettle();

      final gridWithWord = tester.getSize(find.byKey(const Key('grid_c')));
      print('📏 [OPTION C] Grille AVEC mot: $gridWithWord');

      // Vérifier qu'il y a maintenant un container
      expect(greyContainer, findsOneWidget, reason: 'Container visible avec mots');
      print('✅ [OPTION C] Container visible avec mots');

      // Pas de layout shift
      expect(gridWithWord, equals(gridEmpty), reason: 'Pas de layout shift');
      print('✅ [OPTION C] Pas de layout shift!');
    });

    testWidgets('Option D: Pas de layout shift ET fond transparent si vide', (tester) async {
      // État vide
      await tester.pumpWidget(buildOptionD([]));
      await tester.pumpAndSettle();

      final gridEmpty = tester.getSize(find.byKey(const Key('grid_d')));
      print('📏 [OPTION D] Grille SANS mots: $gridEmpty');

      // Vérifier container avec fond transparent
      final transparentContainer = find.byWidgetPredicate(
        (w) => w is Container &&
               w.decoration is BoxDecoration &&
               (w.decoration as BoxDecoration).color == Colors.transparent,
      );
      expect(transparentContainer, findsOneWidget);
      print('✅ [OPTION D] Container transparent quand vide');

      // Avec un mot
      await tester.pumpWidget(buildOptionD(['MOT']));
      await tester.pumpAndSettle();

      final gridWithWord = tester.getSize(find.byKey(const Key('grid_d')));
      print('📏 [OPTION D] Grille AVEC mot: $gridWithWord');

      // Container maintenant visible
      final visibleContainer = find.byWidgetPredicate(
        (w) => w is Container &&
               w.decoration is BoxDecoration &&
               (w.decoration as BoxDecoration).color == Colors.grey[100],
      );
      expect(visibleContainer, findsOneWidget);
      print('✅ [OPTION D] Container gris visible avec mots');

      // Pas de layout shift
      expect(gridWithWord, equals(gridEmpty), reason: 'Pas de layout shift');
      print('✅ [OPTION D] Pas de layout shift!');
    });

    testWidgets('Comparaison hauteur container avec plusieurs mots', (tester) async {
      final words = ['MOT', 'TEST', 'CHAT'];

      print('\n========== COMPARAISON AVEC ${words.length} MOTS ==========');

      // Option C
      await tester.pumpWidget(buildOptionC(words));
      await tester.pumpAndSettle();
      final containerC = find.byWidgetPredicate(
        (w) => w is Container &&
               w.decoration is BoxDecoration &&
               (w.decoration as BoxDecoration).color == Colors.grey[100],
      );
      if (containerC.evaluate().isNotEmpty) {
        final sizeC = tester.getSize(containerC);
        print('📦 [OPTION C] Container: $sizeC (s\'adapte au contenu)');
      }

      // Option D
      await tester.pumpWidget(buildOptionD(words));
      await tester.pumpAndSettle();
      final containerD = find.byWidgetPredicate(
        (w) => w is Container &&
               w.decoration is BoxDecoration &&
               (w.decoration as BoxDecoration).color == Colors.grey[100],
      );
      final sizeD = tester.getSize(containerD);
      print('📦 [OPTION D] Container: $sizeD (hauteur fixe 70px)');
    });
  });
}
