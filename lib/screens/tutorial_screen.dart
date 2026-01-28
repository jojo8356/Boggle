import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';

class TutorialScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const TutorialScreen({super.key, this.onComplete});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

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
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icône
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
          // Démo de grille optionnelle
          if (step.showGridDemo) ...[
            const SizedBox(height: 32),
            _buildGridDemo(),
          ],
        ],
      ),
    );
  }

  Widget _buildGridDemo() {
    // Mini grille de démonstration avec animation
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Mini grille 3x3
          SizedBox(
            width: 150,
            height: 150,
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              children: ['M', 'O', 'T', 'A', 'B', 'C', 'D', 'E', 'F']
                  .asMap()
                  .entries
                  .map((entry) {
                final isHighlighted = entry.key < 3; // Highlight M-O-T
                return Container(
                  decoration: BoxDecoration(
                    color: isHighlighted
                        ? Colors.blue[300]
                        : Colors.amber[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isHighlighted
                          ? Colors.blue[700]!
                          : Colors.brown[400]!,
                      width: isHighlighted ? 3 : 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown[900],
                      ),
                    ),
                  ),
                );
              }).toList(),
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
