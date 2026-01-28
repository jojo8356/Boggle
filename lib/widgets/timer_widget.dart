import 'package:flutter/material.dart';

class TimerWidget extends StatefulWidget {
  final int remainingSeconds;
  final bool isRunning;

  const TimerWidget({
    super.key,
    required this.remainingSeconds,
    this.isRunning = true,
  });

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(TimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Démarrer la pulsation quand < 10 secondes
    if (widget.remainingSeconds <= 10 && widget.remainingSeconds > 0) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = widget.remainingSeconds ~/ 60;
    final seconds = widget.remainingSeconds % 60;
    final isLowTime = widget.remainingSeconds <= 30;
    final isCriticalTime = widget.remainingSeconds <= 10;

    Color bgColor;
    Color borderColor;
    Color textColor;

    if (isCriticalTime && widget.remainingSeconds > 0) {
      bgColor = Colors.red[200]!;
      borderColor = Colors.red[700]!;
      textColor = Colors.red[900]!;
    } else if (isLowTime) {
      bgColor = Colors.red[100]!;
      borderColor = Colors.red;
      textColor = Colors.red[700]!;
    } else {
      bgColor = Colors.blue[100]!;
      borderColor = Colors.blue;
      textColor = Colors.blue[700]!;
    }

    Widget timerContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: isCriticalTime ? 3 : 2,
        ),
        boxShadow: isCriticalTime
            ? [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            color: textColor,
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: isCriticalTime ? 22 : 20,
              fontWeight: FontWeight.bold,
              color: textColor,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );

    // Appliquer l'animation de pulsation si temps critique
    if (isCriticalTime && widget.remainingSeconds > 0) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: child,
          );
        },
        child: timerContent,
      );
    }

    return timerContent;
  }
}
