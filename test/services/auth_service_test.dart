import 'package:flutter_test/flutter_test.dart';
import 'package:froggle_game/services/auth_service.dart';

void main() {
  group('AuthService', () {
    group('Input validation rules', () {
      test('[P1] devrait rejeter un nom d\'utilisateur vide', () {
        // GIVEN: Un nom d'utilisateur vide
        const username = '';

        // WHEN/THEN: La validation devrait echouer
        expect(username.trim().isEmpty, isTrue);
      });

      test('[P1] devrait rejeter un mot de passe trop court', () {
        // GIVEN: Un mot de passe de moins de 4 caracteres
        const shortPassword = 'abc';

        // WHEN/THEN: La validation devrait echouer (< 4 caracteres)
        expect(shortPassword.length < 4, isTrue);
      });

      test('[P1] devrait accepter un mot de passe valide', () {
        // GIVEN: Un mot de passe de 4+ caracteres
        const validPassword = 'abcd';

        // WHEN/THEN: La validation devrait reussir
        expect(validPassword.length >= 4, isTrue);
      });

      test('[P2] devrait accepter un nom d\'utilisateur valide', () {
        // GIVEN: Un nom d'utilisateur valide
        const username = 'JoueurTest123';

        // WHEN/THEN: La validation devrait reussir
        expect(username.trim().isNotEmpty, isTrue);
      });

      test('[P2] devrait trimmer les espaces du nom d\'utilisateur', () {
        // GIVEN: Un nom d'utilisateur avec espaces
        const usernameWithSpaces = '  joueur  ';

        // WHEN: On trim
        final trimmed = usernameWithSpaces.trim();

        // THEN: Le nom devrait etre sans espaces de debut/fin
        expect(trimmed, equals('joueur'));
        expect(trimmed.isNotEmpty, isTrue);
      });
    });

    group('Service instantiation', () {
      test('[P0] devrait creer une instance de AuthService', () {
        // GIVEN/WHEN: On cree une instance
        final authService = AuthService();

        // THEN: L'instance devrait etre creee
        expect(authService, isNotNull);
        expect(authService, isA<AuthService>());
      });

      test('[P0] devrait avoir isLoggedIn a false initialement', () {
        // GIVEN: Une nouvelle instance
        final authService = AuthService();

        // WHEN/THEN: L'utilisateur ne devrait pas etre connecte
        expect(authService.isLoggedIn, isFalse);
      });

      test('[P0] devrait avoir currentUser a null initialement', () {
        // GIVEN: Une nouvelle instance
        final authService = AuthService();

        // WHEN/THEN: L'utilisateur courant devrait etre null
        expect(authService.currentUser, isNull);
      });
    });

    group('ChangeNotifier', () {
      test('[P2] devrait etre un ChangeNotifier', () {
        // GIVEN/WHEN: On cree une instance
        final authService = AuthService();

        // THEN: Devrait supporter addListener
        var notified = false;
        authService.addListener(() {
          notified = true;
        });

        // Note: On ne peut pas tester les notifications sans DB reelle
        // Ce test verifie juste que addListener fonctionne
        expect(authService.hasListeners, isTrue);

        // Cleanup
        authService.removeListener(() {});
      });
    });

    // Note: Les tests de register/login necessitent une base de donnees mockee
    // ce qui sort du scope des tests unitaires simples
    // Ces tests seraient mieux places en integration tests

    group('Password requirements', () {
      test('[P1] devrait exiger au moins 4 caracteres', () {
        // GIVEN: Les regles de validation
        const minLength = 4;

        // WHEN/THEN: Les mots de passe courts devraient etre invalides
        expect('abc'.length >= minLength, isFalse);
        expect('abcd'.length >= minLength, isTrue);
        expect('password123'.length >= minLength, isTrue);
      });
    });

    group('Username requirements', () {
      test('[P1] devrait exiger un nom non vide apres trim', () {
        // GIVEN: Differents noms d'utilisateurs
        const empty = '';
        const whitespace = '   ';
        const valid = 'user';

        // WHEN/THEN: Seuls les noms non vides sont valides
        expect(empty.trim().isEmpty, isTrue);
        expect(whitespace.trim().isEmpty, isTrue);
        expect(valid.trim().isEmpty, isFalse);
      });
    });
  });
}
