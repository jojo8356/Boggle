/// Configuration du jeu Froggle
/// Modifiez ces valeurs pour personnaliser le jeu
class GameConfig {
  /// Taille de la grille (3 = 3x3, 4 = 4x4, 5 = 5x5)
  static const int gridSize = 4;

  /// Durée d'une partie en secondes (180 = 3 minutes)
  static const int gameDurationSeconds = 180;

  /// Nombre maximum de joueurs
  static const int maxPlayers = 6;

  /// Longueur minimale d'un mot pour être valide
  static const int minWordLength = 3;

  /// Calcul des points selon la longueur du mot
  static int getPoints(int wordLength) {
    if (wordLength <= 2) return 0;
    if (wordLength <= 4) return 1;
    if (wordLength == 5) return 2;
    if (wordLength == 6) return 3;
    if (wordLength == 7) return 5;
    return 11; // 8+ lettres
  }
}
