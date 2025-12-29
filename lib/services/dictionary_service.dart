import 'package:flutter/services.dart';

/// Noeud du Trie pour la recherche rapide de préfixes
class TrieNode {
  final Map<String, TrieNode> children = {};
  bool isWord = false;
}

class DictionaryService {
  static final DictionaryService _instance = DictionaryService._internal();
  factory DictionaryService() => _instance;
  DictionaryService._internal();

  Set<String> _words = {};
  TrieNode _root = TrieNode();
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  Future<void> loadDictionary() async {
    if (_isLoaded) return;

    try {
      final String content = await rootBundle.loadString('assets/dictionnaire_fr.txt');
      final lines = content.split('\n');

      // Pré-allouer la capacité pour éviter les réallocations
      _words = <String>{};
      _root = TrieNode();

      // Traiter et insérer dans le Trie en une seule passe
      for (final line in lines) {
        final word = _normalize(line.trim().toUpperCase());
        if (word.length >= 3) {
          _words.add(word);
          _insertWord(word);
        }
      }

      _isLoaded = true;
    } catch (e) {
      throw Exception('Erreur lors du chargement du dictionnaire: $e');
    }
  }

  void _insertWord(String word) {
    TrieNode node = _root;
    for (int i = 0; i < word.length; i++) {
      final char = word[i];
      node.children.putIfAbsent(char, () => TrieNode());
      node = node.children[char]!;
    }
    node.isWord = true;
  }

  bool isValidWord(String word) {
    if (!_isLoaded) return false;
    if (word.length < 3) return false;
    return _words.contains(_normalize(word.toUpperCase()));
  }

  /// Vérifie si un préfixe existe dans le dictionnaire (pour élagage)
  bool hasPrefix(String prefix) {
    if (!_isLoaded) return false;
    prefix = _normalize(prefix.toUpperCase());

    TrieNode node = _root;
    for (int i = 0; i < prefix.length; i++) {
      final char = prefix[i];
      if (!node.children.containsKey(char)) {
        return false;
      }
      node = node.children[char]!;
    }
    return true;
  }

  /// Vérifie si un préfixe existe et si c'est aussi un mot valide
  (bool hasPrefix, bool isWord) checkPrefix(String prefix) {
    if (!_isLoaded) return (false, false);
    prefix = _normalize(prefix.toUpperCase());

    TrieNode node = _root;
    for (int i = 0; i < prefix.length; i++) {
      final char = prefix[i];
      if (!node.children.containsKey(char)) {
        return (false, false);
      }
      node = node.children[char]!;
    }
    return (true, node.isWord && prefix.length >= 3);
  }

  String _normalize(String text) {
    const Map<String, String> accentMap = {
      'à': 'A', 'á': 'A', 'â': 'A', 'ã': 'A', 'ä': 'A', 'å': 'A',
      'ç': 'C',
      'è': 'E', 'é': 'E', 'ê': 'E', 'ë': 'E',
      'ì': 'I', 'í': 'I', 'î': 'I', 'ï': 'I',
      'ñ': 'N',
      'ò': 'O', 'ó': 'O', 'ô': 'O', 'õ': 'O', 'ö': 'O',
      'ù': 'U', 'ú': 'U', 'û': 'U', 'ü': 'U',
      'ý': 'Y', 'ÿ': 'Y',
      'À': 'A', 'Á': 'A', 'Â': 'A', 'Ã': 'A', 'Ä': 'A', 'Å': 'A',
      'Ç': 'C',
      'È': 'E', 'É': 'E', 'Ê': 'E', 'Ë': 'E',
      'Ì': 'I', 'Í': 'I', 'Î': 'I', 'Ï': 'I',
      'Ñ': 'N',
      'Ò': 'O', 'Ó': 'O', 'Ô': 'O', 'Õ': 'O', 'Ö': 'O',
      'Ù': 'U', 'Ú': 'U', 'Û': 'U', 'Ü': 'U',
      'Ý': 'Y', 'Ÿ': 'Y',
    };

    StringBuffer result = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      String char = text[i].toUpperCase();
      result.write(accentMap[char] ?? char);
    }
    return result.toString();
  }

  int get wordCount => _words.length;
}
