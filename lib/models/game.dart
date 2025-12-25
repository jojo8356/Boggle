import '../utils/constants.dart';
import '../utils/letter_distribution.dart';
import 'player.dart';
import 'word.dart';

class Game {
  final String id;
  List<String> grid;
  List<Player> players;
  GameState state;
  int remainingSeconds;
  List<Word> allWords;
  int roundNumber;

  Game({
    required this.id,
    List<String>? grid,
    List<Player>? players,
    this.state = GameState.waiting,
    this.remainingSeconds = GameConstants.gameDurationSeconds,
    List<Word>? allWords,
    this.roundNumber = 1,
  })  : grid = grid ?? LetterDistribution.generateGrid(GameConstants.gridSize),
        players = players ?? [],
        allWords = allWords ?? [];

  void addPlayer(Player player) {
    if (players.length < GameConstants.maxPlayers) {
      players.add(player);
    }
  }

  void removePlayer(String playerId) {
    players.removeWhere((p) => p.id == playerId);
  }

  Player? getPlayer(String playerId) {
    try {
      return players.firstWhere((p) => p.id == playerId);
    } catch (e) {
      return null;
    }
  }

  void startGame() {
    state = GameState.playing;
    remainingSeconds = GameConstants.gameDurationSeconds;
    allWords = [];
    for (var player in players) {
      player.foundWords = [];
      player.state = PlayerState.playing;
    }
  }

  void endGame() {
    state = GameState.finished;
    _processDuplicates();
    _calculateScores();
  }

  void _processDuplicates() {
    final wordCounts = <String, int>{};
    for (var word in allWords) {
      wordCounts[word.text] = (wordCounts[word.text] ?? 0) + 1;
    }

    for (var word in allWords) {
      if ((wordCounts[word.text] ?? 0) > 1) {
        word.isDuplicate = true;
      }
    }
  }

  void _calculateScores() {
    for (var player in players) {
      int score = 0;
      for (var word in allWords.where((w) => w.playerId == player.id)) {
        score += word.effectivePoints;
      }
      player.score += score;
    }
  }

  List<Word> getPlayerWords(String playerId) {
    return allWords.where((w) => w.playerId == playerId).toList();
  }

  void resetForNewGame() {
    grid = LetterDistribution.generateGrid(GameConstants.gridSize);
    state = GameState.waiting;
    remainingSeconds = GameConstants.gameDurationSeconds;
    allWords = [];
    roundNumber++;
    for (var player in players) {
      player.resetForNewGame();
    }
  }

  bool allPlayersVotedForNewGame() {
    return players.every((p) => p.votedForNewGame);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'grid': grid,
      'players': players.map((p) => p.toJson()).toList(),
      'state': state.index,
      'remainingSeconds': remainingSeconds,
      'allWords': allWords.map((w) => w.toJson()).toList(),
      'roundNumber': roundNumber,
    };
  }

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'],
      grid: List<String>.from(json['grid']),
      players:
          (json['players'] as List).map((p) => Player.fromJson(p)).toList(),
      state: GameState.values[json['state'] ?? 0],
      remainingSeconds: json['remainingSeconds'] ?? GameConstants.gameDurationSeconds,
      allWords: (json['allWords'] as List?)?.map((w) => Word.fromJson(w)).toList() ?? [],
      roundNumber: json['roundNumber'] ?? 1,
    );
  }
}
