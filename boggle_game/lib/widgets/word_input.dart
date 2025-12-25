import 'package:flutter/material.dart';

class WordInput extends StatefulWidget {
  final Function(String) onWordSubmitted;
  final bool enabled;

  const WordInput({
    super.key,
    required this.onWordSubmitted,
    this.enabled = true,
  });

  @override
  State<WordInput> createState() => _WordInputState();
}

class _WordInputState extends State<WordInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _feedbackMessage;
  bool _isError = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitWord() {
    final word = _controller.text.trim().toUpperCase();
    if (word.isNotEmpty) {
      widget.onWordSubmitted(word);
      _controller.clear();
    }
  }

  void showFeedback(String message, bool isError) {
    setState(() {
      _feedbackMessage = message;
      _isError = isError;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _feedbackMessage = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: widget.enabled,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'Entrez un mot...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onSubmitted: (_) => _submitWord(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: widget.enabled ? _submitWord : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Icon(Icons.send),
            ),
          ],
        ),
        if (_feedbackMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _isError ? Colors.red[100] : Colors.green[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isError ? Icons.error : Icons.check_circle,
                    color: _isError ? Colors.red : Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _feedbackMessage!,
                    style: TextStyle(
                      color: _isError ? Colors.red[700] : Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
