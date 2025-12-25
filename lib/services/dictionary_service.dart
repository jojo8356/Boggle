import 'package:flutter/services.dart';

class DictionaryService {
  static final DictionaryService _instance = DictionaryService._internal();
  factory DictionaryService() => _instance;
  DictionaryService._internal();

  Set<String> _words = {};
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  Future<void> loadDictionary() async {
    if (_isLoaded) return;

    try {
      final String content = await rootBundle.loadString('assets/dictionnaire_fr.txt');
      _words = content
          .split('\n')
          .map((word) => _normalize(word.trim().toUpperCase()))
          .where((word) => word.length >= 3)
          .toSet();
      _isLoaded = true;
    } catch (e) {
      throw Exception('Erreur lors du chargement du dictionnaire: $e');
    }
  }

  bool isValidWord(String word) {
    if (!_isLoaded) return false;
    if (word.length < 3) return false;
    return _words.contains(_normalize(word.toUpperCase()));
  }

  String _normalize(String text) {
    const accents = 'àáâãäåçèéêëìíîïñòóôõöùúûüýÿÀÁÂÃÄÅÇÈÉÊËÌÍÎÏÑÒÓÔÕÖÙÚÛÜÝŸ';
    const normalized = 'aaaaaaceeeeiiiinooooouuuuyyAAAAAAEEEEIIIINOOOOOUUUUYY';

    String result = text;
    for (int i = 0; i < accents.length; i++) {
      result = result.replaceAll(accents[i], normalized[i]);
    }
    return result;
  }

  int get wordCount => _words.length;
}
