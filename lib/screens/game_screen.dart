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
import 'results_screen.dart';

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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ResultsScreen()),
      );
    }
  }

  void _showQuickHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Colors.purple),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

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

            if (isWideScreen) {
              // Layout horizontal pour desktop/tablette
              return _buildWideLayout(
                game,
                gameProvider,
                currentPlayer,
                playerWords,
              );
            } else {
              // Layout vertical pour mobile
              return _buildNarrowLayout(
                game,
                gameProvider,
                currentPlayer,
                playerWords,
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildWideLayout(
    game,
    GameProvider gameProvider,
    currentPlayer,
    List<Word> playerWords,
  ) {
    // Utiliser le même layout que la version mobile
    return _buildNarrowLayout(game, gameProvider, currentPlayer, playerWords);
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
              icon: const Icon(Icons.stop, size: 16),
              label: const Text('Terminer', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: const Size(0, 30),
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
            decoration: BoxDecoration(
              color: _isError ? Colors.red[100] : Colors.green[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _feedbackMessage ?? ' ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _isError ? Colors.red[700] : Colors.green[700],
              ),
            ),
          ),
        ),

        // Liste des mots trouvés en bas (sans points, plus compacte)
        if (playerWords.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 70),
            margin: const EdgeInsets.fromLTRB(8, 0, 8, 4),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: playerWords
                    .map(
                      (word) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.green[300]!),
                        ),
                        child: Text(
                          word.text,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
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
            const SizedBox(height: 60), // Espace pour éviter le chevauchement
            if (_showZoomSlider)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: RotatedBox(
                  quarterTurns: 3,
                  child: SizedBox(
                    width: 150,
                    child: Slider(
                      value: settings.gridZoom,
                      min: SettingsService.minZoom,
                      max: SettingsService.maxZoom,
                      divisions: 10,
                      activeColor: Colors.purple,
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
              backgroundColor: Colors.purple,
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
              backgroundColor: Colors.purple.withValues(alpha: 0.8),
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
        Icon(icon, color: Colors.purple, size: 24),
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
