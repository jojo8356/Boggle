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
  final GlobalKey<_WordInputWithFeedbackState> _wordInputKey = GlobalKey();
  List<int> _highlightedPath = [];
  bool _isHighlightValid = true;
  GameProvider? _gameProvider;

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

  void _handleWordSubmit(String word) {
    final gameProvider = context.read<GameProvider>();
    final result = gameProvider.submitWord(word);

    if (result.isValid) {
      setState(() {
        _highlightedPath = result.path ?? [];
        _isHighlightValid = true;
      });
      _wordInputKey.currentState?.showFeedback(
        '+${result.points} points!',
        false,
      );
    } else {
      setState(() {
        _highlightedPath = [];
        _isHighlightValid = false;
      });
      _wordInputKey.currentState?.showFeedback(
        result.error ?? 'Mot invalide',
        true,
      );
    }

    // Effacer le highlight après un moment
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _highlightedPath = [];
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
                  // Grille avec taille contrainte
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 350, maxHeight: 350),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: BoggleGrid(
                        letters: game.grid,
                        highlightedPath: _highlightedPath,
                        isHighlightValid: _isHighlightValid,
                        onPathSelected: (path) {
                          final word = path.map((i) => game.grid[i]).join();
                          _handleWordSubmit(word);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Input
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 350),
                      child: _WordInputWithFeedback(
                        key: _wordInputKey,
                        onWordSubmitted: _handleWordSubmit,
                        enabled: game.state == GameState.playing,
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
          Padding(
            padding: const EdgeInsets.only(top: 8),
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
        // Timer en haut
        Container(
          padding: const EdgeInsets.all(16),
          child: TimerWidget(
            remainingSeconds: game.remainingSeconds,
            isRunning: game.state == GameState.playing,
          ),
        ),

        // Score display
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ScoreDisplay(
            currentScore: gameProvider.getCurrentScore(),
            totalScore: currentPlayer?.score ?? 0,
            wordCount: playerWords.length,
          ),
        ),

        const SizedBox(height: 16),

        // Grille Boggle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: BoggleGrid(
            letters: game.grid,
            highlightedPath: _highlightedPath,
            isHighlightValid: _isHighlightValid,
            onPathSelected: (path) {
              // Construire le mot à partir du path
              final word = path.map((i) => game.grid[i]).join();
              _handleWordSubmit(word);
            },
          ),
        ),

        const SizedBox(height: 16),

        // Input mot
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _WordInputWithFeedback(
            key: _wordInputKey,
            onWordSubmitted: _handleWordSubmit,
            enabled: game.state == GameState.playing,
          ),
        ),

        const SizedBox(height: 8),

        // Liste des mots trouvés
        Expanded(
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

  @override
  void dispose() {
    _gameProvider?.removeListener(_onGameStateChange);
    super.dispose();
  }
}

class _WordInputWithFeedback extends StatefulWidget {
  final Function(String) onWordSubmitted;
  final bool enabled;

  const _WordInputWithFeedback({
    super.key,
    required this.onWordSubmitted,
    this.enabled = true,
  });

  @override
  State<_WordInputWithFeedback> createState() => _WordInputWithFeedbackState();
}

class _WordInputWithFeedbackState extends State<_WordInputWithFeedback> {
  final TextEditingController _controller = TextEditingController();
  String? _feedbackMessage;
  bool _isError = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

  void _submitWord() {
    final word = _controller.text.trim().toUpperCase();
    if (word.isNotEmpty) {
      widget.onWordSubmitted(word);
      _controller.clear();
    }
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
