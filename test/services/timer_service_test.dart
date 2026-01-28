import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:froggle_game/services/timer_service.dart';

void main() {
  group('TimerService', () {
    late TimerService timerService;

    setUp(() {
      timerService = TimerService(initialDuration: 180);
    });

    tearDown(() {
      timerService.dispose();
    });

    // -------------------------------------------------------
    // P0 - Tests critiques : etat initial et operations de base
    // -------------------------------------------------------

    group('Etat initial', () {
      test('[P0] devrait avoir remainingSeconds egal a initialDuration', () {
        // GIVEN: Un TimerService fraichement cree avec 180 secondes

        // WHEN: On lit remainingSeconds

        // THEN: La valeur devrait etre 180
        expect(timerService.remainingSeconds, equals(180));
      });

      test('[P0] devrait avoir initialDuration correctement configure', () {
        // GIVEN: Un TimerService cree avec 180 secondes

        // WHEN: On lit initialDuration

        // THEN: La valeur devrait etre 180
        expect(timerService.initialDuration, equals(180));
      });

      test('[P0] devrait ne pas etre en cours (isRunning == false)', () {
        // GIVEN: Un TimerService fraichement cree

        // WHEN: On verifie isRunning

        // THEN: Le timer ne devrait pas etre en cours
        expect(timerService.isRunning, isFalse);
      });
    });

    group('start()', () {
      test('[P0] devrait mettre isRunning a true', () {
        // GIVEN: Un TimerService a l\'arret

        // WHEN: On demarre le timer
        timerService.start();

        // THEN: Le timer devrait etre en cours
        expect(timerService.isRunning, isTrue);
      });
    });

    group('stop()', () {
      test('[P0] devrait mettre isRunning a false', () {
        // GIVEN: Un TimerService en cours
        timerService.start();
        expect(timerService.isRunning, isTrue);

        // WHEN: On arrete le timer
        timerService.stop();

        // THEN: Le timer ne devrait plus etre en cours
        expect(timerService.isRunning, isFalse);
      });
    });

    group('reset()', () {
      test('[P0] devrait reinitialiser remainingSeconds a initialDuration', () {
        // GIVEN: Un TimerService dont le temps restant a ete modifie
        timerService.setRemainingSeconds(50);
        expect(timerService.remainingSeconds, equals(50));

        // WHEN: On reinitialise le timer
        timerService.reset();

        // THEN: remainingSeconds devrait revenir a la duree initiale
        expect(timerService.remainingSeconds, equals(180));
        expect(timerService.isRunning, isFalse);
      });
    });

    group('setRemainingSeconds()', () {
      test('[P0] devrait mettre a jour la valeur de remainingSeconds', () {
        // GIVEN: Un TimerService avec 180 secondes

        // WHEN: On definit manuellement les secondes restantes
        timerService.setRemainingSeconds(42);

        // THEN: La valeur devrait etre mise a jour
        expect(timerService.remainingSeconds, equals(42));
      });
    });

    // -------------------------------------------------------
    // P1 - Tests importants : callbacks et comportement temporel
    // -------------------------------------------------------

    group('Callbacks avec fakeAsync', () {
      test('[P1] start() devrait appeler onTick apres 1 seconde', () {
        fakeAsync((async) {
          // GIVEN: Un TimerService avec un callback onTick
          int? tickValue;
          final service = TimerService(
            initialDuration: 10,
            onTick: (remaining) {
              tickValue = remaining;
            },
          );

          // WHEN: On demarre le timer et on avance de 1 seconde
          service.start();
          async.elapse(const Duration(seconds: 1));

          // THEN: onTick devrait avoir ete appele avec 9 secondes restantes
          expect(tickValue, equals(9));

          service.dispose();
        });
      });

      test('[P1] le timer devrait atteindre zero et appeler onTimeUp', () {
        fakeAsync((async) {
          // GIVEN: Un TimerService de 3 secondes avec un callback onTimeUp
          bool timeUpCalled = false;
          final service = TimerService(
            initialDuration: 3,
            onTimeUp: () {
              timeUpCalled = true;
            },
          );

          // WHEN: On demarre et on avance de 3 secondes
          service.start();
          async.elapse(const Duration(seconds: 3));

          // THEN: onTimeUp devrait avoir ete appele
          expect(timeUpCalled, isTrue);
          expect(service.remainingSeconds, equals(0));

          service.dispose();
        });
      });

      test('[P1] stop() apres start() devrait preserver le temps restant', () {
        fakeAsync((async) {
          // GIVEN: Un TimerService demarre depuis 2 secondes
          final service = TimerService(initialDuration: 10);
          service.start();
          async.elapse(const Duration(seconds: 2));
          expect(service.remainingSeconds, equals(8));

          // WHEN: On arrete le timer
          service.stop();

          // THEN: Le temps restant devrait etre preserve a 8
          expect(service.remainingSeconds, equals(8));
          expect(service.isRunning, isFalse);

          // Et le temps ne devrait plus avancer
          async.elapse(const Duration(seconds: 2));
          expect(service.remainingSeconds, equals(8));

          service.dispose();
        });
      });
    });

    // -------------------------------------------------------
    // P2 - Tests complementaires
    // -------------------------------------------------------

    group('dispose()', () {
      test('[P2] devrait annuler le timer en cours', () {
        fakeAsync((async) {
          // GIVEN: Un TimerService en cours
          final service = TimerService(initialDuration: 10);
          service.start();
          expect(service.isRunning, isTrue);

          // WHEN: On dispose le service
          service.dispose();

          // THEN: Le timer devrait etre annule (pas d'erreur apres elapse)
          async.elapse(const Duration(seconds: 5));
          // Si dispose n'avait pas annule, on aurait une erreur ou un timer fantome
        });
      });
    });
  });
}
