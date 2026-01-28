import 'package:flutter_test/flutter_test.dart';
import 'package:froggle_game/config/game_config.dart';

void main() {
  group('GameConfig', () {
    // -------------------------------------------------------
    // P0 - Tests critiques : constantes et calcul de points
    // -------------------------------------------------------

    group('Constantes', () {
      test('[P0] gridSize devrait etre 4', () {
        // GIVEN: La configuration du jeu

        // WHEN: On lit gridSize

        // THEN: La valeur devrait etre 4
        expect(GameConfig.gridSize, equals(4));
      });

      test('[P0] gameDurationSeconds devrait etre 180 (3 minutes)', () {
        // GIVEN: La configuration du jeu

        // WHEN: On lit gameDurationSeconds

        // THEN: La valeur devrait etre 180
        expect(GameConfig.gameDurationSeconds, equals(180));
      });

      test('[P0] maxPlayers devrait etre 6', () {
        // GIVEN: La configuration du jeu

        // WHEN: On lit maxPlayers

        // THEN: La valeur devrait etre 6
        expect(GameConfig.maxPlayers, equals(6));
      });

      test('[P0] minWordLength devrait etre 3', () {
        // GIVEN: La configuration du jeu

        // WHEN: On lit minWordLength

        // THEN: La valeur devrait etre 3
        expect(GameConfig.minWordLength, equals(3));
      });
    });

    group('getPoints', () {
      test('[P0] devrait retourner 0 pour un mot de 2 lettres ou moins', () {
        // GIVEN: Des longueurs de mot <= 2

        // WHEN/THEN: Les points devraient etre 0
        expect(GameConfig.getPoints(0), equals(0));
        expect(GameConfig.getPoints(1), equals(0));
        expect(GameConfig.getPoints(2), equals(0));
      });

      test('[P0] devrait retourner 1 pour un mot de 3 lettres', () {
        // GIVEN: Une longueur de mot de 3

        // WHEN: On calcule les points
        final points = GameConfig.getPoints(3);

        // THEN: Le resultat devrait etre 1
        expect(points, equals(1));
      });

      test('[P0] devrait retourner 1 pour un mot de 4 lettres', () {
        // GIVEN: Une longueur de mot de 4

        // WHEN: On calcule les points
        final points = GameConfig.getPoints(4);

        // THEN: Le resultat devrait etre 1
        expect(points, equals(1));
      });

      test('[P0] devrait retourner 2 pour un mot de 5 lettres', () {
        // GIVEN: Une longueur de mot de 5

        // WHEN: On calcule les points
        final points = GameConfig.getPoints(5);

        // THEN: Le resultat devrait etre 2
        expect(points, equals(2));
      });

      test('[P0] devrait retourner 3 pour un mot de 6 lettres', () {
        // GIVEN: Une longueur de mot de 6

        // WHEN: On calcule les points
        final points = GameConfig.getPoints(6);

        // THEN: Le resultat devrait etre 3
        expect(points, equals(3));
      });

      test('[P0] devrait retourner 5 pour un mot de 7 lettres', () {
        // GIVEN: Une longueur de mot de 7

        // WHEN: On calcule les points
        final points = GameConfig.getPoints(7);

        // THEN: Le resultat devrait etre 5
        expect(points, equals(5));
      });

      test('[P0] devrait retourner 11 pour un mot de 8 lettres ou plus', () {
        // GIVEN: Une longueur de mot de 8

        // WHEN: On calcule les points
        final points = GameConfig.getPoints(8);

        // THEN: Le resultat devrait etre 11
        expect(points, equals(11));
      });
    });

    // -------------------------------------------------------
    // P1 - Tests importants : mots tres longs
    // -------------------------------------------------------

    group('getPoints pour mots tres longs', () {
      test('[P1] devrait retourner 11 pour un mot de 10 lettres', () {
        // GIVEN: Une longueur de mot de 10

        // WHEN: On calcule les points
        final points = GameConfig.getPoints(10);

        // THEN: Le resultat devrait etre 11 (meme regle que 8+)
        expect(points, equals(11));
      });

      test('[P1] devrait retourner 11 pour un mot de 15 lettres', () {
        // GIVEN: Une longueur de mot de 15

        // WHEN: On calcule les points
        final points = GameConfig.getPoints(15);

        // THEN: Le resultat devrait etre 11 (meme regle que 8+)
        expect(points, equals(11));
      });
    });
  });
}
