import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GameEndTransition extends StatefulWidget {
  final int wordsFound;
  final int totalScore;
  final VoidCallback onComplete;

  const GameEndTransition({
    super.key,
    required this.wordsFound,
    required this.totalScore,
    required this.onComplete,
  });

  @override
  State<GameEndTransition> createState() => _GameEndTransitionState();
}

class _GameEndTransitionState extends State<GameEndTransition>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Vibration de feedback
    HapticFeedback.heavyImpact();

    // Animation de scale pour "TEMPS ECOULÉ"
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Animation de fade pour les infos
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    // Démarrer les animations
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _fadeController.forward();
      }
    });

    // Naviguer vers les résultats après 2.5 secondes
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange[400]!,
              Colors.red[400]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icône de sablier animée
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.hourglass_empty,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Texte "TEMPS ÉCOULÉ !"
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: const Text(
                    'TEMPS ÉCOULÉ !',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 4,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                // Résumé rapide
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit, color: Colors.purple[700], size: 28),
                            const SizedBox(width: 8),
                            Text(
                              '${widget.wordsFound} mots trouvés',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.star, color: Colors.amber[700], size: 28),
                            const SizedBox(width: 8),
                            Text(
                              '${widget.totalScore} points',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Indicateur de chargement
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    'Préparation des résultats...',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
