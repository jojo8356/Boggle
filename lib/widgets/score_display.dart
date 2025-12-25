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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[400]!, Colors.purple[600]!],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ScoreItem(
            label: 'Mots',
            value: wordCount.toString(),
            icon: Icons.abc,
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.white30,
          ),
          _ScoreItem(
            label: 'Manche',
            value: '+$currentScore',
            icon: Icons.star,
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.white30,
          ),
          _ScoreItem(
            label: 'Total',
            value: totalScore.toString(),
            icon: Icons.emoji_events,
          ),
        ],
      ),
    );
  }
}

class _ScoreItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ScoreItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
