import 'package:flutter_test/flutter_test.dart';
import 'package:froggle_game/services/score_service.dart';
import 'package:froggle_game/models/word.dart';

void main() {
  group('ScoreService', () {
    late ScoreService scoreService;

    setUp(() {
      scoreService = ScoreService();
    });

    // -------------------------------------------------------
    // P0 - Tests critiques : calcul de points et scores
    // -------------------------------------------------------

    group('getPointsForWordLength', () {
      test('[P0] devrait retourner 0 point pour un mot de 2 lettres', () {
        // GIVEN: Une longueur de mot de 2

        // WHEN: On calcule les points
        final points = scoreService.getPointsForWordLength(2);

        // THEN: Le resultat devrait etre 0
        expect(points, equals(0));
      });

      test('[P0] devrait retourner 1 point pour un mot de 3 lettres', () {
        // GIVEN: Une longueur de mot de 3

        // WHEN: On calcule les points
        final points = scoreService.getPointsForWordLength(3);

        // THEN: Le resultat devrait etre 1
        expect(points, equals(1));
      });

      test('[P0] devrait retourner 1 point pour un mot de 4 lettres', () {
        // GIVEN: Une longueur de mot de 4

        // WHEN: On calcule les points
        final points = scoreService.getPointsForWordLength(4);

        // THEN: Le resultat devrait etre 1
        expect(points, equals(1));
      });

      test('[P0] devrait retourner 2 points pour un mot de 5 lettres', () {
        // GIVEN: Une longueur de mot de 5

        // WHEN: On calcule les points
        final points = scoreService.getPointsForWordLength(5);

        // THEN: Le resultat devrait etre 2
        expect(points, equals(2));
      });

      test('[P0] devrait retourner 3 points pour un mot de 6 lettres', () {
        // GIVEN: Une longueur de mot de 6

        // WHEN: On calcule les points
        final points = scoreService.getPointsForWordLength(6);

        // THEN: Le resultat devrait etre 3
        expect(points, equals(3));
      });

      test('[P0] devrait retourner 5 points pour un mot de 7 lettres', () {
        // GIVEN: Une longueur de mot de 7

        // WHEN: On calcule les points
        final points = scoreService.getPointsForWordLength(7);

        // THEN: Le resultat devrait etre 5
        expect(points, equals(5));
      });

      test('[P0] devrait retourner 11 points pour un mot de 8 lettres', () {
        // GIVEN: Une longueur de mot de 8

        // WHEN: On calcule les points
        final points = scoreService.getPointsForWordLength(8);

        // THEN: Le resultat devrait etre 11
        expect(points, equals(11));
      });
    });

    group('calculatePlayerScore', () {
      test('[P0] devrait calculer le score avec des mots valides', () {
        // GIVEN: Des mots valides pour le joueur "player1"
        final words = [
          Word(text: 'MOT', playerId: 'player1', path: [0, 1, 2]),      // 3 lettres -> 1 pt
          Word(text: 'MOTS', playerId: 'player1', path: [0, 1, 2, 3]),  // 4 lettres -> 1 pt
          Word(text: 'TRAIN', playerId: 'player1', path: [0, 1, 2, 3, 4]), // 5 lettres -> 2 pts
        ];

        // WHEN: On calcule le score du joueur
        final score = scoreService.calculatePlayerScore(words, 'player1');

        // THEN: Le score devrait etre 4 (1 + 1 + 2)
        expect(score, equals(4));
      });

      test('[P0] devrait ignorer les mots des autres joueurs', () {
        // GIVEN: Des mots de differents joueurs
        final words = [
          Word(text: 'MOT', playerId: 'player1', path: [0, 1, 2]),      // 1 pt
          Word(text: 'TRAIN', playerId: 'player2', path: [0, 1, 2, 3, 4]), // 2 pts (autre joueur)
        ];

        // WHEN: On calcule le score de player1
        final score = scoreService.calculatePlayerScore(words, 'player1');

        // THEN: Seul le mot de player1 devrait compter
        expect(score, equals(1));
      });
    });

    // -------------------------------------------------------
    // P1 - Tests importants : doublons, scores multiples, classement
    // -------------------------------------------------------

    group('calculatePlayerScore avec doublons', () {
      test('[P1] devrait ignorer les mots dupliques (effectivePoints = 0)', () {
        // GIVEN: Un mot marque comme duplique
        final words = [
          Word(text: 'MOT', playerId: 'player1', path: [0, 1, 2]),       // 1 pt
          Word(text: 'MOT', playerId: 'player1', path: [0, 1, 2])
            ..isDuplicate = true,                                          // 0 pt (duplique)
        ];

        // WHEN: On calcule le score
        final score = scoreService.calculatePlayerScore(words, 'player1');

        // THEN: Le mot duplique ne devrait pas compter
        expect(score, equals(1));
      });
    });

    group('calculateAllScores', () {
      test('[P1] devrait calculer les scores de tous les joueurs', () {
        // GIVEN: Des mots de plusieurs joueurs
        final words = [
          Word(text: 'MOT', playerId: 'player1', path: [0, 1, 2]),        // 1 pt
          Word(text: 'TRAIN', playerId: 'player1', path: [0, 1, 2, 3, 4]), // 2 pts
          Word(text: 'JEUX', playerId: 'player2', path: [0, 1, 2, 3]),     // 1 pt
        ];

        // WHEN: On calcule tous les scores
        final scores = scoreService.calculateAllScores(words);

        // THEN: Chaque joueur devrait avoir son score total
        expect(scores['player1'], equals(3));
        expect(scores['player2'], equals(1));
        expect(scores.length, equals(2));
      });
    });

    // -------------------------------------------------------
    // P2 - Tests complementaires
    // -------------------------------------------------------

    group('Cas limites', () {
      test('[P2] calculatePlayerScore avec une liste vide devrait retourner 0', () {
        // GIVEN: Une liste de mots vide
        final words = <Word>[];

        // WHEN: On calcule le score
        final score = scoreService.calculatePlayerScore(words, 'player1');

        // THEN: Le score devrait etre 0
        expect(score, equals(0));
      });
    });
  });
}
