import 'package:flutter_test/flutter_test.dart';
import 'package:froggle_game/models/game.dart';
import 'package:froggle_game/models/player.dart';
import 'package:froggle_game/models/word.dart';
import 'package:froggle_game/utils/constants.dart';
import 'package:froggle_game/config/game_config.dart';

void main() {
  group('Game', () {
    group('Creation', () {
      test('[P0] devrait creer une partie avec un ID', () {
        // GIVEN/WHEN: On cree une nouvelle partie
        final game = Game(id: 'test-game-1');

        // THEN: La partie devrait avoir l'ID specifie
        expect(game.id, equals('test-game-1'));
      });

      test('[P0] devrait creer une partie avec l\'etat "waiting" par defaut', () {
        // GIVEN/WHEN: On cree une nouvelle partie
        final game = Game(id: 'test-game-1');

        // THEN: L'etat devrait etre "waiting"
        expect(game.state, equals(GameState.waiting));
      });

      test('[P0] devrait creer une partie avec une grille de 16 lettres', () {
        // GIVEN/WHEN: On cree une nouvelle partie
        final game = Game(id: 'test-game-1');

        // THEN: La grille devrait avoir 16 lettres (4x4)
        expect(game.grid.length, equals(16));
      });

      test('[P0] devrait creer une partie sans joueurs initialement', () {
        // GIVEN/WHEN: On cree une nouvelle partie
        final game = Game(id: 'test-game-1');

        // THEN: La liste des joueurs devrait etre vide
        expect(game.players, isEmpty);
      });

      test('[P1] devrait creer une partie au round 1 par defaut', () {
        // GIVEN/WHEN: On cree une nouvelle partie
        final game = Game(id: 'test-game-1');

        // THEN: Le numero de round devrait etre 1
        expect(game.roundNumber, equals(1));
      });

      test('[P1] devrait accepter une grille personnalisee', () {
        // GIVEN: Une grille personnalisee
        final customGrid = List.generate(16, (i) => 'A');

        // WHEN: On cree une partie avec cette grille
        final game = Game(id: 'test-game-1', grid: customGrid);

        // THEN: La grille devrait etre celle fournie
        expect(game.grid, equals(customGrid));
        expect(game.grid.every((letter) => letter == 'A'), isTrue);
      });
    });

    group('Player management', () {
      test('[P0] devrait ajouter un joueur a la partie', () {
        // GIVEN: Une partie vide
        final game = Game(id: 'test-game-1');
        final player = Player(
          id: 'player-1',
          name: 'Joueur 1',
          isHost: true,
        );

        // WHEN: On ajoute un joueur
        game.addPlayer(player);

        // THEN: Le joueur devrait etre dans la liste
        expect(game.players.length, equals(1));
        expect(game.players.first.name, equals('Joueur 1'));
      });

      test('[P0] devrait trouver un joueur par son ID avec getPlayer', () {
        // GIVEN: Une partie avec un joueur
        final game = Game(id: 'test-game-1');
        final player = Player(
          id: 'player-1',
          name: 'Joueur 1',
          isHost: true,
        );
        game.addPlayer(player);

        // WHEN: On cherche le joueur par ID
        final foundPlayer = game.getPlayer('player-1');

        // THEN: Le joueur devrait etre trouve
        expect(foundPlayer, isNotNull);
        expect(foundPlayer!.name, equals('Joueur 1'));
      });

      test('[P1] devrait retourner null pour un ID inexistant', () {
        // GIVEN: Une partie avec un joueur
        final game = Game(id: 'test-game-1');
        final player = Player(
          id: 'player-1',
          name: 'Joueur 1',
          isHost: true,
        );
        game.addPlayer(player);

        // WHEN: On cherche un ID inexistant
        final foundPlayer = game.getPlayer('player-999');

        // THEN: Null devrait etre retourne
        expect(foundPlayer, isNull);
      });

      test('[P1] devrait retirer un joueur de la partie', () {
        // GIVEN: Une partie avec un joueur
        final game = Game(id: 'test-game-1');
        final player = Player(id: 'player-1', name: 'Joueur 1');
        game.addPlayer(player);
        expect(game.players.length, equals(1));

        // WHEN: On retire le joueur
        game.removePlayer('player-1');

        // THEN: La liste devrait etre vide
        expect(game.players, isEmpty);
      });

      test('[P2] devrait respecter la limite maximale de joueurs', () {
        // GIVEN: Une partie
        final game = Game(id: 'test-game-1');

        // WHEN: On ajoute plus de joueurs que le max (6)
        for (int i = 0; i < 10; i++) {
          game.addPlayer(Player(id: 'player-$i', name: 'Joueur $i'));
        }

        // THEN: Le nombre de joueurs devrait etre limite
        expect(game.players.length, lessThanOrEqualTo(GameConfig.maxPlayers));
      });
    });

    group('Game state transitions', () {
      test('[P0] devrait passer de waiting a playing avec startGame', () {
        // GIVEN: Une partie en attente
        final game = Game(id: 'test-game-1');
        game.addPlayer(Player(id: 'p1', name: 'Player 1'));
        expect(game.state, equals(GameState.waiting));

        // WHEN: On demarre la partie
        game.startGame();

        // THEN: L'etat devrait etre "playing"
        expect(game.state, equals(GameState.playing));
      });

      test('[P0] devrait passer de playing a finished avec endGame', () {
        // GIVEN: Une partie en cours
        final game = Game(id: 'test-game-1');
        game.addPlayer(Player(id: 'p1', name: 'Player 1'));
        game.startGame();

        // WHEN: On termine la partie
        game.endGame();

        // THEN: L'etat devrait etre "finished"
        expect(game.state, equals(GameState.finished));
      });

      test('[P1] devrait reinitialiser les mots des joueurs au demarrage', () {
        // GIVEN: Une partie avec un joueur qui a des mots
        final game = Game(id: 'test-game-1');
        final player = Player(id: 'p1', name: 'Player 1');
        player.addWord('TEST');
        game.addPlayer(player);

        // WHEN: On demarre une nouvelle partie
        game.startGame();

        // THEN: Les mots du joueur devraient etre vides
        expect(game.players.first.foundWords, isEmpty);
      });
    });

    group('Word management', () {
      test('[P0] devrait permettre d\'ajouter des mots a allWords', () {
        // GIVEN: Une partie en cours
        final game = Game(id: 'test-game-1');
        game.addPlayer(Player(id: 'p1', name: 'Player 1'));
        game.startGame();

        final word = Word(
          text: 'CHAT',
          playerId: 'p1',
          path: [0, 1, 2, 3],
        );

        // WHEN: On ajoute un mot
        game.allWords.add(word);

        // THEN: Le mot devrait etre dans la liste
        expect(game.allWords.length, equals(1));
        expect(game.allWords.first.text, equals('CHAT'));
      });

      test('[P1] devrait marquer les doublons a la fin de la partie', () {
        // GIVEN: Une partie avec deux joueurs ayant trouve le meme mot
        final game = Game(id: 'test-game-1');
        game.addPlayer(Player(id: 'p1', name: 'Player 1'));
        game.addPlayer(Player(id: 'p2', name: 'Player 2'));
        game.startGame();

        game.allWords.add(Word(text: 'CHAT', playerId: 'p1', path: [0, 1, 2, 3]));
        game.allWords.add(Word(text: 'CHAT', playerId: 'p2', path: [0, 1, 2, 3]));

        // WHEN: On termine la partie
        game.endGame();

        // THEN: Les deux mots devraient etre marques comme doublons
        expect(game.allWords[0].isDuplicate, isTrue);
        expect(game.allWords[1].isDuplicate, isTrue);
      });

      test('[P1] devrait recuperer les mots d\'un joueur specifique', () {
        // GIVEN: Une partie avec des mots de differents joueurs
        final game = Game(id: 'test-game-1');
        game.addPlayer(Player(id: 'p1', name: 'Player 1'));
        game.addPlayer(Player(id: 'p2', name: 'Player 2'));
        game.startGame();

        game.allWords.add(Word(text: 'CHAT', playerId: 'p1', path: [0, 1, 2, 3]));
        game.allWords.add(Word(text: 'CHIEN', playerId: 'p2', path: [0, 1, 2, 3, 4]));
        game.allWords.add(Word(text: 'OISEAU', playerId: 'p1', path: [0, 1, 2, 3, 4, 5]));

        // WHEN: On recupere les mots du joueur 1
        final p1Words = game.getPlayerWords('p1');

        // THEN: On devrait avoir 2 mots
        expect(p1Words.length, equals(2));
        expect(p1Words.map((w) => w.text), containsAll(['CHAT', 'OISEAU']));
      });
    });

    group('Points calculation', () {
      test('[P0] devrait calculer 1 point pour un mot de 3 lettres', () {
        expect(GameConstants.getPoints(3), equals(1));
      });

      test('[P0] devrait calculer 1 point pour un mot de 4 lettres', () {
        expect(GameConstants.getPoints(4), equals(1));
      });

      test('[P0] devrait calculer 2 points pour un mot de 5 lettres', () {
        expect(GameConstants.getPoints(5), equals(2));
      });

      test('[P1] devrait calculer 3 points pour un mot de 6 lettres', () {
        expect(GameConstants.getPoints(6), equals(3));
      });

      test('[P1] devrait calculer 5 points pour un mot de 7 lettres', () {
        expect(GameConstants.getPoints(7), equals(5));
      });

      test('[P1] devrait calculer 11 points pour un mot de 8+ lettres', () {
        expect(GameConstants.getPoints(8), equals(11));
        expect(GameConstants.getPoints(10), equals(11));
        expect(GameConstants.getPoints(15), equals(11));
      });
    });

    group('JSON serialization', () {
      test('[P2] devrait serialiser une partie en JSON', () {
        // GIVEN: Une partie
        final game = Game(
          id: 'test-game-1',
          grid: List.generate(16, (i) => 'A'),
        );
        game.addPlayer(Player(id: 'p1', name: 'Player 1'));

        // WHEN: On serialise en JSON
        final json = game.toJson();

        // THEN: Le JSON devrait contenir les bonnes cles
        expect(json['id'], equals('test-game-1'));
        expect(json['grid'], isA<List>());
        expect(json['players'], isA<List>());
      });

      test('[P2] devrait deserialiser une partie depuis JSON', () {
        // GIVEN: Un JSON de partie
        final json = {
          'id': 'test-game-1',
          'grid': List.generate(16, (i) => 'B'),
          'players': [
            {'id': 'p1', 'name': 'Player 1', 'isHost': true, 'state': 0, 'score': 0, 'foundWords': [], 'votedForNewGame': false}
          ],
          'state': 0,
          'remainingSeconds': 180,
          'allWords': [],
          'roundNumber': 1,
        };

        // WHEN: On deserialise
        final game = Game.fromJson(json);

        // THEN: La partie devrait etre correcte
        expect(game.id, equals('test-game-1'));
        expect(game.grid.every((l) => l == 'B'), isTrue);
        expect(game.players.length, equals(1));
      });
    });
  });

  group('Player', () {
    test('[P0] devrait creer un joueur avec les bonnes proprietes', () {
      // GIVEN/WHEN: On cree un joueur
      final player = Player(
        id: 'player-1',
        name: 'TestPlayer',
        isHost: true,
      );

      // THEN: Les proprietes devraient etre correctes
      expect(player.id, equals('player-1'));
      expect(player.name, equals('TestPlayer'));
      expect(player.isHost, isTrue);
      expect(player.score, equals(0));
      expect(player.state, equals(PlayerState.connected));
      expect(player.foundWords, isEmpty);
    });

    test('[P0] devrait ajouter un mot a la liste foundWords', () {
      // GIVEN: Un joueur sans mots
      final player = Player(
        id: 'player-1',
        name: 'TestPlayer',
      );
      expect(player.foundWords, isEmpty);

      // WHEN: On ajoute un mot
      player.addWord('CHAT');

      // THEN: Le mot devrait etre dans la liste (en majuscules)
      expect(player.foundWords.length, equals(1));
      expect(player.foundWords.first, equals('CHAT'));
    });

    test('[P1] devrait ne pas ajouter un mot en double', () {
      // GIVEN: Un joueur avec un mot
      final player = Player(id: 'player-1', name: 'TestPlayer');
      player.addWord('CHAT');

      // WHEN: On essaie d'ajouter le meme mot
      player.addWord('CHAT');
      player.addWord('chat'); // en minuscules

      // THEN: Le mot ne devrait pas etre en double
      expect(player.foundWords.length, equals(1));
    });

    test('[P1] devrait reinitialiser pour une nouvelle partie', () {
      // GIVEN: Un joueur avec des mots et un vote
      final player = Player(id: 'player-1', name: 'TestPlayer');
      player.addWord('CHAT');
      player.votedForNewGame = true;

      // WHEN: On reinitialise
      player.resetForNewGame();

      // THEN: Les mots et le vote devraient etre reinitialises
      expect(player.foundWords, isEmpty);
      expect(player.votedForNewGame, isFalse);
    });
  });

  group('Word', () {
    test('[P0] devrait creer un mot avec les bonnes proprietes', () {
      // GIVEN/WHEN: On cree un mot
      final word = Word(
        text: 'TEST',
        playerId: 'player-1',
        path: [0, 1, 2, 3],
      );

      // THEN: Les proprietes devraient etre correctes
      expect(word.text, equals('TEST'));
      expect(word.playerId, equals('player-1'));
      expect(word.path, equals([0, 1, 2, 3]));
      expect(word.isDuplicate, isFalse);
      expect(word.isInvalid, isFalse);
    });

    test('[P0] devrait calculer les points automatiquement selon la longueur', () {
      // GIVEN/WHEN: On cree des mots de differentes longueurs
      final word3 = Word(text: 'MOT', playerId: 'p1', path: [0, 1, 2]);
      final word5 = Word(text: 'MATIN', playerId: 'p1', path: [0, 1, 2, 3, 4]);
      final word8 = Word(text: 'MALADIES', playerId: 'p1', path: [0, 1, 2, 3, 4, 5, 6, 7]);

      // THEN: Les points devraient etre calcules correctement
      expect(word3.points, equals(1)); // 3 lettres = 1 point
      expect(word5.points, equals(2)); // 5 lettres = 2 points
      expect(word8.points, equals(11)); // 8 lettres = 11 points
    });

    test('[P1] devrait retourner 0 points effectifs si doublon', () {
      // GIVEN: Un mot marque comme doublon
      final word = Word(
        text: 'TEST',
        playerId: 'player-1',
        path: [0, 1, 2, 3],
        isDuplicate: true,
      );

      // WHEN/THEN: Les points effectifs devraient etre 0
      expect(word.points, equals(1)); // Points de base
      expect(word.effectivePoints, equals(0)); // Points effectifs = 0
    });

    test('[P1] devrait retourner 0 points effectifs si invalide', () {
      // GIVEN: Un mot marque comme invalide
      final word = Word(
        text: 'XYZABC',
        playerId: 'player-1',
        path: [0, 1, 2, 3, 4, 5],
        isInvalid: true,
      );

      // WHEN/THEN: Les points effectifs devraient etre 0
      expect(word.effectivePoints, equals(0));
    });

    test('[P1] devrait retourner les points normaux si valide et non doublon', () {
      // GIVEN: Un mot valide non doublon
      final word = Word(
        text: 'MAISON',
        playerId: 'player-1',
        path: [0, 1, 2, 3, 4, 5],
      );

      // WHEN/THEN: Les points effectifs devraient etre les points normaux
      expect(word.effectivePoints, equals(3)); // 6 lettres = 3 points
    });
  });
}
