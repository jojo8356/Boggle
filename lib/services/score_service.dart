import '../config/game_config.dart';
import '../models/word.dart';

/// Service responsable du calcul des scores.
///
/// Encapsule la logique de scoring precedemment dans GameProvider.
/// Centralise les regles de points pour faciliter les modifications
/// et les tests unitaires.
class ScoreService {
  /// Calcule le score total d'un joueur a partir de la liste de mots du jeu.
  ///
  /// [words] : tous les mots soumis pendant la partie.
  /// [playerId] : identifiant du joueur dont on calcule le score.
  ///
  /// Seuls les mots qui ne sont ni dupliques ni invalides sont comptes
  /// (via [Word.effectivePoints]).
  int calculatePlayerScore(List<Word> words, String playerId) {
    int score = 0;
    for (final word in words.where((w) => w.playerId == playerId)) {
      score += word.effectivePoints;
    }
    return score;
  }

  /// Retourne le nombre de points pour un mot d'une longueur donnee.
  ///
  /// Regles de scoring (definies dans [GameConfig]) :
  /// - 2 lettres ou moins : 0 point
  /// - 3-4 lettres : 1 point
  /// - 5 lettres : 2 points
  /// - 6 lettres : 3 points
  /// - 7 lettres : 5 points
  /// - 8+ lettres : 11 points
  int getPointsForWordLength(int wordLength) {
    return GameConfig.getPoints(wordLength);
  }

  /// Retourne le nombre de points pour un mot donne (par son texte).
  int getPointsForWord(String word) {
    return GameConfig.getPoints(word.length);
  }

  /// Calcule les scores de tous les joueurs presents dans la liste de mots.
  ///
  /// Retourne une Map associant chaque [playerId] a son score total.
  Map<String, int> calculateAllScores(List<Word> words) {
    final scores = <String, int>{};
    for (final word in words) {
      scores.update(
        word.playerId,
        (current) => current + word.effectivePoints,
        ifAbsent: () => word.effectivePoints,
      );
    }
    return scores;
  }

}
