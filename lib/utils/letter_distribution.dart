import 'dart:math';

class LetterDistribution {
  /// Les 16 dés officiels du Boggle français (6 faces par dé)
  static const List<List<String>> boggleDice = [
    ['E', 'T', 'U', 'K', 'N', 'O'],
    ['E', 'V', 'G', 'T', 'I', 'N'],
    ['D', 'E', 'C', 'A', 'M', 'P'],
    ['I', 'E', 'L', 'R', 'U', 'W'],
    ['E', 'H', 'I', 'F', 'S', 'E'],
    ['R', 'E', 'C', 'A', 'L', 'S'],
    ['E', 'N', 'T', 'D', 'O', 'S'],
    ['O', 'F', 'X', 'R', 'I', 'A'],
    ['N', 'A', 'V', 'E', 'D', 'Z'],
    ['E', 'I', 'O', 'A', 'T', 'A'],
    ['G', 'L', 'E', 'N', 'Y', 'U'],
    ['B', 'M', 'A', 'Q', 'J', 'O'],
    ['T', 'L', 'I', 'B', 'R', 'A'],
    ['S', 'P', 'U', 'L', 'T', 'E'],
    ['A', 'I', 'M', 'S', 'O', 'R'],
    ['E', 'N', 'H', 'R', 'I', 'S'],
  ];

  /// Génère une grille en mélangeant les 16 dés et en lançant chacun
  static List<String> generateGrid(int size) {
    final random = Random();
    final int totalCells = size * size;

    // Copier et mélanger les dés
    final List<List<String>> shuffledDice = List.from(boggleDice);
    shuffledDice.shuffle(random);

    final List<String> grid = [];

    for (int i = 0; i < totalCells; i++) {
      // Utiliser le dé correspondant (modulo pour les grilles plus grandes)
      final die = shuffledDice[i % shuffledDice.length];
      // Lancer le dé (choisir une face au hasard)
      final face = die[random.nextInt(die.length)];
      grid.add(face);
    }

    return grid;
  }
}
