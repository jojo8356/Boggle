import '../utils/constants.dart';

class Word {
  final String text;
  final String playerId;
  final List<int> path;
  final int points;
  bool isDuplicate;

  Word({
    required this.text,
    required this.playerId,
    required this.path,
    this.isDuplicate = false,
  }) : points = GameConstants.getPoints(text.length);

  int get effectivePoints => isDuplicate ? 0 : points;

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'playerId': playerId,
      'path': path,
      'isDuplicate': isDuplicate,
    };
  }

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      text: json['text'],
      playerId: json['playerId'],
      path: List<int>.from(json['path'] ?? []),
      isDuplicate: json['isDuplicate'] ?? false,
    );
  }
}
