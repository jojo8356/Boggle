import '../utils/constants.dart';

class Player {
  final String id;
  final String name;
  final bool isHost;
  PlayerState state;
  int score;
  List<String> foundWords;
  bool votedForNewGame;

  Player({
    required this.id,
    required this.name,
    this.isHost = false,
    this.state = PlayerState.connected,
    this.score = 0,
    List<String>? foundWords,
    this.votedForNewGame = false,
  }) : foundWords = foundWords ?? [];

  void addWord(String word) {
    if (!foundWords.contains(word.toUpperCase())) {
      foundWords.add(word.toUpperCase());
    }
  }

  void resetForNewGame() {
    foundWords = [];
    votedForNewGame = false;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isHost': isHost,
      'state': state.index,
      'score': score,
      'foundWords': foundWords,
      'votedForNewGame': votedForNewGame,
    };
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
      isHost: json['isHost'] ?? false,
      state: PlayerState.values[json['state'] ?? 0],
      score: json['score'] ?? 0,
      foundWords: List<String>.from(json['foundWords'] ?? []),
      votedForNewGame: json['votedForNewGame'] ?? false,
    );
  }
}
