import 'dart:convert';
import 'package:flutter/services.dart';

class DefinitionService {
  static final DefinitionService _instance = DefinitionService._internal();
  factory DefinitionService() => _instance;
  DefinitionService._internal();

  Map<String, String> _definitions = {};
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  Future<void> loadDefinitions() async {
    if (_isLoaded) return;

    try {
      final String content =
          await rootBundle.loadString('assets/definitions_fr.json');
      final Map<String, dynamic> json = jsonDecode(content);
      _definitions = json.map((k, v) => MapEntry(k, v as String));
      _isLoaded = true;
    } catch (e) {
      _definitions = {};
    }
  }

  /// Returns definitions for a word (lines separated by \n), or null if not found.
  String? getDefinition(String word) {
    final normalized = _normalize(word.toLowerCase());
    return _definitions[normalized];
  }

  /// Returns individual definitions as a list.
  List<String> getDefinitions(String word) {
    final raw = getDefinition(word);
    if (raw == null) return [];
    return raw.split('\n').where((d) => d.isNotEmpty).toList();
  }

  String _normalize(String input) {
    const accented = 'àâäéèêëïîôùûüÿçœæ';
    const replaced = 'aaaeeeeiioouuycoa';
    final buffer = StringBuffer();
    for (final char in input.runes) {
      final c = String.fromCharCode(char);
      final idx = accented.indexOf(c);
      if (idx >= 0) {
        buffer.write(idx < replaced.length ? replaced[idx] : c);
      } else {
        buffer.write(c);
      }
    }
    return buffer.toString();
  }
}
