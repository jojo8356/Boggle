import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  static const String _keyGameDuration = 'game_duration';
  static const String _keyGridZoom = 'grid_zoom';

  // Valeurs par défaut
  static const int defaultGameDuration = 180; // 3 minutes
  static const double defaultGridZoom = 1.0; // 100%
  static const double minZoom = 1.0; // 100%
  static const double maxZoom = 1.5; // 150%

  int _gameDuration = defaultGameDuration;
  double _gridZoom = defaultGridZoom;

  int get gameDuration => _gameDuration;
  double get gridZoom => _gridZoom;

  // Options de durée disponibles (en secondes)
  static const List<int> durationOptions = [60, 120, 180, 240, 300]; // 1, 2, 3, 4, 5 minutes

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _gameDuration = prefs.getInt(_keyGameDuration) ?? defaultGameDuration;
    _gridZoom = prefs.getDouble(_keyGridZoom) ?? defaultGridZoom;
    notifyListeners();
  }

  Future<void> setGameDuration(int seconds) async {
    _gameDuration = seconds;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyGameDuration, seconds);
    notifyListeners();
  }

  Future<void> setGridZoom(double zoom) async {
    _gridZoom = zoom.clamp(minZoom, maxZoom);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyGridZoom, _gridZoom);
    notifyListeners();
  }

  String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (secs == 0) {
      return '$minutes min';
    }
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  String formatZoom(double zoom) {
    return '${(zoom * 100).round()}%';
  }
}
