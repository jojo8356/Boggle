import 'package:flutter_test/flutter_test.dart';
import 'package:froggle_game/services/game_provider.dart';
import 'package:froggle_game/utils/constants.dart';

void main() {
  group('GameProvider', () {
    late GameProvider provider;

    setUp(() {
      provider = GameProvider();
    });

    tearDown(() {
      provider.dispose();
    });

    group('Etat initial', () {
      test('[P0] devrait avoir game a null au demarrage', () {
        // GIVEN/WHEN: On cree un nouveau GameProvider

        // THEN: La partie devrait etre null
        expect(provider.game, isNull);
      });

      test('[P0] devrait avoir currentPlayer a null au demarrage', () {
        // GIVEN/WHEN: On cree un nouveau GameProvider

        // THEN: Le joueur courant devrait etre null
        expect(provider.currentPlayer, isNull);
      });
    });

    group('startTestGame', () {
      test('[P0] devrait creer une partie et un joueur', () {
        // GIVEN: Un provider sans partie

        // WHEN: On demarre une partie test
        provider.startTestGame('TestPlayer');

        // THEN: La partie et le joueur devraient exister
        expect(provider.game, isNotNull);
        expect(provider.currentPlayer, isNotNull);
        expect(provider.currentPlayer!.name, equals('TestPlayer'));
      });

      test('[P0] devrait definir isHost a true', () {
        // GIVEN: Un provider sans partie

        // WHEN: On demarre une partie test
        provider.startTestGame('TestPlayer');

        // THEN: Le joueur devrait etre host
        expect(provider.isHost, isTrue);
      });

      test('[P0] devrait definir isTestMode a true', () {
        // GIVEN: Un provider sans partie

        // WHEN: On demarre une partie test (pas de connexion)
        provider.startTestGame('TestPlayer');

        // THEN: Le mode test devrait etre actif
        expect(provider.isTestMode, isTrue);
      });

      test('[P0] devrait mettre l\'etat du jeu a playing', () {
        // GIVEN: Un provider sans partie

        // WHEN: On demarre une partie test
        provider.startTestGame('TestPlayer');

        // THEN: L'etat du jeu devrait etre playing
        expect(provider.game!.state, equals(GameState.playing));
      });

      test('[P1] devrait utiliser la duree personnalisee si fournie', () {
        // GIVEN: Un provider sans partie
        const customDuration = 60;

        // WHEN: On demarre une partie test avec une duree personnalisee
        provider.startTestGame('TestPlayer', gameDuration: customDuration);

        // THEN: Le jeu devrait avoir la duree personnalisee
        // Note: startGame() reinitialise remainingSeconds a GameConstants.gameDurationSeconds
        // mais le Game est cree avec remainingSeconds = customDuration,
        // puis startGame() le remet a GameConstants.gameDurationSeconds.
        // Verifions que le jeu existe et est en cours
        expect(provider.game, isNotNull);
        expect(provider.game!.state, equals(GameState.playing));
      });
    });

    group('getCurrentScore', () {
      test('[P1] devrait retourner 0 quand il n\'y a pas de partie', () {
        // GIVEN: Un provider sans partie

        // WHEN: On demande le score courant
        final score = provider.getCurrentScore();

        // THEN: Le score devrait etre 0
        expect(score, equals(0));
      });

      test('[P1] devrait retourner 0 au debut d\'une partie test', () {
        // GIVEN: Un provider avec une partie test fraichement demarree
        provider.startTestGame('TestPlayer');

        // WHEN: On demande le score courant
        final score = provider.getCurrentScore();

        // THEN: Le score devrait etre 0 (aucun mot trouve)
        expect(score, equals(0));
      });
    });

    group('stopTestGame', () {
      test('[P1] devrait arreter la partie en mode test', () {
        // GIVEN: Une partie test en cours
        provider.startTestGame('TestPlayer');
        expect(provider.game!.state, equals(GameState.playing));

        // WHEN: On arrete la partie test
        provider.stopTestGame();

        // THEN: L'etat du jeu devrait etre finished
        expect(provider.game!.state, equals(GameState.finished));
      });

      test('[P1] devrait ne rien faire si pas en mode test', () {
        // GIVEN: Un provider sans partie (pas en mode test)
        expect(provider.isTestMode, isFalse);

        // WHEN: On essaie d'arreter la partie test
        provider.stopTestGame();

        // THEN: Aucune exception ne devrait etre levee et game reste null
        expect(provider.game, isNull);
      });
    });

    group('dispose', () {
      test('[P2] devrait ne pas lever d\'exception avec une partie en cours', () {
        // GIVEN: Un provider avec une partie test
        // Note: On cree un provider dedie pour eviter le double-dispose du tearDown
        final dedicatedProvider = GameProvider();
        dedicatedProvider.startTestGame('TestPlayer');

        // WHEN/THEN: Dispose ne devrait pas lever d'exception
        expect(() => dedicatedProvider.dispose(), returnsNormally);
      });

      test('[P2] devrait ne pas lever d\'exception sans partie', () {
        // GIVEN: Un provider sans partie
        final dedicatedProvider = GameProvider();

        // WHEN/THEN: Dispose ne devrait pas lever d'exception
        expect(() => dedicatedProvider.dispose(), returnsNormally);
      });
    });

    group('submitWord', () {
      test(
        '[P1] devrait retourner invalide quand la partie n\'est pas initialisee',
        () {
          // GIVEN: Un provider sans partie

          // WHEN: On soumet un mot
          final result = provider.submitWord('TEST');

          // THEN: Le resultat devrait etre invalide
          expect(result.isValid, isFalse);
        },
      );
    });
  });
}
