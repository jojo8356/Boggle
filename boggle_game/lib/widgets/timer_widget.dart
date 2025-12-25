import 'package:flutter/material.dart';

class TimerWidget extends StatelessWidget {
  final int remainingSeconds;
  final bool isRunning;

  const TimerWidget({
    super.key,
    required this.remainingSeconds,
    this.isRunning = true,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    final isLowTime = remainingSeconds <= 30;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isLowTime ? Colors.red[100] : Colors.blue[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLowTime ? Colors.red : Colors.blue,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            color: isLowTime ? Colors.red[700] : Colors.blue[700],
            size: 28,
          ),
          const SizedBox(width: 8),
          Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isLowTime ? Colors.red[700] : Colors.blue[700],
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
