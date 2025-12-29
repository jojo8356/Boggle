import 'package:flutter/material.dart';

class ScoreDisplay extends StatelessWidget {
  final int currentScore;
  final int totalScore;
  final int wordCount;

  const ScoreDisplay({
    super.key,
    required this.currentScore,
    required this.totalScore,
    required this.wordCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[400]!, Colors.purple[600]!],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$wordCount',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Text(
            ' mots | ',
            style: TextStyle(fontSize: 12, color: Colors.white70),
          ),
          Text(
            '+$currentScore',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Text(
            ' pts',
            style: TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
