import '../utils/constants.dart';
import 'dictionary_service.dart';

class GameLogicService {
  final DictionaryService _dictionaryService = DictionaryService();

  static const List<List<int>> _adjacencies = [
    [1, 3, 4],         // 0: droite, bas, diagonale bas-droite
    [0, 2, 3, 4, 5],   // 1: gauche, droite, diagonales et bas
    [1, 4, 5],         // 2: gauche, bas, diagonale bas-gauche
    [0, 1, 4, 6, 7],   // 3: haut, diagonales et droite, bas
    [0, 1, 2, 3, 5, 6, 7, 8], // 4: centre - toutes les directions
    [1, 2, 4, 7, 8],   // 5: haut, diagonales et gauche, bas
    [3, 4, 7],         // 6: haut, droite, diagonale haut-droite
    [3, 4, 5, 6, 8],   // 7: haut, diagonales et gauche, droite
    [4, 5, 7],         // 8: haut, gauche, diagonale haut-gauche
  ];

  bool areAdjacent(int pos1, int pos2) {
    if (pos1 < 0 || pos1 >= 9 || pos2 < 0 || pos2 >= 9) return false;
    return _adjacencies[pos1].contains(pos2);
  }

  bool isValidPath(List<int> path) {
    if (path.isEmpty) return false;
    if (path.length != path.toSet().length) return false; // pas de répétition

    for (int i = 0; i < path.length - 1; i++) {
      if (!areAdjacent(path[i], path[i + 1])) {
        return false;
      }
    }
    return true;
  }

  String getWordFromPath(List<String> grid, List<int> path) {
    return path.map((index) => grid[index]).join();
  }

  bool isValidWord(String word) {
    return _dictionaryService.isValidWord(word);
  }

  List<List<int>>? findWordPath(List<String> grid, String word) {
    word = word.toUpperCase();
    List<List<int>> allPaths = [];

    for (int startPos = 0; startPos < 9; startPos++) {
      if (_normalizeChar(grid[startPos]) == _normalizeChar(word[0])) {
        _findPathDFS(grid, word, startPos, [startPos], allPaths);
      }
    }

    return allPaths.isEmpty ? null : allPaths;
  }

  void _findPathDFS(
    List<String> grid,
    String word,
    int currentPos,
    List<int> currentPath,
    List<List<int>> allPaths,
  ) {
    if (currentPath.length == word.length) {
      allPaths.add(List.from(currentPath));
      return;
    }

    int nextCharIndex = currentPath.length;
    String nextChar = _normalizeChar(word[nextCharIndex]);

    for (int neighbor in _adjacencies[currentPos]) {
      if (!currentPath.contains(neighbor) &&
          _normalizeChar(grid[neighbor]) == nextChar) {
        currentPath.add(neighbor);
        _findPathDFS(grid, word, neighbor, currentPath, allPaths);
        currentPath.removeLast();
      }
    }
  }

  String _normalizeChar(String char) {
    const accents = 'àáâãäåçèéêëìíîïñòóôõöùúûüýÿÀÁÂÃÄÅÇÈÉÊËÌÍÎÏÑÒÓÔÕÖÙÚÛÜÝŸ';
    const normalized = 'AAAAAACEEEEIIIINOOOOOOUUUUYYAAAAAACEEEEIIIINOOOOOUUUUYY';

    String upper = char.toUpperCase();
    int index = accents.indexOf(upper);
    if (index >= 0) {
      return normalized[index];
    }
    return upper;
  }

  /// Trouve tous les mots possibles dans la grille
  List<String> findAllPossibleWords(List<String> grid) {
    final Set<String> foundWords = {};

    // Pour chaque position de départ
    for (int startPos = 0; startPos < 9; startPos++) {
      _findAllWordsDFS(grid, startPos, [startPos], '', foundWords);
    }

    // Trier par longueur décroissante puis alphabétiquement
    final sortedWords = foundWords.toList()
      ..sort((a, b) {
        final lengthCompare = b.length.compareTo(a.length);
        if (lengthCompare != 0) return lengthCompare;
        return a.compareTo(b);
      });

    return sortedWords;
  }

  void _findAllWordsDFS(
    List<String> grid,
    int currentPos,
    List<int> currentPath,
    String currentWord,
    Set<String> foundWords,
  ) {
    // Construire le mot actuel
    final word = currentWord + grid[currentPos];

    // Si le mot a au moins 3 lettres et est valide, l'ajouter
    if (word.length >= GameConstants.minWordLength && isValidWord(word)) {
      foundWords.add(word);
    }

    // Limiter la profondeur à 9 (taille de la grille)
    if (currentPath.length >= 9) return;

    // Explorer les voisins
    for (int neighbor in _adjacencies[currentPos]) {
      if (!currentPath.contains(neighbor)) {
        currentPath.add(neighbor);
        _findAllWordsDFS(grid, neighbor, currentPath, word, foundWords);
        currentPath.removeLast();
      }
    }
  }

  ValidationResult validateWord(List<String> grid, String word, List<String> alreadyFound) {
    word = word.toUpperCase();

    if (word.length < GameConstants.minWordLength) {
      return ValidationResult(
        isValid: false,
        error: 'Le mot doit contenir au moins ${GameConstants.minWordLength} lettres',
      );
    }

    if (alreadyFound.contains(word)) {
      return ValidationResult(
        isValid: false,
        error: 'Mot déjà trouvé',
      );
    }

    final paths = findWordPath(grid, word);
    if (paths == null || paths.isEmpty) {
      return ValidationResult(
        isValid: false,
        error: 'Impossible de former ce mot sur la grille',
      );
    }

    if (!isValidWord(word)) {
      return ValidationResult(
        isValid: false,
        error: 'Mot non reconnu dans le dictionnaire',
      );
    }

    return ValidationResult(
      isValid: true,
      path: paths.first,
      points: GameConstants.getPoints(word.length),
    );
  }
}

class ValidationResult {
  final bool isValid;
  final String? error;
  final List<int>? path;
  final int points;

  ValidationResult({
    required this.isValid,
    this.error,
    this.path,
    this.points = 0,
  });
}
