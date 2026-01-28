import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/definition_service.dart';
import '../services/game_provider.dart';
import '../services/game_logic_service.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/word.dart';
import '../models/game_result.dart';
import '../models/match_record.dart';
import '../utils/constants.dart';
import 'home_screen.dart';
import 'game_screen.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/word_chip.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  List<String>? _allPossibleWords;
  bool _isLoadingWords = false;
  String? _selectedWord;
  List<int>? _highlightedPath;
  GameProvider? _gameProvider;
  String? _expandedPlayerId; // ID du joueur dont les mots sont affichés

  @override
  void initState() {
    super.initState();
    DefinitionService().loadDefinitions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _gameProvider = context.read<GameProvider>();
      _gameProvider?.addListener(_onGameStateChange);
      _saveMatchIfLoggedIn();
    });
  }

  Future<void> _saveMatchIfLoggedIn() async {
    final authService = context.read<AuthService>();
    if (!authService.isLoggedIn) return;

    final gameProvider = context.read<GameProvider>();
    final game = gameProvider.game;
    final currentPlayer = gameProvider.currentPlayer;

    if (game == null || currentPlayer == null) return;

    // Calculer le résultat
    final playerResults = game.players.map((player) {
      final words = game.allWords.where((w) => w.playerId == player.id).toList();
      final roundScore = words.fold<int>(0, (sum, w) => sum + w.effectivePoints);
      return (playerId: player.id, score: player.score, roundScore: roundScore, words: words);
    }).toList();

    playerResults.sort((a, b) => b.score.compareTo(a.score));
    final rank = playerResults.indexWhere((r) => r.playerId == currentPlayer.id) + 1;
    final isWin = rank == 1;

    final currentPlayerResult = playerResults.firstWhere((r) => r.playerId == currentPlayer.id);
    final validWords = currentPlayerResult.words.where((w) => !w.isDuplicate && !w.isInvalid).length;

    final match = MatchRecord(
      userId: authService.currentUser!.id!,
      playedAt: DateTime.now(),
      score: currentPlayer.score,
      wordsFound: currentPlayerResult.words.length,
      validWords: validWords,
      rank: rank,
      totalPlayers: game.players.length,
      isWin: isWin,
      isSolo: game.players.length == 1,
      gameDuration: GameConstants.gameDurationSeconds,
    );

    await DatabaseService.instance.insertMatch(match);
  }

  void _onGameStateChange() {
    if (_gameProvider?.game?.state == GameState.playing) {
      _gameProvider?.removeListener(_onGameStateChange);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GameScreen()),
      );
    }
  }

  @override
  void dispose() {
    _gameProvider?.removeListener(_onGameStateChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultats'),
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          final game = gameProvider.game;
          final currentPlayer = gameProvider.currentPlayer;

          if (game == null || currentPlayer == null) {
            return const Center(child: Text('Erreur: Données non disponibles'));
          }

          // Créer les résultats
          final playerResults = game.players.map((player) {
            final words = game.allWords.where((w) => w.playerId == player.id).toList();
            final roundScore = words.fold<int>(0, (sum, w) => sum + w.effectivePoints);

            return PlayerResult(
              playerId: player.id,
              playerName: player.name,
              words: words,
              roundScore: roundScore,
              totalScore: player.score,
            );
          }).toList();

          final gameResult = GameResult(
            playerResults: playerResults,
            roundNumber: game.roundNumber,
          );

          final ranking = gameResult.getRanking();
          final currentPlayerResult = playerResults.firstWhere(
            (r) => r.playerId == currentPlayer.id,
          );

          return Column(
            children: [
              // Grille fixe en haut
              Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                padding: const EdgeInsets.all(12),
                child: _buildReviewGrid(game.grid),
              ),

              // Contenu scrollable
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Titre manche
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: AppDecorations.roundTitle(),
                        child: Text(
                          'Manche ${game.roundNumber} terminée!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Classement
                      const Text(
                        'Classement',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...ranking.asMap().entries.map((entry) {
                        final index = entry.key;
                        final result = entry.value;
                        final isCurrentPlayer = result.playerId == currentPlayer.id;
                        final isExpanded = _expandedPlayerId == result.playerId;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_expandedPlayerId == result.playerId) {
                                _expandedPlayerId = null;
                              } else {
                                _expandedPlayerId = result.playerId;
                              }
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: isCurrentPlayer ? AppColors.blue50 : AppColors.grey100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isCurrentPlayer ? AppColors.blue : AppColors.grey300,
                                width: isCurrentPlayer ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      _buildRankBadge(index + 1),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  result.playerName,
                                                  style: TextStyle(
                                                    fontWeight: isCurrentPlayer
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Icon(
                                                  isExpanded ? Icons.expand_less : Icons.expand_more,
                                                  size: 20,
                                                  color: AppColors.grey600,
                                                ),
                                              ],
                                            ),
                                            Text(
                                              '+${result.roundScore} cette manche • ${result.words.length} mots',
                                              style: TextStyle(
                                                color: AppColors.grey600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.purple,
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Text(
                                          '${result.totalScore} pts',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Mots du joueur (visible si expandé)
                                if (isExpanded) ...[
                                  const Divider(height: 1),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: _buildPlayerExpandedWords(result.words, game.grid),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 24),

                      // Vos mots
                      const Text(
                        'Vos mots',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildWordsList(currentPlayerResult.words, game.grid),

                      const SizedBox(height: 24),

                      // Section tous les mots possibles (cachée par défaut)
                      _buildAllPossibleWordsSection(game.grid),

                      const SizedBox(height: 24),

                      // Bouton rejouer la même grille (solo uniquement)
                      if (game.players.length == 1)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: AppDecorations.replaySection(),
                          child: Column(
                            children: [
                              Icon(Icons.replay, color: AppColors.amber700, size: 32),
                              const SizedBox(height: 8),
                              const Text(
                                'Rejouer la même grille',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tentez d\'améliorer votre score avec la même grille!',
                                style: TextStyle(
                                  color: AppColors.grey700,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () => gameProvider.replaySameGrid(),
                                icon: const Icon(Icons.replay),
                                label: const Text('Rejouer cette grille'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.amber600,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Vote nouvelle partie
                      _buildNewGameSection(context, gameProvider),

                      const SizedBox(height: 16),

                      // Bouton quitter
                      OutlinedButton(
                        onPressed: () {
                          gameProvider.dispose();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const HomeScreen()),
                            (route) => false,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Quitter la partie'),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAllPossibleWordsSection(List<String> grid) {
    final gameProvider = context.read<GameProvider>();
    final currentPlayer = gameProvider.currentPlayer;
    final userFoundWords = currentPlayer?.foundWords.toSet() ?? <String>{};

    final totalPossible = _allPossibleWords?.length ?? 0;
    final notFoundCount = _allPossibleWords
        ?.where((word) => !userFoundWords.contains(word))
        .length ?? 0;

    return Container(
      decoration: AppDecorations.possibleWordsSection(),
      child: ExpansionTile(
        leading: Icon(Icons.lightbulb, color: AppColors.orange700),
        title: Text(
          'Mots que vous avez manqués',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.orange800,
          ),
        ),
        subtitle: _allPossibleWords != null
            ? Text(
                '$notFoundCount mots manqués sur $totalPossible possibles',
                style: TextStyle(color: AppColors.orange600, fontSize: 12),
              )
            : null,
        onExpansionChanged: (expanded) {
          if (expanded && _allPossibleWords == null && !_isLoadingWords) {
            _loadAllPossibleWords(grid);
          }
        },
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildPossibleWordsList(grid),
          ),
        ],
      ),
    );
  }

  void _loadAllPossibleWords(List<String> grid) {
    setState(() {
      _isLoadingWords = true;
    });

    // Use Future.delayed to yield to the event loop, letting the UI paint
    // the loading state before running the expensive computation.
    // Note: compute() cannot be used here because DictionaryService is a
    // singleton that loads data via rootBundle on the main isolate; a new
    // isolate would get a fresh, uninitialised instance.
    Future.delayed(Duration.zero, () {
      final gameLogic = GameLogicService();
      final words = gameLogic.findAllPossibleWords(grid);
      if (mounted) {
        setState(() {
          _allPossibleWords = words;
          _isLoadingWords = false;
        });
      }
    });
  }

  Widget _buildPossibleWordsList(List<String> grid) {
    if (_isLoadingWords) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Recherche des mots...'),
            ],
          ),
        ),
      );
    }

    if (_allPossibleWords == null || _allPossibleWords!.isEmpty) {
      return const Text('Aucun mot trouvé');
    }

    // Récupérer les mots trouvés par l'utilisateur
    final gameProvider = context.read<GameProvider>();
    final currentPlayer = gameProvider.currentPlayer;
    final userFoundWords = currentPlayer?.foundWords.toSet() ?? <String>{};

    // Filtrer pour ne garder que les mots NON trouvés par l'utilisateur
    final wordsNotFound = _allPossibleWords!
        .where((word) => !userFoundWords.contains(word))
        .toList();

    if (wordsNotFound.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.celebration, size: 48, color: AppColors.amber700),
            const SizedBox(height: 12),
            const Text(
              'Félicitations! Vous avez trouvé tous les mots possibles!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Grouper par longueur (uniquement les mots non trouvés)
    final wordsByLength = <int, List<String>>{};
    for (final word in wordsNotFound) {
      final length = word.length;
      wordsByLength.putIfAbsent(length, () => []).add(word);
    }

    final sortedLengths = wordsByLength.keys.toList()..sort((a, b) => a.compareTo(b));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedLengths.map((length) {
        final words = wordsByLength[length]!;
        final points = GameConstants.getPoints(length);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.orange200,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$length lettres (+$points pts) - ${words.length} mots',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.orange900,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: words.map((word) {
                  final isSelected = _selectedWord == word;
                  return WordChip(
                    text: word,
                    backgroundColor: isSelected ? AppColors.orange300 : Colors.white,
                    borderColor: isSelected ? AppColors.orange700 : AppColors.orange200,
                    textColor: isSelected ? AppColors.orange900 : AppColors.grey700,
                    fontSize: 18,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    isSelected: isSelected,
                    onTap: () => _selectWord(word, grid),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReviewGrid(List<String> grid) {
    final int gridSize = GameConstants.gridSize;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.reviewGrid(),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.grid_4x4, color: AppColors.brown700),
              const SizedBox(width: 8),
              Text(
                'Grille de la manche',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.brown800,
                ),
              ),
              const Spacer(),
              // Bouton toujours présent mais invisible quand pas de sélection
              Opacity(
                opacity: _selectedWord != null ? 1.0 : 0.0,
                child: IgnorePointer(
                  ignoring: _selectedWord == null,
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedWord = null;
                        _highlightedPath = null;
                      });
                    },
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Effacer'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.brown600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Espace réservé pour le mot sélectionné (toujours présent pour éviter les sauts)
          SizedBox(
            height: 36,
            child: _selectedWord != null
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: AppDecorations.selectedWordPill(),
                  child: Text(
                    'Mot sélectionné: $_selectedWord',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.green800,
                    ),
                  ),
                )
              : null,
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300, maxHeight: 300),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.brown100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridSize,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemCount: gridSize * gridSize,
                  itemBuilder: (context, index) {
                    final isHighlighted = _highlightedPath?.contains(index) ?? false;
                    final pathIndex = _highlightedPath?.indexOf(index) ?? -1;

                    return Container(
                      decoration: BoxDecoration(
                        color: isHighlighted ? AppColors.green300 : AppColors.amber100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isHighlighted ? AppColors.green700 : AppColors.brown400,
                          width: isHighlighted ? 3 : 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.brown.withValues(alpha: 0.2),
                            blurRadius: 2,
                            offset: const Offset(1, 1),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              grid[index],
                              style: TextStyle(
                                fontSize: gridSize <= 4 ? 22 : 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.brown900,
                              ),
                            ),
                          ),
                          if (isHighlighted && pathIndex >= 0)
                            Positioned(
                              top: 2,
                              left: 2,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: AppColors.green700,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${pathIndex + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cliquez sur un mot ci-dessous pour voir son chemin',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.brown600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  void _selectWord(String word, List<String> grid) {
    // Si le mot est déjà sélectionné, afficher la définition
    if (_selectedWord == word) {
      _showDefinitionDialog(word);
      return;
    }

    // Sinon, juste afficher le chemin
    final gameLogic = GameLogicService();
    final paths = gameLogic.findWordPath(grid, word);

    setState(() {
      _selectedWord = word;
      _highlightedPath = paths?.first;
    });
  }

  List<String> _lookupDefinitions(String word) {
    return DefinitionService().getDefinitions(word);
  }

  void _showDefinitionDialog(String word) {
    final lowercaseWord = word.toLowerCase();
    final cnrtlUrl = 'https://www.cnrtl.fr/definition/$lowercaseWord';
    final definitions = _lookupDefinitions(word);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          word,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 300),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (definitions.isEmpty)
                  Text(
                    'Définition non disponible',
                    style: TextStyle(
                      color: AppColors.grey600,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                else
                  ...definitions.asMap().entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.orange100,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.orange800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  )),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fermer'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final uri = Uri.parse(cnrtlUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            icon: const Icon(Icons.open_in_new, size: 18),
            label: const Text('CNRTL'),
          ),
        ],
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    Color color;
    IconData? icon;

    switch (rank) {
      case 1:
        color = Colors.amber;
        icon = Icons.emoji_events;
        break;
      case 2:
        color = AppColors.grey400;
        icon = Icons.emoji_events;
        break;
      case 3:
        color = AppColors.brown300;
        icon = Icons.emoji_events;
        break;
      default:
        color = AppColors.grey300;
        icon = null;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: icon != null
            ? Icon(icon, color: Colors.white, size: 24)
            : Text(
                '$rank',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }

  Widget _buildWordsList(List<Word> words, List<String> grid) {
    if (words.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Aucun mot trouvé',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: AppColors.grey400,
          ),
        ),
      );
    }

    // Séparer mots valides, doublons et invalides
    final validWords = words.where((w) => !w.isDuplicate && !w.isInvalid).toList();
    final duplicateWords = words.where((w) => w.isDuplicate && !w.isInvalid).toList();
    final invalidWords = words.where((w) => w.isInvalid).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (validWords.isNotEmpty) ...[
            Text(
              'Mots comptés (${validWords.length})',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.green500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: validWords.map((word) {
                final isSelected = _selectedWord == word.text;
                return GestureDetector(
                  onTap: () => _selectWord(word.text, grid),
                  child: Chip(
                    label: Text('${word.text} (+${word.points})'),
                    backgroundColor: isSelected ? AppColors.green300 : AppColors.green100,
                    side: BorderSide(
                      color: isSelected ? AppColors.green700 : AppColors.green300,
                      width: 2, // Largeur fixe pour éviter les sauts de layout
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          if (duplicateWords.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Mots trouvés par d\'autres (${duplicateWords.length})',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.grey400,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: duplicateWords.map((word) {
                final isSelected = _selectedWord == word.text;
                return GestureDetector(
                  onTap: () => _selectWord(word.text, grid),
                  child: Chip(
                    label: Text(
                      word.text,
                      style: TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: AppColors.grey400,
                      ),
                    ),
                    backgroundColor: isSelected ? AppColors.grey400 : AppColors.grey200,
                    side: BorderSide(
                      color: isSelected ? AppColors.grey700 : AppColors.grey400,
                      width: 2, // Largeur fixe pour éviter les sauts de layout
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          if (invalidWords.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Mots invalides (${invalidWords.length})',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.red,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: invalidWords.map((word) {
                final isSelected = _selectedWord == word.text;
                return GestureDetector(
                  onTap: () => _selectWord(word.text, grid),
                  child: Chip(
                    label: Text(
                      word.text,
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: AppColors.red,
                      ),
                    ),
                    backgroundColor: isSelected ? AppColors.red200 : AppColors.red50,
                    side: BorderSide(
                      color: isSelected ? AppColors.red700 : AppColors.red300,
                      width: 2,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayerExpandedWords(List<Word> words, List<String> grid) {
    if (words.isEmpty) {
      return Text(
        'Aucun mot trouvé',
        style: TextStyle(
          fontStyle: FontStyle.italic,
          color: AppColors.grey600,
        ),
      );
    }

    // Séparer mots valides, doublons et invalides
    final validWords = words.where((w) => !w.isDuplicate && !w.isInvalid).toList();
    final duplicateWords = words.where((w) => w.isDuplicate && !w.isInvalid).toList();
    final invalidWords = words.where((w) => w.isInvalid).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (validWords.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: validWords.map((word) {
              final isSelected = _selectedWord == word.text;
              return WordChip(
                text: '${word.text} +${word.points}',
                isSelected: isSelected,
                onTap: () => _selectWord(word.text, grid),
              );
            }).toList(),
          ),
        ],
        if (duplicateWords.isNotEmpty) ...[
          if (validWords.isNotEmpty) const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: duplicateWords.map((word) {
              final isSelected = _selectedWord == word.text;
              return WordChip(
                text: word.text,
                backgroundColor: isSelected ? AppColors.grey400 : AppColors.grey200,
                borderColor: isSelected ? AppColors.grey600 : AppColors.grey400,
                textColor: AppColors.grey600,
                fontWeight: FontWeight.normal,
                textDecoration: TextDecoration.lineThrough,
                isSelected: isSelected,
                onTap: () => _selectWord(word.text, grid),
              );
            }).toList(),
          ),
        ],
        if (invalidWords.isNotEmpty) ...[
          if (validWords.isNotEmpty || duplicateWords.isNotEmpty) const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: invalidWords.map((word) {
              final isSelected = _selectedWord == word.text;
              return WordChip(
                text: word.text,
                backgroundColor: isSelected ? AppColors.red200 : AppColors.red50,
                borderColor: isSelected ? AppColors.red600 : AppColors.red300,
                textColor: AppColors.red700,
                fontWeight: FontWeight.normal,
                textDecoration: TextDecoration.lineThrough,
                isSelected: isSelected,
                onTap: () => _selectWord(word.text, grid),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildNewGameSection(BuildContext context, GameProvider gameProvider) {
    final game = gameProvider.game!;
    final currentPlayer = gameProvider.currentPlayer!;
    final votedCount = game.players.where((p) => p.votedForNewGame).length;
    final totalPlayers = game.players.length;
    final hasVoted = currentPlayer.votedForNewGame;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.newGameSection(),
      child: Column(
        children: [
          const Text(
            'Nouvelle partie?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$votedCount/$totalPlayers joueurs ont voté',
            style: TextStyle(color: AppColors.grey600),
          ),
          const SizedBox(height: 12),

          // Liste des votes
          Wrap(
            spacing: 8,
            children: game.players.map((player) {
              return Chip(
                avatar: Icon(
                  player.votedForNewGame ? Icons.check_circle : Icons.hourglass_empty,
                  color: player.votedForNewGame ? AppColors.green500 : AppColors.grey400,
                  size: 18,
                ),
                label: Text(player.name),
                backgroundColor:
                    player.votedForNewGame ? AppColors.green100 : AppColors.grey200,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          if (!hasVoted)
            ElevatedButton(
              onPressed: () => gameProvider.voteForNewGame(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green500,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('Voter pour une nouvelle partie'),
            )
          else
            Text(
              'Vous avez voté! En attente des autres joueurs...',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: AppColors.grey400,
              ),
            ),
        ],
      ),
    );
  }
}
