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
      _words = content
          .split('\n')
          .map((word) => _normalize(word.trim().toUpperCase()))
          .where((word) => word.length >= 3)
          .where((word) => !_isConjugatedVerb(word))
          .toSet();

      // Construire le Trie pour recherche de préfixes
      _buildTrie();
      _isLoaded = true;
    } catch (e) {
      throw Exception('Erreur lors du chargement du dictionnaire: $e');
    }
  }

  /// Vérifie si un mot est probablement un verbe conjugué
  bool _isConjugatedVerb(String word) {
    if (word.length < 4) return false;

    // Terminaisons de conjugaison françaises (normalisées sans accents)
    final conjugationEndings = [
      // Présent pluriel
      'ONS', 'EZ', 'ENT',
      // Imparfait
      'AIS', 'AIT', 'IONS', 'IEZ', 'AIENT',
      // Passé simple
      'AMES', 'ATES', 'ERENT', 'IMES', 'ITES', 'IRENT', 'UMES', 'UTES', 'URENT',
      // Futur
      'ERAI', 'ERAS', 'ERA', 'ERONS', 'EREZ', 'ERONT',
      'IRAI', 'IRAS', 'IRA', 'IRONS', 'IREZ', 'IRONT',
      // Conditionnel
      'ERAIS', 'ERAIT', 'ERIONS', 'ERIEZ', 'ERAIENT',
      'IRAIS', 'IRAIT', 'IRIONS', 'IRIEZ', 'IRAIENT',
      // Subjonctif présent
      'ASSE', 'ASSES', 'ASSENT', 'ISSIONS', 'ISSIEZ', 'ISSENT',
      // Subjonctif imparfait
      'ASSES', 'ASSIONS', 'ASSIEZ', 'ASSENT',
      // Participe présent
      'ANT',
      // Impératif pluriel (déjà couvert par ONS, EZ)
    ];

    // Mots courants à ne pas exclure (faux positifs)
    final exceptions = {
      'PONT', 'FONT', 'MONT', 'DONT', 'RONT', 'SONT', 'VONT', 'TANT', 'GANT',
      'VENT', 'DENT', 'LENT', 'CENT', 'SENT', 'MENT', 'RENT', 'TENT',
      'AVANT', 'ENFANT', 'GEANT', 'ISANT', 'ETANT', 'AYANT',
      'PARENT', 'ARGENT', 'AGENT', 'URGENT', 'ACCENT', 'MOMENT', 'CEMENT',
      'SERPENT', 'CONTENT', 'PRESENT', 'ABSENT', 'PATIENT', 'ORIENT',
      'AUTANT', 'POURTANT', 'CEPENDANT', 'PENDANT', 'MAINTENANT',
      'RESTAURANT', 'INSTANT', 'DISTANT', 'CONSTANT', 'ELEPHANT',
      'DIAMANT', 'AIMANT', 'VOLANT', 'GALANT', 'BRILLANT', 'ECLATANT',
      'HABITANT', 'IMPORTANT', 'INTERESSANT', 'AMUSANT', 'PASSANT',
      'SAVANT', 'VIVANT', 'SUIVANT', 'DEVANT', 'LEVANT', 'CROISSANT',
      'CROISANT', 'PUISSANT', 'GLISSANT', 'NAISSANT', 'AGISSANT',
      'BLANC', 'FRANC', 'BANC',
      'HORIZON', 'PRISON', 'RAISON', 'SAISON', 'MAISON', 'POISON', 'POISSON',
      'LESSON', 'TRONCON', 'GARCON', 'FACON', 'LECON', 'SOUPCON', 'RANCON',
      'CHANSON', 'ISSON',
      'ASSEZ', 'CHEZ', 'NEZ',
      'JAMAIS', 'MAIS', 'DESORMAIS', 'PALAIS', 'MARAIS', 'RELAIS', 'BIAIS',
      'BALAIS', 'RABAIS', 'DELAI', 'ESSAI', 'MINERAI', 'QUAI', 'VRAI',
      'BOIS', 'FOIS', 'MOIS', 'POIS', 'TOIT', 'DROIT', 'FROID', 'ETROIT',
      'EXPLOIT', 'DETROIT',
      'FUT', 'BUT', 'MUR', 'SUR', 'DUR', 'PUR', 'AZUR',
      'DEBUT', 'SALUT', 'STATUT', 'TRIBUT', 'ATTRIBUT',
    };

    if (exceptions.contains(word)) return false;

    for (final ending in conjugationEndings) {
      if (word.endsWith(ending) && word.length > ending.length + 1) {
        return true;
      }
    }

    return false;
  }

  void _buildTrie() {
    _root = TrieNode();
    for (final word in _words) {
      _insertWord(word);
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
