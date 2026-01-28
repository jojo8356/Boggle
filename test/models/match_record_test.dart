import 'package:flutter_test/flutter_test.dart';
import 'package:froggle_game/models/match_record.dart';

void main() {
  group('MatchRecord', () {
    // Helper pour creer un MatchRecord de reference
    MatchRecord makeRecord({
      int? id = 1,
      int userId = 42,
      DateTime? playedAt,
      int score = 150,
      int wordsFound = 12,
      int validWords = 10,
      int rank = 1,
      int totalPlayers = 4,
      bool isWin = true,
      bool isSolo = false,
      int gameDuration = 180,
    }) {
      return MatchRecord(
        id: id,
        userId: userId,
        playedAt: playedAt ?? DateTime(2025, 6, 15, 14, 30),
        score: score,
        wordsFound: wordsFound,
        validWords: validWords,
        rank: rank,
        totalPlayers: totalPlayers,
        isWin: isWin,
        isSolo: isSolo,
        gameDuration: gameDuration,
      );
    }

    group('Creation', () {
      test('[P0] devrait creer un MatchRecord avec tous les champs requis', () {
        // GIVEN/WHEN: On cree un MatchRecord
        final record = makeRecord();

        // THEN: Tous les champs devraient etre corrects
        expect(record.id, equals(1));
        expect(record.userId, equals(42));
        expect(record.playedAt, equals(DateTime(2025, 6, 15, 14, 30)));
        expect(record.score, equals(150));
        expect(record.wordsFound, equals(12));
        expect(record.validWords, equals(10));
        expect(record.rank, equals(1));
        expect(record.totalPlayers, equals(4));
        expect(record.isWin, isTrue);
        expect(record.isSolo, isFalse);
        expect(record.gameDuration, equals(180));
      });
    });

    group('toMap', () {
      test('[P0] devrait produire une map avec les bonnes cles', () {
        // GIVEN: Un MatchRecord
        final record = makeRecord();

        // WHEN: On convertit en map
        final map = record.toMap();

        // THEN: La map devrait contenir toutes les cles attendues
        expect(map.containsKey('id'), isTrue);
        expect(map.containsKey('user_id'), isTrue);
        expect(map.containsKey('played_at'), isTrue);
        expect(map.containsKey('score'), isTrue);
        expect(map.containsKey('words_found'), isTrue);
        expect(map.containsKey('valid_words'), isTrue);
        expect(map.containsKey('rank'), isTrue);
        expect(map.containsKey('total_players'), isTrue);
        expect(map.containsKey('is_win'), isTrue);
        expect(map.containsKey('is_solo'), isTrue);
        expect(map.containsKey('game_duration'), isTrue);
      });

      test('[P0] devrait convertir les booleens en entiers (true -> 1, false -> 0)', () {
        // GIVEN: Un MatchRecord avec isWin=true et isSolo=false
        final record = makeRecord(isWin: true, isSolo: false);

        // WHEN: On convertit en map
        final map = record.toMap();

        // THEN: Les booleens devraient etre convertis en entiers
        expect(map['is_win'], equals(1));
        expect(map['is_solo'], equals(0));

        // GIVEN: Un MatchRecord avec isWin=false et isSolo=true
        final record2 = makeRecord(isWin: false, isSolo: true);

        // WHEN: On convertit en map
        final map2 = record2.toMap();

        // THEN: Les booleens devraient etre convertis en entiers
        expect(map2['is_win'], equals(0));
        expect(map2['is_solo'], equals(1));
      });

      test('[P1] devrait inclure un id null dans la map', () {
        // GIVEN: Un MatchRecord sans id
        final record = makeRecord(id: null);

        // WHEN: On convertit en map
        final map = record.toMap();

        // THEN: La cle id devrait etre presente avec la valeur null
        expect(map.containsKey('id'), isTrue);
        expect(map['id'], isNull);
      });
    });

    group('fromMap', () {
      test('[P0] devrait parser correctement une map en MatchRecord', () {
        // GIVEN: Une map valide
        final map = {
          'id': 5,
          'user_id': 42,
          'played_at': '2025-06-15T14:30:00.000',
          'score': 150,
          'words_found': 12,
          'valid_words': 10,
          'rank': 1,
          'total_players': 4,
          'is_win': 1,
          'is_solo': 0,
          'game_duration': 180,
        };

        // WHEN: On parse la map
        final record = MatchRecord.fromMap(map);

        // THEN: Le MatchRecord devrait avoir les bonnes valeurs
        expect(record.id, equals(5));
        expect(record.userId, equals(42));
        expect(record.playedAt, equals(DateTime(2025, 6, 15, 14, 30)));
        expect(record.score, equals(150));
        expect(record.wordsFound, equals(12));
        expect(record.validWords, equals(10));
        expect(record.rank, equals(1));
        expect(record.totalPlayers, equals(4));
        expect(record.isWin, isTrue);
        expect(record.isSolo, isFalse);
        expect(record.gameDuration, equals(180));
      });

      test('[P1] devrait gerer un id null dans la map', () {
        // GIVEN: Une map avec id null
        final map = {
          'id': null,
          'user_id': 42,
          'played_at': '2025-06-15T14:30:00.000',
          'score': 100,
          'words_found': 8,
          'valid_words': 6,
          'rank': 2,
          'total_players': 3,
          'is_win': 0,
          'is_solo': 1,
          'game_duration': 120,
        };

        // WHEN: On parse la map
        final record = MatchRecord.fromMap(map);

        // THEN: L'id devrait etre null
        expect(record.id, isNull);
        expect(record.userId, equals(42));
        expect(record.isSolo, isTrue);
        expect(record.isWin, isFalse);
      });
    });

    group('Roundtrip serialization', () {
      test('[P0] toMap puis fromMap devrait produire un objet equivalent', () {
        // GIVEN: Un MatchRecord original
        final original = makeRecord();

        // WHEN: On fait un aller-retour toMap -> fromMap
        final map = original.toMap();
        final restored = MatchRecord.fromMap(map);

        // THEN: Les champs devraient etre identiques
        expect(restored.id, equals(original.id));
        expect(restored.userId, equals(original.userId));
        expect(restored.playedAt, equals(original.playedAt));
        expect(restored.score, equals(original.score));
        expect(restored.wordsFound, equals(original.wordsFound));
        expect(restored.validWords, equals(original.validWords));
        expect(restored.rank, equals(original.rank));
        expect(restored.totalPlayers, equals(original.totalPlayers));
        expect(restored.isWin, equals(original.isWin));
        expect(restored.isSolo, equals(original.isSolo));
        expect(restored.gameDuration, equals(original.gameDuration));
      });

      test('[P2] la serialisation aller-retour devrait preserver le DateTime', () {
        // GIVEN: Un MatchRecord avec un DateTime precis
        final dateTime = DateTime(2025, 12, 25, 23, 59, 59);
        final original = makeRecord(playedAt: dateTime);

        // WHEN: On fait un aller-retour toMap -> fromMap
        final map = original.toMap();
        final restored = MatchRecord.fromMap(map);

        // THEN: Le DateTime devrait etre preserve
        expect(restored.playedAt.year, equals(2025));
        expect(restored.playedAt.month, equals(12));
        expect(restored.playedAt.day, equals(25));
        expect(restored.playedAt.hour, equals(23));
        expect(restored.playedAt.minute, equals(59));
        expect(restored.playedAt.second, equals(59));
        expect(restored.playedAt, equals(original.playedAt));
      });
    });
  });
}
