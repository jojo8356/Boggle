import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../widgets/player_list.dart';
import '../services/game_provider.dart';
import 'game_screen.dart';

class LobbyScreen extends StatefulWidget {
  final ConnectionType connectionType;
  final String playerName;
  final bool isHost;
  final String? hostAddress;

  const LobbyScreen({
    super.key,
    required this.connectionType,
    required this.playerName,
    required this.isHost,
    this.hostAddress,
  });

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  bool _isConnecting = true;
  String? _connectionInfo;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initConnection();
  }

  Future<void> _initConnection() async {
    final gameProvider = context.read<GameProvider>();

    try {
      await gameProvider.initConnection(
        connectionType: widget.connectionType,
        playerName: widget.playerName,
        isHost: widget.isHost,
        hostAddress: widget.hostAddress,
      );

      setState(() {
        _isConnecting = false;
        _connectionInfo = gameProvider.connectionInfo;
      });
    } catch (e) {
      setState(() {
        _isConnecting = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _startGame() {
    final gameProvider = context.read<GameProvider>();
    gameProvider.startGame();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const GameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salle d\'attente'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: _isConnecting
          ? _buildLoadingView()
          : _errorMessage != null
              ? _buildErrorView()
              : _buildLobbyView(),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Connexion en cours...'),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Retour'),
          ),
        ],
      ),
    );
  }

  Widget _buildLobbyView() {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final game = gameProvider.game;
        final players = game?.players ?? [];
        final canStart = widget.isHost && players.isNotEmpty;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_connectionInfo != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Info de connexion',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _connectionInfo!,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              Text(
                'Joueurs (${players.length}/${GameConstants.maxPlayers})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: PlayerList(
                  players: players,
                  currentPlayerId: gameProvider.currentPlayerId,
                  showScores: false,
                ),
              ),
              const SizedBox(height: 16),
              if (widget.isHost)
                ElevatedButton(
                  onPressed: canStart ? _startGame : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Démarrer la partie',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'En attente du lancement par l\'hôte...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
