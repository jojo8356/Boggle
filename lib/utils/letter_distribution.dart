import 'dart:math';

class LetterDistribution {
  static const Map<String, int> frenchLetterWeights = {
    'E': 15, 'A': 9, 'I': 8, 'S': 8, 'N': 7, 'R': 7, 'T': 7, 'O': 6,
    'L': 6, 'U': 6, 'D': 4, 'C': 3, 'M': 3, 'P': 3, 'G': 2, 'B': 2,
    'V': 2, 'H': 2, 'F': 2, 'Q': 1, 'Y': 1, 'X': 1, 'J': 1, 'K': 1,
    'W': 1, 'Z': 1,
  };

  static final List<String> _weightedLetters = _buildWeightedList();

  static List<String> _buildWeightedList() {
    final List<String> letters = [];
    frenchLetterWeights.forEach((letter, weight) {
      for (int i = 0; i < weight; i++) {
        letters.add(letter);
      }
    });
    return letters;
  }

  static List<String> generateGrid(int size) {
    final random = Random();
    final List<String> grid = [];

    for (int i = 0; i < size * size; i++) {
      grid.add(_weightedLetters[random.nextInt(_weightedLetters.length)]);
    }

    // Assurer au moins une voyelle
    final vowels = ['A', 'E', 'I', 'O', 'U'];
    bool hasVowel = grid.any((letter) => vowels.contains(letter));

    if (!hasVowel) {
      final randomIndex = random.nextInt(grid.length);
      grid[randomIndex] = vowels[random.nextInt(vowels.length)];
    }

    return grid;
  }
}
