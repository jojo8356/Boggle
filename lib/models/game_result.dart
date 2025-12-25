import 'word.dart';

class PlayerResult {
  final String playerId;
  final String playerName;
  final List<Word> words;
  final int roundScore;
  final int totalScore;

  PlayerResult({
    required this.playerId,
    required this.playerName,
    required this.words,
    required this.roundScore,
    required this.totalScore,
  });

  List<Word> get validWords => words.where((w) => !w.isDuplicate).toList();
  List<Word> get duplicateWords => words.where((w) => w.isDuplicate).toList();
}

class GameResult {
  final List<PlayerResult> playerResults;
  final int roundNumber;

  GameResult({
    required this.playerResults,
    required this.roundNumber,
  });

  PlayerResult? getWinner() {
    if (playerResults.isEmpty) return null;
    return playerResults.reduce((a, b) => a.roundScore > b.roundScore ? a : b);
  }

  List<PlayerResult> getRanking() {
    final sorted = List<PlayerResult>.from(playerResults);
    sorted.sort((a, b) => b.totalScore.compareTo(a.totalScore));
    return sorted;
  }
}
