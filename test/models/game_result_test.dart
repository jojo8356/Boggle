import 'package:flutter_test/flutter_test.dart';
import 'package:froggle_game/models/game_result.dart';
import 'package:froggle_game/models/word.dart';

void main() {
  group('PlayerResult', () {
    group('Creation', () {
      test('[P0] devrait creer un PlayerResult avec tous les champs', () {
        // GIVEN: Des mots pour le joueur
        final words = [
          Word(text: 'CHAT', playerId: 'p1', path: [0, 1, 2, 3]),
          Word(text: 'CHIEN', playerId: 'p1', path: [4, 5, 6, 7, 8]),
        ];

        // WHEN: On cree un PlayerResult
        final result = PlayerResult(
          playerId: 'p1',
          playerName: 'Joueur 1',
          words: words,
          roundScore: 10,
          totalScore: 25,
        );

        // THEN: Tous les champs devraient etre corrects
        expect(result.playerId, equals('p1'));
        expect(result.playerName, equals('Joueur 1'));
        expect(result.words.length, equals(2));
        expect(result.roundScore, equals(10));
        expect(result.totalScore, equals(25));
      });
    });

  });

  group('GameResult', () {
    // Helper pour creer des PlayerResult rapidement
    PlayerResult makePlayer(String id, String name, int roundScore, int totalScore) {
      return PlayerResult(
        playerId: id,
        playerName: name,
        words: [],
        roundScore: roundScore,
        totalScore: totalScore,
      );
    }

    group('getRanking', () {
      test('[P0] devrait trier les joueurs par totalScore decroissant', () {
        // GIVEN: Un GameResult avec plusieurs joueurs
        final gameResult = GameResult(
          playerResults: [
            makePlayer('p1', 'Joueur 1', 5, 10),
            makePlayer('p2', 'Joueur 2', 12, 30),
            makePlayer('p3', 'Joueur 3', 8, 20),
          ],
          roundNumber: 1,
        );

        // WHEN: On recupere le classement
        final ranking = gameResult.getRanking();

        // THEN: Les joueurs devraient etre tries par totalScore decroissant
        expect(ranking.length, equals(3));
        expect(ranking[0].playerId, equals('p2'));
        expect(ranking[0].totalScore, equals(30));
        expect(ranking[1].playerId, equals('p3'));
        expect(ranking[1].totalScore, equals(20));
        expect(ranking[2].playerId, equals('p1'));
        expect(ranking[2].totalScore, equals(10));
      });

      test('[P2] devrait fonctionner avec un seul joueur', () {
        // GIVEN: Un GameResult avec un seul joueur
        final gameResult = GameResult(
          playerResults: [
            makePlayer('p1', 'Joueur Solo', 7, 42),
          ],
          roundNumber: 1,
        );

        // WHEN: On recupere le classement
        final ranking = gameResult.getRanking();

        // THEN: Le classement devrait contenir un seul joueur
        expect(ranking.length, equals(1));
        expect(ranking[0].playerId, equals('p1'));
        expect(ranking[0].totalScore, equals(42));
      });
    });
  });
}
