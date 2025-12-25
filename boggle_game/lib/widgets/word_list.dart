import 'package:flutter/material.dart';
import '../models/word.dart';

class WordList extends StatelessWidget {
  final List<Word> words;
  final bool showDuplicates;

  const WordList({
    super.key,
    required this.words,
    this.showDuplicates = false,
  });

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text(
          'Aucun mot trouvé',
          style: TextStyle(
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: words.length,
      itemBuilder: (context, index) {
        final word = words[index];
        return _WordTile(word: word, showDuplicate: showDuplicates);
      },
    );
  }
}

class _WordTile extends StatelessWidget {
  final Word word;
  final bool showDuplicate;

  const _WordTile({
    required this.word,
    required this.showDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    final isDuplicate = showDuplicate && word.isDuplicate;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDuplicate ? Colors.grey[200] : Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDuplicate ? Colors.grey : Colors.green[300]!,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            word.text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              decoration: isDuplicate ? TextDecoration.lineThrough : null,
              color: isDuplicate ? Colors.grey : Colors.black87,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isDuplicate ? Colors.grey : Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+${isDuplicate ? 0 : word.points}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SimpleWordList extends StatelessWidget {
  final List<String> words;

  const SimpleWordList({
    super.key,
    required this.words,
  });

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return const Text(
        'Aucun mot trouvé',
        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: words.map((word) {
        return Chip(
          label: Text(
            word,
            style: const TextStyle(fontSize: 12),
          ),
          backgroundColor: Colors.green[100],
          padding: const EdgeInsets.symmetric(horizontal: 4),
          visualDensity: VisualDensity.compact,
          side: BorderSide(color: Colors.green[300]!),
        );
      }).toList(),
    );
  }
}
