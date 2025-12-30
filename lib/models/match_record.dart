class MatchRecord {
  final int? id;
  final int userId;
  final DateTime playedAt;
  final int score;
  final int wordsFound;
  final int validWords;
  final int rank;
  final int totalPlayers;
  final bool isWin;
  final bool isSolo;
  final int gameDuration;

  MatchRecord({
    this.id,
    required this.userId,
    required this.playedAt,
    required this.score,
    required this.wordsFound,
    required this.validWords,
    required this.rank,
    required this.totalPlayers,
    required this.isWin,
    required this.isSolo,
    required this.gameDuration,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'played_at': playedAt.toIso8601String(),
      'score': score,
      'words_found': wordsFound,
      'valid_words': validWords,
      'rank': rank,
      'total_players': totalPlayers,
      'is_win': isWin ? 1 : 0,
      'is_solo': isSolo ? 1 : 0,
      'game_duration': gameDuration,
    };
  }

  factory MatchRecord.fromMap(Map<String, dynamic> map) {
    return MatchRecord(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      playedAt: DateTime.parse(map['played_at'] as String),
      score: map['score'] as int,
      wordsFound: map['words_found'] as int,
      validWords: map['valid_words'] as int,
      rank: map['rank'] as int,
      totalPlayers: map['total_players'] as int,
      isWin: (map['is_win'] as int) == 1,
      isSolo: (map['is_solo'] as int) == 1,
      gameDuration: map['game_duration'] as int,
    );
  }
}
