import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/game_provider.dart';
import '../services/game_logic_service.dart';
import '../models/word.dart';
import '../models/game_result.dart';
import '../utils/constants.dart';
import 'home_screen.dart';
import 'game_screen.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _gameProvider = context.read<GameProvider>();
      _gameProvider?.addListener(_onGameStateChange);
    });
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
        backgroundColor: Colors.purple,
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
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.purple[400]!, Colors.purple[600]!],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                              color: isCurrentPlayer ? Colors.blue[50] : Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isCurrentPlayer ? Colors.blue : Colors.grey[300]!,
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
                                                  color: Colors.grey[600],
                                                ),
                                              ],
                                            ),
                                            Text(
                                              '+${result.roundScore} cette manche • ${result.words.length} mots',
                                              style: TextStyle(
                                                color: Colors.grey[600],
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
                                          color: Colors.purple,
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[300]!),
      ),
      child: ExpansionTile(
        leading: Icon(Icons.lightbulb, color: Colors.orange[700]),
        title: Text(
          'Tous les mots possibles',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.orange[800],
          ),
        ),
        subtitle: _allPossibleWords != null
            ? Text(
                '${_allPossibleWords!.length} mots trouvés',
                style: TextStyle(color: Colors.orange[600], fontSize: 12),
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

    // Calculer dans un Future pour ne pas bloquer l'UI
    Future.microtask(() {
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

    // Grouper par longueur
    final wordsByLength = <int, List<String>>{};
    for (final word in _allPossibleWords!) {
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
                  color: Colors.orange[200],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$length lettres (+$points pts) - ${words.length} mots',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.orange[900],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: words.map((word) {
                  final isSelected = _selectedWord == word;
                  return GestureDetector(
                    onTap: () => _selectWord(word, grid),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.orange[300] : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? Colors.orange[700]! : Colors.orange[200]!,
                          width: 2, // Largeur fixe pour éviter les sauts de layout
                        ),
                      ),
                      child: Text(
                        word,
                        style: TextStyle(
                          fontSize: 18,
                          color: isSelected ? Colors.orange[900] : Colors.grey[800],
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
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
      decoration: BoxDecoration(
        color: Colors.brown[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.brown[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.grid_4x4, color: Colors.brown[700]),
              const SizedBox(width: 8),
              Text(
                'Grille de la manche',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[800],
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
                      foregroundColor: Colors.brown[600],
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
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green[300]!),
                  ),
                  child: Text(
                    'Mot sélectionné: $_selectedWord',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
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
                  color: Colors.brown[100],
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
                        color: isHighlighted ? Colors.green[300] : Colors.amber[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isHighlighted ? Colors.green[700]! : Colors.brown[400]!,
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
                                color: Colors.brown[900],
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
                                  color: Colors.green[700],
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
              color: Colors.brown[600],
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

  Future<List<String>> _fetchDefinitions(String word) async {
    final lowercaseWord = word.toLowerCase();

    // Essayer d'abord le CNRTL (TLFi)
    try {
      final cnrtlUrl = Uri.parse('https://www.cnrtl.fr/definition/$lowercaseWord');
      final response = await http.get(cnrtlUrl).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final definitions = _parseCnrtlDefinitions(response.body);
        if (definitions.isNotEmpty) {
          return definitions;
        }
      }
    } catch (e) {
      // Erreur CNRTL, on continue
    }

    // Fallback: Larousse
    try {
      final larousseUrl = Uri.parse('https://www.larousse.fr/dictionnaires/francais/$lowercaseWord');
      final response = await http.get(larousseUrl).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final definitions = _parseLarousseDefinitions(response.body);
        if (definitions.isNotEmpty) {
          return definitions;
        }
      }
    } catch (e) {
      // Erreur Larousse
    }

    return [];
  }

  List<String> _parseCnrtlDefinitions(String html) {
    final definitions = <String>[];

    // Chercher les définitions dans les balises tlf_cdefinition
    final defRegex = RegExp(r'<span[^>]*class="[^"]*tlf_cdefinition[^"]*"[^>]*>(.*?)</span>', dotAll: true);
    final matches = defRegex.allMatches(html);

    for (final match in matches) {
      if (definitions.length >= 3) break;

      var text = match.group(1) ?? '';
      // Nettoyer le HTML
      text = text
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();

      if (text.isNotEmpty && text.length > 10) {
        definitions.add(text);
      }
    }

    // Si pas de définitions trouvées, essayer une autre méthode
    if (definitions.isEmpty) {
      final altRegex = RegExp(r'<div[^>]*class="[^"]*tlf_parah[^"]*"[^>]*>(.*?)</div>', dotAll: true);
      final altMatches = altRegex.allMatches(html);

      for (final match in altMatches) {
        if (definitions.length >= 2) break;

        var text = match.group(1) ?? '';
        text = text
          .replaceAll(RegExp(r'<[^>]+>'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

        if (text.isNotEmpty && text.length > 20 && !text.contains('Prononc.')) {
          definitions.add(text);
        }
      }
    }

    return definitions;
  }

  List<String> _parseLarousseDefinitions(String html) {
    final definitions = <String>[];

    // Chercher les définitions Larousse
    final defRegex = RegExp(r'<li[^>]*class="[^"]*DivisionDefinition[^"]*"[^>]*>(.*?)</li>', dotAll: true);
    final matches = defRegex.allMatches(html);

    for (final match in matches) {
      if (definitions.length >= 3) break;

      var text = match.group(1) ?? '';
      text = text
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll('&nbsp;', ' ')
        .trim();

      if (text.isNotEmpty && text.length > 10) {
        definitions.add(text);
      }
    }

    return definitions;
  }

  void _showDefinitionDialog(String word) {
    final lowercaseWord = word.toLowerCase();
    final cnrtlUrl = 'https://www.cnrtl.fr/definition/$lowercaseWord';

    showDialog(
      context: context,
      builder: (dialogContext) => FutureBuilder<List<String>>(
        future: _fetchDefinitions(word),
        builder: (context, snapshot) {
          final definitions = snapshot.data ?? [];
          final isLoading = snapshot.connectionState == ConnectionState.waiting;

          return AlertDialog(
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
                    if (isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (definitions.isEmpty)
                      Text(
                        'Définition non disponible',
                        style: TextStyle(
                          color: Colors.grey[600],
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
                                color: Colors.orange[100],
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${entry.key + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[800],
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
          );
        },
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
        color = Colors.grey[400]!;
        icon = Icons.emoji_events;
        break;
      case 3:
        color = Colors.brown[300]!;
        icon = Icons.emoji_events;
        break;
      default:
        color = Colors.grey[300]!;
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
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Aucun mot trouvé',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey,
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
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (validWords.isNotEmpty) ...[
            Text(
              'Mots comptés (${validWords.length})',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.green,
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
                    backgroundColor: isSelected ? Colors.green[300] : Colors.green[100],
                    side: BorderSide(
                      color: isSelected ? Colors.green[700]! : Colors.green[300]!,
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
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
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
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                      ),
                    ),
                    backgroundColor: isSelected ? Colors.grey[400] : Colors.grey[200],
                    side: BorderSide(
                      color: isSelected ? Colors.grey[700]! : Colors.grey[400]!,
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
                color: Colors.red,
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
                        color: Colors.red,
                      ),
                    ),
                    backgroundColor: isSelected ? Colors.red[200] : Colors.red[50],
                    side: BorderSide(
                      color: isSelected ? Colors.red[700]! : Colors.red[300]!,
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
          color: Colors.grey[600],
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
            spacing: 6,
            runSpacing: 4,
            children: validWords.map((word) {
              final isSelected = _selectedWord == word.text;
              return GestureDetector(
                onTap: () => _selectWord(word.text, grid),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.green[300] : Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.green[700]! : Colors.green[300]!,
                    ),
                  ),
                  child: Text(
                    '${word.text} +${word.points}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[800],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
        if (duplicateWords.isNotEmpty) ...[
          if (validWords.isNotEmpty) const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: duplicateWords.map((word) {
              final isSelected = _selectedWord == word.text;
              return GestureDetector(
                onTap: () => _selectWord(word.text, grid),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.grey[400] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.grey[600]! : Colors.grey[400]!,
                    ),
                  ),
                  child: Text(
                    word.text,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
        if (invalidWords.isNotEmpty) ...[
          if (validWords.isNotEmpty || duplicateWords.isNotEmpty) const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: invalidWords.map((word) {
              final isSelected = _selectedWord == word.text;
              return GestureDetector(
                onTap: () => _selectWord(word.text, grid),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.red[200] : Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.red[600]! : Colors.red[300]!,
                    ),
                  ),
                  child: Text(
                    word.text,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red[700],
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ),
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
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue),
      ),
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
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),

          // Liste des votes
          Wrap(
            spacing: 8,
            children: game.players.map((player) {
              return Chip(
                avatar: Icon(
                  player.votedForNewGame ? Icons.check_circle : Icons.hourglass_empty,
                  color: player.votedForNewGame ? Colors.green : Colors.grey,
                  size: 18,
                ),
                label: Text(player.name),
                backgroundColor:
                    player.votedForNewGame ? Colors.green[100] : Colors.grey[200],
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          if (!hasVoted)
            ElevatedButton(
              onPressed: () => gameProvider.voteForNewGame(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('Voter pour une nouvelle partie'),
            )
          else
            const Text(
              'Vous avez voté! En attente des autres joueurs...',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
        ],
      ),
    );
  }
}
