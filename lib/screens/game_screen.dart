import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_provider.dart';
import '../widgets/boggle_grid.dart';
import '../widgets/timer_widget.dart';
import '../widgets/word_list.dart';
import '../widgets/score_display.dart';
import '../models/word.dart';
import '../utils/constants.dart';
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
    Future.delayed(const Duration(milliseconds: 1500), () {
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
      body: SafeArea(
        child: Consumer<GameProvider>(
          builder: (context, gameProvider, child) {
            final game = gameProvider.game;
            if (game == null) {
              return const Center(child: Text('Erreur: Partie non trouvée'));
            }

            final currentPlayer = gameProvider.currentPlayer;
            final playerWords = currentPlayer?.foundWords
                    .map((w) => Word(
                          text: w,
                          playerId: currentPlayer.id,
                          path: [],
                        ))
                    .toList() ??
                [];

            if (isWideScreen) {
              // Layout horizontal pour desktop/tablette
              return _buildWideLayout(game, gameProvider, currentPlayer, playerWords);
            } else {
              // Layout vertical pour mobile
              return _buildNarrowLayout(game, gameProvider, currentPlayer, playerWords);
            }
          },
        ),
      ),
    );
  }

  Widget _buildWideLayout(game, GameProvider gameProvider, currentPlayer, List<Word> playerWords) {
    return Row(
      children: [
        // Panneau gauche: grille et input
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Bouton arrêter (mode test uniquement)
                  if (kDebugMode && gameProvider.isTestMode)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ElevatedButton.icon(
                        onPressed: () => gameProvider.stopTestGame(),
                        icon: const Icon(Icons.stop),
                        label: const Text('Arrêter la partie'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  // Timer
                  TimerWidget(
                    remainingSeconds: game.remainingSeconds,
                    isRunning: game.state == GameState.playing,
                  ),
                  const SizedBox(height: 12),
                  // Score
                  ScoreDisplay(
                    currentScore: gameProvider.getCurrentScore(),
                    totalScore: currentPlayer?.score ?? 0,
                    wordCount: playerWords.length,
                  ),
                  const SizedBox(height: 16),
                  // Grille avec taille contrainte + espace pour boutons
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 350, maxHeight: 450),
                    child: BoggleGrid(
                      letters: game.grid,
                      highlightedPath: _highlightedPath,
                      isHighlightValid: _isHighlightValid,
                      onPathSelected: (path) {
                        final word = path.map((i) => game.grid[i]).join();
                        _handleWordSubmit(word, path: path);
                      },
                    ),
                  ),
                  // Feedback message (espace toujours réservé)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Opacity(
                      opacity: _feedbackMessage != null ? 1.0 : 0.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _isError ? Colors.red[100] : Colors.green[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _feedbackMessage ?? ' ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _isError ? Colors.red[700] : Colors.green[700],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Panneau droit: liste des mots
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vos mots (${playerWords.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    child: WordList(
                      words: playerWords,
                      showDuplicates: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(game, GameProvider gameProvider, currentPlayer, List<Word> playerWords) {
    return Column(
      children: [
        // Bouton arrêter (mode test uniquement)
        if (kDebugMode && gameProvider.isTestMode)
          ElevatedButton.icon(
            onPressed: () => gameProvider.stopTestGame(),
            icon: const Icon(Icons.stop, size: 16),
            label: const Text('Stop', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: const Size(0, 30),
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
            child: BoggleGrid(
              letters: game.grid,
              highlightedPath: _highlightedPath,
              isHighlightValid: _isHighlightValid,
              onPathSelected: (path) {
                final word = path.map((i) => game.grid[i]).join();
                _handleWordSubmit(word, path: path);
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

        // Liste des mots très compacte
        if (playerWords.isNotEmpty)
          Container(
            height: 28,
            margin: const EdgeInsets.fromLTRB(8, 0, 8, 2),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: playerWords.map((word) => Container(
                  margin: const EdgeInsets.only(right: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    word.text,
                    style: TextStyle(fontSize: 10, color: Colors.green[800], fontWeight: FontWeight.w500),
                  ),
                )).toList(),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _gameProvider?.removeListener(_onGameStateChange);
    super.dispose();
  }
}

