import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test visuel comparatif pour mesurer:
/// 1. L'espace vide en bas (Option actuelle avec SizedBox 78px)
/// 2. Le saut de grille au premier mot (Option originale sans espace réservé)

void main() {
  group('Comparaison Layout - Espace vide vs Saut de grille', () {

    // Simule l'écran de jeu avec dimensions réalistes (iPhone)
    const screenWidth = 390.0;
    const screenHeight = 844.0;
    const safeAreaTop = 47.0;
    const safeAreaBottom = 34.0;

    /// VERSION ACTUELLE: SizedBox 78px réservé (espace vide en bas)
    Widget buildCurrentVersion(List<String> words) {
      return MaterialApp(
        home: Scaffold(
          body: SafeArea(
            child: SizedBox(
              width: screenWidth,
              height: screenHeight - safeAreaTop - safeAreaBottom,
              child: Column(
                children: [
                  // Header (timer + score)
                  Container(
                    height: 50,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(child: Text('Timer + Score')),
                  ),
                  // Grille (Expanded)
                  Expanded(
                    child: Container(
                      key: const Key('grid_current'),
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.brown, width: 2),
                      ),
                      child: const Center(
                        child: Text(
                          'GRILLE 4x4',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Feedback message
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Feedback: +3 points!'),
                  ),
                  // VERSION ACTUELLE: SizedBox 78px réservé
                  SizedBox(
                    height: 78,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                      child: words.isEmpty
                          ? Container(
                              // Visualiser l'espace vide avec bordure pointillée
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.red.withOpacity(0.5),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Text(
                                  '⚠️ ESPACE VIDE 78px',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Wrap(
                                spacing: 4,
                                children: words
                                    .map((w) => Chip(
                                          label: Text(w),
                                          backgroundColor: Colors.green[100],
                                        ))
                                    .toList(),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    /// VERSION ORIGINALE: Pas d'espace réservé (saut de grille)
    Widget buildOriginalVersion(List<String> words) {
      return MaterialApp(
        home: Scaffold(
          body: SafeArea(
            child: SizedBox(
              width: screenWidth,
              height: screenHeight - safeAreaTop - safeAreaBottom,
              child: Column(
                children: [
                  // Header (timer + score)
                  Container(
                    height: 50,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(child: Text('Timer + Score')),
                  ),
                  // Grille (Expanded)
                  Expanded(
                    child: Container(
                      key: const Key('grid_original'),
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.brown, width: 2),
                      ),
                      child: const Center(
                        child: Text(
                          'GRILLE 4x4',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Feedback message
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Feedback: +3 points!'),
                  ),
                  // VERSION ORIGINALE: Pas d'espace si vide
                  if (words.isNotEmpty)
                    Container(
                      constraints: const BoxConstraints(maxHeight: 70),
                      margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Wrap(
                        spacing: 4,
                        children: words
                            .map((w) => Chip(
                                  label: Text(w),
                                  backgroundColor: Colors.green[100],
                                ))
                            .toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('PROBLÈME 1: Mesure de l\'espace vide (version actuelle)', (tester) async {
      print('\n' + '=' * 60);
      print('PROBLÈME 1: ESPACE VIDE EN BAS (VERSION ACTUELLE)');
      print('=' * 60);

      // Sans mots
      await tester.pumpWidget(buildCurrentVersion([]));
      await tester.pumpAndSettle();

      final gridEmpty = tester.getSize(find.byKey(const Key('grid_current')));
      final gridEmptyPos = tester.getTopLeft(find.byKey(const Key('grid_current')));

      print('\n📱 Écran simulé: ${screenWidth}x${screenHeight - safeAreaTop - safeAreaBottom}px');
      print('\n🔲 SANS MOTS:');
      print('   Grille taille: ${gridEmpty.width.toStringAsFixed(0)}x${gridEmpty.height.toStringAsFixed(0)}px');
      print('   Grille position Y: ${gridEmptyPos.dy.toStringAsFixed(0)}px depuis le haut');
      print('   ⚠️  Espace vide réservé en bas: 78px');

      // Avec mots
      await tester.pumpWidget(buildCurrentVersion(['MOT', 'TEST']));
      await tester.pumpAndSettle();

      final gridWithWords = tester.getSize(find.byKey(const Key('grid_current')));

      print('\n🔲 AVEC MOTS:');
      print('   Grille taille: ${gridWithWords.width.toStringAsFixed(0)}x${gridWithWords.height.toStringAsFixed(0)}px');

      final heightDiff = (gridEmpty.height - gridWithWords.height).abs();
      print('\n📊 DIFFÉRENCE DE HAUTEUR: ${heightDiff.toStringAsFixed(1)}px');

      if (heightDiff < 1) {
        print('✅ Pas de layout shift (grille stable)');
      } else {
        print('❌ Layout shift détecté!');
      }

      print('\n⚠️  INCONVÉNIENT: 78px d\'espace vide permanent en bas quand pas de mots');
    });

    testWidgets('PROBLÈME 2: Mesure du saut de grille (version originale)', (tester) async {
      print('\n' + '=' * 60);
      print('PROBLÈME 2: SAUT DE GRILLE (VERSION ORIGINALE)');
      print('=' * 60);

      // Sans mots
      await tester.pumpWidget(buildOriginalVersion([]));
      await tester.pumpAndSettle();

      final gridEmpty = tester.getSize(find.byKey(const Key('grid_original')));
      final gridEmptyPos = tester.getTopLeft(find.byKey(const Key('grid_original')));

      print('\n📱 Écran simulé: ${screenWidth}x${screenHeight - safeAreaTop - safeAreaBottom}px');
      print('\n🔲 SANS MOTS:');
      print('   Grille taille: ${gridEmpty.width.toStringAsFixed(0)}x${gridEmpty.height.toStringAsFixed(0)}px');
      print('   Grille position Y: ${gridEmptyPos.dy.toStringAsFixed(0)}px depuis le haut');
      print('   ✅ Pas d\'espace vide en bas');

      // Avec mots
      await tester.pumpWidget(buildOriginalVersion(['MOT', 'TEST']));
      await tester.pumpAndSettle();

      final gridWithWords = tester.getSize(find.byKey(const Key('grid_original')));
      final gridWithWordsPos = tester.getTopLeft(find.byKey(const Key('grid_original')));

      print('\n🔲 AVEC MOTS:');
      print('   Grille taille: ${gridWithWords.width.toStringAsFixed(0)}x${gridWithWords.height.toStringAsFixed(0)}px');
      print('   Grille position Y: ${gridWithWordsPos.dy.toStringAsFixed(0)}px depuis le haut');

      final heightDiff = gridEmpty.height - gridWithWords.height;
      print('\n📊 SAUT DE GRILLE: ${heightDiff.toStringAsFixed(1)}px');

      if (heightDiff > 1) {
        print('⚠️  La grille RÉTRÉCIT de ${heightDiff.toStringAsFixed(0)}px quand le premier mot est ajouté');
        print('   → Effet visuel: la grille "saute" vers le haut');
      }

      print('\n⚠️  INCONVÉNIENT: Saut visuel déstabilisant au premier mot validé');
    });

    testWidgets('RÉSUMÉ COMPARATIF', (tester) async {
      print('\n' + '=' * 60);
      print('RÉSUMÉ COMPARATIF');
      print('=' * 60);

      // Mesures version actuelle
      await tester.pumpWidget(buildCurrentVersion([]));
      await tester.pumpAndSettle();
      final currentEmpty = tester.getSize(find.byKey(const Key('grid_current')));

      await tester.pumpWidget(buildCurrentVersion(['MOT']));
      await tester.pumpAndSettle();
      final currentWithWord = tester.getSize(find.byKey(const Key('grid_current')));

      // Mesures version originale
      await tester.pumpWidget(buildOriginalVersion([]));
      await tester.pumpAndSettle();
      final originalEmpty = tester.getSize(find.byKey(const Key('grid_original')));

      await tester.pumpWidget(buildOriginalVersion(['MOT']));
      await tester.pumpAndSettle();
      final originalWithWord = tester.getSize(find.byKey(const Key('grid_original')));

      print('\n┌─────────────────────────────────────────────────────────┐');
      print('│                    COMPARAISON                          │');
      print('├─────────────────────────────────────────────────────────┤');
      print('│ VERSION         │ GRILLE VIDE │ GRILLE+MOT │ SHIFT     │');
      print('├─────────────────────────────────────────────────────────┤');
      print('│ Actuelle (78px) │ ${currentEmpty.height.toStringAsFixed(0).padLeft(7)}px   │ ${currentWithWord.height.toStringAsFixed(0).padLeft(6)}px   │ ${(currentEmpty.height - currentWithWord.height).abs().toStringAsFixed(0).padLeft(5)}px   │');
      print('│ Originale       │ ${originalEmpty.height.toStringAsFixed(0).padLeft(7)}px   │ ${originalWithWord.height.toStringAsFixed(0).padLeft(6)}px   │ ${(originalEmpty.height - originalWithWord.height).abs().toStringAsFixed(0).padLeft(5)}px   │');
      print('└─────────────────────────────────────────────────────────┘');

      final shiftOriginal = originalEmpty.height - originalWithWord.height;
      final extraSpaceCurrent = originalEmpty.height - currentEmpty.height;

      print('\n📏 ANALYSE:');
      print('   • Version actuelle: Grille ${extraSpaceCurrent.toStringAsFixed(0)}px plus petite (espace réservé)');
      print('   • Version originale: Saut de ${shiftOriginal.toStringAsFixed(0)}px au premier mot');

      print('\n🎯 CHOIX:');
      print('   1️⃣  Garder espace 78px → Grille plus petite mais STABLE');
      print('   2️⃣  Revenir original   → Grille plus grande mais SAUT au 1er mot');
      print('   3️⃣  Compromis          → Réduire espace réservé (ex: 40px)');
    });
  });
}
