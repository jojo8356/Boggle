import 'dart:async';

import 'package:flutter/foundation.dart';

/// Service responsable de la gestion du timer de jeu.
///
/// Encapsule la logique de compte a rebours precedemment dans GameProvider.
/// Emet des notifications a chaque tick via ChangeNotifier et
/// appelle les callbacks [onTick] et [onTimeUp] pour communiquer
/// avec le code appelant.
class TimerService extends ChangeNotifier {
  Timer? _timer;
  int _remainingSeconds;
  final int _initialDuration;

  /// Callback appele a chaque seconde avec le nombre de secondes restantes.
  final void Function(int remainingSeconds)? onTick;

  /// Callback appele lorsque le temps est ecoule.
  final VoidCallback? onTimeUp;

  /// Cree un [TimerService] avec une duree initiale en secondes.
  ///
  /// [initialDuration] : duree totale du timer en secondes.
  /// [onTick] : appele a chaque seconde avec les secondes restantes.
  /// [onTimeUp] : appele lorsque le temps atteint zero.
  TimerService({
    required int initialDuration,
    this.onTick,
    this.onTimeUp,
  })  : _initialDuration = initialDuration,
        _remainingSeconds = initialDuration;

  /// Nombre de secondes restantes.
  int get remainingSeconds => _remainingSeconds;

  /// Duree initiale configuree.
  int get initialDuration => _initialDuration;

  /// Indique si le timer est actuellement en cours.
  bool get isRunning => _timer != null && _timer!.isActive;

  /// Demarre le timer. Si un timer est deja en cours, il est annule
  /// et relance depuis [_remainingSeconds].
  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _remainingSeconds--;
      onTick?.call(_remainingSeconds);
      notifyListeners();

      if (_remainingSeconds <= 0) {
        _timer?.cancel();
        onTimeUp?.call();
      }
    });
  }

  /// Met le timer en pause sans reinitialiser le temps restant.
  void stop() {
    _timer?.cancel();
  }

  /// Annule le timer et reinitialise le temps restant a la duree initiale.
  void reset() {
    _timer?.cancel();
    _remainingSeconds = _initialDuration;
    notifyListeners();
  }

  /// Met a jour le nombre de secondes restantes manuellement.
  /// Utile lors de la synchronisation avec un etat de jeu recu du reseau.
  void setRemainingSeconds(int seconds) {
    _remainingSeconds = seconds;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
