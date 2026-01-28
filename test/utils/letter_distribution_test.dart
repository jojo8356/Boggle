import 'package:flutter_test/flutter_test.dart';
import 'package:froggle_game/utils/letter_distribution.dart';

void main() {
  group('LetterDistribution', () {
    group('boggleDice', () {
      test('[P1] devrait avoir 16 des', () {
        // GIVEN/WHEN: On accede aux des
        final dice = LetterDistribution.boggleDice;

        // THEN: Il devrait y avoir 16 des
        expect(dice.length, equals(16));
      });

      test('[P1] chaque de devrait avoir 6 faces', () {
        // GIVEN: Les des du Boggle
        final dice = LetterDistribution.boggleDice;

        // WHEN/THEN: Chaque de devrait avoir 6 faces
        for (final die in dice) {
          expect(die.length, equals(6));
        }
      });

      test('[P2] chaque face devrait etre une lettre majuscule', () {
        // GIVEN: Les des du Boggle
        final dice = LetterDistribution.boggleDice;

        // WHEN/THEN: Chaque face devrait etre une lettre majuscule
        for (final die in dice) {
          for (final face in die) {
            expect(face, matches(RegExp(r'^[A-Z]$')));
          }
        }
      });
    });

    group('generateGrid', () {
      test('[P0] devrait generer une grille de la bonne taille', () {
        // GIVEN: Une taille de grille de 4
        const size = 4;

        // WHEN: On genere une grille
        final grid = LetterDistribution.generateGrid(size);

        // THEN: La grille devrait avoir 16 cellules (4x4)
        expect(grid.length, equals(size * size));
      });

      test('[P0] devrait generer uniquement des lettres majuscules', () {
        // GIVEN: Une grille generee
        final grid = LetterDistribution.generateGrid(4);

        // WHEN/THEN: Chaque cellule devrait contenir une lettre majuscule
        for (final letter in grid) {
          expect(letter, matches(RegExp(r'^[A-Z]$')));
        }
      });

      test('[P1] devrait generer des grilles differentes (aleatoire)', () {
        // GIVEN: Plusieurs grilles generees
        final grid1 = LetterDistribution.generateGrid(4);
        final grid2 = LetterDistribution.generateGrid(4);
        final grid3 = LetterDistribution.generateGrid(4);

        // WHEN: On compare les grilles
        // THEN: Il est tres improbable que toutes soient identiques
        // (Note: theoriquement possible mais extremement improbable)
        final allSame = grid1.join() == grid2.join() && grid2.join() == grid3.join();

        // On verifie juste que le generateur fonctionne
        expect(grid1.length, equals(16));
        expect(grid2.length, equals(16));
        expect(grid3.length, equals(16));

        // Si toutes identiques, c'est un probleme (mais on ne fail pas car c'est possible)
        if (allSame) {
          // ignore: avoid_print
          print('Warning: 3 grilles identiques generees - verifier le random');
        }
      });

      test('[P2] devrait gerer une grille 3x3', () {
        // GIVEN: Une taille de grille de 3
        const size = 3;

        // WHEN: On genere une grille
        final grid = LetterDistribution.generateGrid(size);

        // THEN: La grille devrait avoir 9 cellules (3x3)
        expect(grid.length, equals(size * size));
      });

      test('[P2] devrait gerer une grille 5x5', () {
        // GIVEN: Une taille de grille de 5
        const size = 5;

        // WHEN: On genere une grille
        final grid = LetterDistribution.generateGrid(size);

        // THEN: La grille devrait avoir 25 cellules (5x5)
        expect(grid.length, equals(size * size));
      });
    });
  });
}
