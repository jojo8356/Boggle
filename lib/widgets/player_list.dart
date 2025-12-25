import 'package:flutter/material.dart';
import '../models/player.dart';
import '../utils/constants.dart';

class PlayerList extends StatelessWidget {
  final List<Player> players;
  final String? currentPlayerId;
  final bool showScores;
  final bool showVoteStatus;

  const PlayerList({
    super.key,
    required this.players,
    this.currentPlayerId,
    this.showScores = true,
    this.showVoteStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Joueurs',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...players.map((player) => _PlayerTile(
              player: player,
              isCurrentPlayer: player.id == currentPlayerId,
              showScore: showScores,
              showVoteStatus: showVoteStatus,
            )),
      ],
    );
  }
}

class _PlayerTile extends StatelessWidget {
  final Player player;
  final bool isCurrentPlayer;
  final bool showScore;
  final bool showVoteStatus;

  const _PlayerTile({
    required this.player,
    required this.isCurrentPlayer,
    required this.showScore,
    required this.showVoteStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          _buildStateIcon(),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      player.name,
                      style: TextStyle(
                        fontWeight:
                            isCurrentPlayer ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (player.isHost)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'HOST',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (isCurrentPlayer)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'VOUS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (showVoteStatus)
            Icon(
              player.votedForNewGame ? Icons.check_circle : Icons.hourglass_empty,
              color: player.votedForNewGame ? Colors.green : Colors.grey,
            ),
          if (showScore)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purple[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${player.score} pts',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[800],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStateIcon() {
    IconData icon;
    Color color;

    switch (player.state) {
      case PlayerState.connected:
        icon = Icons.wifi;
        color = Colors.orange;
        break;
      case PlayerState.ready:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case PlayerState.playing:
        icon = Icons.sports_esports;
        color = Colors.blue;
        break;
      case PlayerState.disconnected:
        icon = Icons.wifi_off;
        color = Colors.red;
        break;
    }

    return Icon(icon, color: color, size: 20);
  }
}
