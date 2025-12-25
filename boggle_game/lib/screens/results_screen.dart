import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_provider.dart';
import '../models/word.dart';
import '../models/game_result.dart';
import 'home_screen.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
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

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCurrentPlayer ? Colors.blue[50] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCurrentPlayer ? Colors.blue : Colors.grey[300]!,
                        width: isCurrentPlayer ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildRankBadge(index + 1),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                              Text(
                                '+${result.roundScore} cette manche',
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
                _buildWordsList(currentPlayerResult.words),

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
              ],
            ),
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

  Widget _buildWordsList(List<Word> words) {
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

    // Séparer mots valides et doublons
    final validWords = words.where((w) => !w.isDuplicate).toList();
    final duplicateWords = words.where((w) => w.isDuplicate).toList();

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
                return Chip(
                  label: Text('${word.text} (+${word.points})'),
                  backgroundColor: Colors.green[100],
                  side: BorderSide(color: Colors.green[300]!),
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
                return Chip(
                  label: Text(
                    word.text,
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                    ),
                  ),
                  backgroundColor: Colors.grey[200],
                  side: BorderSide(color: Colors.grey[400]!),
                );
              }).toList(),
            ),
          ],
        ],
      ),
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
