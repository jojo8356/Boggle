import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/word.dart';
import '../services/game_provider.dart';
import '../services/settings_service.dart';
import '../utils/constants.dart';
import '../widgets/boggle_grid.dart';
import '../widgets/score_display.dart';
import '../widgets/timer_widget.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/word_chip.dart';
import 'results_screen.dart';
import 'game_end_transition.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<int> _highlightedPath = [];
  bool _isHighlightValid = true;
  GameProvider? _gameProvider;
  String? _feedbackMessage;
  bool _isError = false;
  bool _showZoomSlider = false;

  @override
  void initState() {
    super.initState();
    _checkGameEnd();
  }

  void _checkGameEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _gameProvider = context.read<GameProvider>();
      _gameProvider?.addListener(_onGameStateChange);
    });
  }

  void _onGameStateChange() {
    if (_gameProvider?.game?.state == GameState.finished) {
      _gameProvider?.removeListener(_onGameStateChange);
      final currentPlayer = _gameProvider?.currentPlayer;
      final wordsFound = currentPlayer?.foundWords.length ?? 0;
      final totalScore = currentPlayer?.score ?? 0;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GameEndTransition(
            wordsFound: wordsFound,
            totalScore: totalScore,
            onComplete: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ResultsScreen()),
              );
            },
          ),
        ),
      );
    }
  }

  void _showQuickHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: AppColors.purple),
            SizedBox(width: 8),
            Text('Comment jouer'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HelpItem(
              icon: Icons.swipe,
              text: 'Glissez sur les lettres adjacentes',
            ),
            SizedBox(height: 12),
            _HelpItem(
              icon: Icons.check_circle,
              text: 'Appuyez sur le bouton vert pour valider',
            ),
            SizedBox(height: 12),
            _HelpItem(
              icon: Icons.close,
              text: 'Bouton rouge pour annuler',
            ),
            SizedBox(height: 12),
            _HelpItem(
              icon: Icons.text_fields,
              text: 'Minimum 3 lettres par mot',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris !'),
          ),
        ],
      ),
    );
  }

  void _handleWordSubmit(String word, {List<int>? path}) {
    final gameProvider = context.read<GameProvider>();
    final result = gameProvider.submitWord(word, path: path);

    if (result.isValid) {
      setState(() {
        _highlightedPath = result.path ?? [];
        _isHighlightValid = true;
        _feedbackMessage = '+${result.points} points!';
        _isError = false;
      });
    } else {
      setState(() {
        _highlightedPath = [];
        _isHighlightValid = false;
        _feedbackMessage = result.error ?? 'Mot invalide';
        _isError = true;
      });
    }

    // Effacer le highlight et le feedback après un moment
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _highlightedPath = [];
          _feedbackMessage = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _buildFloatingButtons(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      body: SafeArea(
        child: Consumer<GameProvider>(
          builder: (context, gameProvider, child) {
            final game = gameProvider.game;
            if (game == null) {
              return const Center(child: Text('Erreur: Partie non trouvée'));
            }

            final currentPlayer = gameProvider.currentPlayer;
            final playerWords =
                currentPlayer?.foundWords
                    .map(
                      (w) =>
                          Word(text: w, playerId: currentPlayer.id, path: []),
                    )
                    .toList() ??
                [];

            return _buildNarrowLayout(
              game,
              gameProvider,
              currentPlayer,
              playerWords,
            );
          },
        ),
      ),
    );
  }

  Widget _buildNarrowLayout(
    game,
    GameProvider gameProvider,
    currentPlayer,
    List<Word> playerWords,
  ) {
    return Column(
      children: [
        // Bouton terminer (mode debug uniquement - fonctionne en solo et multi)
        if (kDebugMode)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ElevatedButton.icon(
              onPressed: () => gameProvider.forceEndGame(),
              icon: const Icon(Icons.stop, size: 20),
              label: const Text('Terminer', style: TextStyle(fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: const Size(0, 44),
              ),
            ),
          ),
        // Timer et Score sur la même ligne
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: TimerWidget(
                  remainingSeconds: game.remainingSeconds,
                  isRunning: game.state == GameState.playing,
                ),
              ),
              const SizedBox(width: 8),
              ScoreDisplay(
                currentScore: gameProvider.getCurrentScore(),
                totalScore: currentPlayer?.score ?? 0,
                wordCount: playerWords.length,
              ),
            ],
          ),
        ),

        // Grille Boggle - prend le maximum de place possible
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Consumer<SettingsService>(
              builder: (context, settings, child) {
                return BoggleGrid(
                  letters: game.grid,
                  highlightedPath: _highlightedPath,
                  isHighlightValid: _isHighlightValid,
                  initialZoom: settings.gridZoom,
                  onPathSelected: (path) {
                    final word = path.map((i) => game.grid[i]).join();
                    _handleWordSubmit(word, path: path);
                  },
                );
              },
            ),
          ),
        ),

        // Feedback message (espace toujours réservé)
        Opacity(
          opacity: _feedbackMessage != null ? 1.0 : 0.0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: AppDecorations.feedbackContainer(isError: _isError),
            child: Text(
              _feedbackMessage ?? ' ',
              style: AppTextStyles.feedback(isError: _isError),
            ),
          ),
        ),

        // Bandeau horizontal des mots trouvés (hauteur fixe, scroll horizontal)
        Container(
          height: 52,
          margin: const EdgeInsets.fromLTRB(8, 4, 8, 8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: AppDecorations.greyContainer(),
          child: playerWords.isEmpty
              ? Center(
                  child: Text(
                    'Vos mots apparaîtront ici',
                    style: AppTextStyles.placeholder,
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (int i = 0; i < playerWords.length; i++) ...[
                        if (i > 0) const SizedBox(width: 8),
                        WordChip(text: playerWords[i].text),
                      ],
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildFloatingButtons(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settings, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 75), // Espace pour éviter le chevauchement
            if (_showZoomSlider)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: AppDecorations.zoomSlider(),
                child: RotatedBox(
                  quarterTurns: 3,
                  child: SizedBox(
                    width: 150,
                    child: Slider(
                      value: settings.gridZoom,
                      min: SettingsService.minZoom,
                      max: SettingsService.maxZoom,
                      divisions: 10,
                      activeColor: AppColors.purple,
                      onChanged: (value) {
                        settings.setGridZoom(value);
                      },
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            // Bouton Zoom
            FloatingActionButton.small(
              heroTag: 'zoom_button',
              backgroundColor: AppColors.purple,
              onPressed: () {
                setState(() {
                  _showZoomSlider = !_showZoomSlider;
                });
              },
              child: Icon(
                _showZoomSlider ? Icons.close : Icons.zoom_in,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            // Bouton Aide
            FloatingActionButton.small(
              heroTag: 'help_button',
              backgroundColor: AppColors.purple.withValues(alpha: 0.8),
              onPressed: () => _showQuickHelp(context),
              child: const Icon(Icons.help_outline, color: Colors.white),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _gameProvider?.removeListener(_onGameStateChange);
    super.dispose();
  }
}

class _HelpItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HelpItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.purple, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
