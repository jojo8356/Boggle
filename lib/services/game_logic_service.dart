import 'dart:math';
import '../utils/constants.dart';
import 'dictionary_service.dart';

class GameLogicService {
  final DictionaryService _dictionaryService = DictionaryService();

  /// Calcule la taille de la grille à partir du nombre de cellules
  int _getGridSize(List<String> grid) => sqrt(grid.length).round();

  /// Calcule les voisins d'une position pour une grille de taille donnée
  List<int> getNeighbors(int pos, int gridSize) {
    final int row = pos ~/ gridSize;
    final int col = pos % gridSize;
    final List<int> neighbors = [];

    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        final int newRow = row + dr;
        final int newCol = col + dc;
        if (newRow >= 0 && newRow < gridSize && newCol >= 0 && newCol < gridSize) {
          neighbors.add(newRow * gridSize + newCol);
        }
      }
    }
    return neighbors;
  }

  bool areAdjacent(int pos1, int pos2, int gridSize) {
    final int totalCells = gridSize * gridSize;
    if (pos1 < 0 || pos1 >= totalCells || pos2 < 0 || pos2 >= totalCells) return false;
    return getNeighbors(pos1, gridSize).contains(pos2);
  }

  bool isValidPath(List<int> path, int gridSize) {
    if (path.isEmpty) return false;
    if (path.length != path.toSet().length) return false; // pas de répétition

    for (int i = 0; i < path.length - 1; i++) {
      if (!areAdjacent(path[i], path[i + 1], gridSize)) {
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
    final int gridSize = _getGridSize(grid);

    for (int startPos = 0; startPos < grid.length; startPos++) {
      if (_normalizeChar(grid[startPos]) == _normalizeChar(word[0])) {
        _findPathDFS(grid, word, startPos, [startPos], allPaths, gridSize);
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
    int gridSize,
  ) {
    if (currentPath.length == word.length) {
      allPaths.add(List.from(currentPath));
      return;
    }

    int nextCharIndex = currentPath.length;
    String nextChar = _normalizeChar(word[nextCharIndex]);

    for (int neighbor in getNeighbors(currentPos, gridSize)) {
      if (!currentPath.contains(neighbor) &&
          _normalizeChar(grid[neighbor]) == nextChar) {
        currentPath.add(neighbor);
        _findPathDFS(grid, word, neighbor, currentPath, allPaths, gridSize);
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

  /// Trouve tous les mots possibles dans la grille (optimisé avec Trie)
  List<String> findAllPossibleWords(List<String> grid) {
    final Set<String> foundWords = {};
    final int gridSize = _getGridSize(grid);

    // Pour chaque position de départ
    for (int startPos = 0; startPos < grid.length; startPos++) {
      _findAllWordsDFS(grid, startPos, [startPos], '', foundWords, gridSize);
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
    int gridSize,
  ) {
    // Construire le mot actuel
    final word = currentWord + grid[currentPos];

    // Vérifier le préfixe avec le Trie (élagage)
    final (hasPrefix, isWord) = _dictionaryService.checkPrefix(word);

    // Si ce préfixe n'existe pas, on arrête cette branche
    if (!hasPrefix) return;

    // Si c'est un mot valide (>= 3 lettres), l'ajouter
    if (isWord) {
      foundWords.add(word);
    }

    // Limiter la profondeur à la taille de la grille
    if (currentPath.length >= grid.length) return;

    // Explorer les voisins
    for (int neighbor in getNeighbors(currentPos, gridSize)) {
      if (!currentPath.contains(neighbor)) {
        currentPath.add(neighbor);
        _findAllWordsDFS(grid, neighbor, currentPath, word, foundWords, gridSize);
        currentPath.removeLast();
      }
    }
  }

  /// Valide un mot
  /// [skipDictionaryCheck] - Si true, ne vérifie pas le dictionnaire (pour le multijoueur)
  ValidationResult validateWord(List<String> grid, String word, List<String> alreadyFound, {List<int>? providedPath, bool skipDictionaryCheck = false}) {
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

    // Si un chemin est fourni, vérifier qu'il est valide
    List<int>? validPath;
    if (providedPath != null && providedPath.isNotEmpty) {
      final gridSize = _getGridSize(grid);
      // Vérifier que le chemin est valide et correspond au mot
      if (isValidPath(providedPath, gridSize)) {
        final wordFromPath = getWordFromPath(grid, providedPath);
        if (wordFromPath.toUpperCase() == word) {
          validPath = providedPath;
        }
      }
    }

    // Si pas de chemin fourni ou invalide, en chercher un
    if (validPath == null) {
      final paths = findWordPath(grid, word);
      if (paths == null || paths.isEmpty) {
        return ValidationResult(
          isValid: false,
          error: 'Impossible de former ce mot sur la grille',
        );
      }
      validPath = paths.first;
    }

    // En mode multijoueur, on ne vérifie pas le dictionnaire maintenant
    if (!skipDictionaryCheck && !isValidWord(word)) {
      return ValidationResult(
        isValid: false,
        error: 'Mot non reconnu dans le dictionnaire',
      );
    }

    return ValidationResult(
      isValid: true,
      path: validPath,
      points: GameConstants.getPoints(word.length),
      isInDictionary: skipDictionaryCheck ? null : true,
    );
  }
}

class ValidationResult {
  final bool isValid;
  final String? error;
  final List<int>? path;
  final int points;
  final bool? isInDictionary;

  ValidationResult({
    required this.isValid,
    this.error,
    this.path,
    this.points = 0,
    this.isInDictionary,
  });
}
