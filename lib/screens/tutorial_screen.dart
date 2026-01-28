import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';

class TutorialScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const TutorialScreen({super.key, this.onComplete});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _highlightAnimation;

  final List<TutorialStep> _steps = [
    TutorialStep(
      title: 'Bienvenue dans Froggle !',
      description: 'Le jeu de mots qui fait travailler vos neurones.\n\nTrouvez un maximum de mots dans la grille de 16 lettres.',
      icon: Icons.waving_hand,
      color: Colors.purple,
    ),
    TutorialStep(
      title: 'Glissez pour former des mots',
      description: 'Faites glisser votre doigt sur les lettres adjacentes pour former un mot.\n\nLes lettres doivent se toucher (horizontalement, verticalement ou en diagonale).',
      icon: Icons.swipe,
      color: Colors.blue,
      showGridDemo: true,
    ),
    TutorialStep(
      title: 'Validez vos mots',
      description: 'Appuyez sur le bouton vert pour valider votre mot.\n\nLe mot doit faire au moins 3 lettres et exister dans le dictionnaire.',
      icon: Icons.check_circle,
      color: Colors.green,
    ),
    TutorialStep(
      title: 'Marquez des points !',
      description: '3-4 lettres = 1 point\n5 lettres = 2 points\n6 lettres = 3 points\n7 lettres = 5 points\n8+ lettres = 11 points\n\nVous avez 3 minutes pour trouver un maximum de mots !',
      icon: Icons.star,
      color: Colors.amber,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _highlightAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.repeat(reverse: true);
  }

  void _nextPage() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeTutorial();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeTutorial() {
    final settings = Provider.of<SettingsService>(context, listen: false);
    settings.setTutorialSeen();

    if (widget.onComplete != null) {
      widget.onComplete!();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _skipTutorial() {
    _completeTutorial();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
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
              _steps[_currentPage].color.withValues(alpha: 0.8),
              _steps[_currentPage].color.withValues(alpha: 0.4),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Bouton passer en haut à droite
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skipTutorial,
                  child: const Text(
                    'Passer',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              // Contenu du tutoriel
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _steps.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_steps[index]);
                  },
                ),
              ),
              // Indicateurs de page
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _steps.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Boutons navigation
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Bouton précédent
                    _currentPage > 0
                        ? TextButton.icon(
                            onPressed: _previousPage,
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            label: const Text(
                              'Précédent',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : const SizedBox(width: 100),
                    // Bouton suivant/commencer
                    ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: _steps[_currentPage].color,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        _currentPage == _steps.length - 1 ? 'Commencer !' : 'Suivant',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(TutorialStep step) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icone
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      step.icon,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Titre
                  Text(
                    step.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // Description
                  Text(
                    step.description,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // Demo de grille optionnelle
                  if (step.showGridDemo) ...[
                    const SizedBox(height: 32),
                    _buildGridDemo(),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridDemo() {
    // Mini grille de demonstration avec animation
    return AnimatedBuilder(
      animation: _highlightAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mini grille 3x3
              SizedBox(
                width: 150,
                height: 150,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    const letters = ['M', 'O', 'T', 'A', 'B', 'C', 'D', 'E', 'F'];
                    final isHighlighted = index < 3; // Highlight M-O-T
                    final animatedBorderWidth = isHighlighted
                        ? 2.0 + (_highlightAnimation.value * 2.0)
                        : 2.0;
                    final animatedColor = isHighlighted
                        ? Color.lerp(
                            Colors.blue[200],
                            Colors.blue[400],
                            _highlightAnimation.value,
                          )
                        : Colors.amber[100];

                    return Container(
                      decoration: BoxDecoration(
                        color: animatedColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isHighlighted
                              ? Colors.blue[700]!
                              : Colors.brown[400]!,
                          width: animatedBorderWidth,
                        ),
                        boxShadow: isHighlighted
                            ? [
                                BoxShadow(
                                  color: Colors.blue.withValues(
                                    alpha: 0.3 * _highlightAnimation.value,
                                  ),
                                  blurRadius: 8 * _highlightAnimation.value,
                                  spreadRadius: 2 * _highlightAnimation.value,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          letters[index],
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown[900],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Exemple: MOT',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TutorialStep {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool showGridDemo;

  TutorialStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.showGridDemo = false,
  });
}
