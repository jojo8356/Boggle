import 'package:flutter_test/flutter_test.dart';
import 'package:froggle_game/core/di/connection_factory.dart';
import 'package:froggle_game/services/connection/connection_interface.dart';
import 'package:froggle_game/services/connection/internet_connection.dart';
import 'package:froggle_game/utils/constants.dart';

void main() {
  group('ConnectionFactory', () {
    group('create', () {
      test('[P0] devrait retourner une InternetConnection pour le type internet', () {
        // GIVEN: Le type de connexion internet

        // WHEN: On cree une connexion
        final connection = ConnectionFactory.create(ConnectionType.internet);

        // THEN: La connexion devrait etre de type InternetConnection
        expect(connection, isA<InternetConnection>());
      });

      test('[P0] devrait retourner une ConnectionInterface pour le type bluetooth', () {
        // GIVEN: Le type de connexion bluetooth

        // WHEN: On cree une connexion
        // Note: Retourne BluetoothConnection ou BluetoothConnectionStub
        // selon la plateforme
        final connection = ConnectionFactory.create(ConnectionType.bluetooth);

        // THEN: La connexion devrait implementer ConnectionInterface
        expect(connection, isA<ConnectionInterface>());
      });

      test('[P0] devrait retourner une ConnectionInterface pour le type wifiDirect', () {
        // GIVEN: Le type de connexion wifiDirect

        // WHEN: On cree une connexion
        // Note: Retourne WifiDirectConnection ou WifiDirectConnectionStub
        // selon la plateforme
        final connection = ConnectionFactory.create(ConnectionType.wifiDirect);

        // THEN: La connexion devrait implementer ConnectionInterface
        expect(connection, isA<ConnectionInterface>());
      });
    });

    group('Interface commune', () {
      test('[P1] toutes les connexions creees implementent ConnectionInterface', () {
        // GIVEN: Tous les types de connexion

        // WHEN: On cree une connexion pour chaque type
        for (final type in ConnectionType.values) {
          final connection = ConnectionFactory.create(type);

          // THEN: Chaque connexion devrait implementer ConnectionInterface
          expect(
            connection,
            isA<ConnectionInterface>(),
            reason: 'ConnectionType.$type devrait retourner une ConnectionInterface',
          );
        }
      });

      test('[P1] les connexions creees ont les callbacks a null par defaut', () {
        // GIVEN: Une connexion fraichement creee

        // WHEN: On cree une connexion internet
        final connection = ConnectionFactory.create(ConnectionType.internet);

        // THEN: Les callbacks devraient etre null par defaut
        expect(connection.onGameUpdate, isNull);
        expect(connection.onPlayerJoined, isNull);
        expect(connection.onPlayerLeft, isNull);
        expect(connection.onGameStart, isNull);
        expect(connection.onGameEnd, isNull);
        expect(connection.onNewGameVote, isNull);
        expect(connection.onWordReceived, isNull);
      });
    });
  });
}
