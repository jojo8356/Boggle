import 'dart:async';
import 'dart:convert';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';
import '../../models/game.dart';
import '../../models/player.dart';
import '../../models/word.dart';
import 'connection_interface.dart';

class WifiDirectConnection implements ConnectionInterface {
  FlutterP2pHost? _host;
  FlutterP2pClient? _client;
  StreamSubscription? _stateSubscription;
  StreamSubscription? _textSubscription;
  bool _isHost = false;
  String? _connectionInfo;

  @override
  String? get connectionInfo => _connectionInfo;

  @override
  Function(Game)? onGameUpdate;
  @override
  Function(Player)? onPlayerJoined;
  @override
  Function(String)? onPlayerLeft;
  @override
  Function()? onGameStart;
  @override
  Function()? onGameEnd;
  @override
  Function(String)? onNewGameVote;
  @override
  Function(Word)? onWordReceived;

  @override
  Future<void> hostGame(Game game) async {
    _isHost = true;
    _host = FlutterP2pHost();

    await _host!.initialize();

    // Écouter les messages reçus
    _textSubscription = _host!.streamReceivedTexts().listen(_handleMessage);

    // Écouter l'état du hotspot
    _stateSubscription = _host!.streamHotspotState().listen((state) {
      if (state.isActive) {
        _connectionInfo = 'SSID: ${state.ssid ?? "N/A"}\nMot de passe: ${state.preSharedKey ?? "N/A"}';
      }
    });

    // Créer le groupe WiFi Direct
    await _host!.createGroup();
  }

  @override
  Future<void> joinGame(String address, Player player) async {
    _isHost = false;
    _client = FlutterP2pClient();

    await _client!.initialize();

    // Écouter les messages reçus
    _textSubscription = _client!.streamReceivedTexts().listen(_handleMessage);

    // Écouter l'état de connexion
    _stateSubscription = _client!.streamHotspotState().listen((state) {
      if (state.isActive) {
        _connectionInfo = 'Connecté au host';
        // Envoyer les infos du joueur
        _sendMessage({
          'type': 'player_join',
          'data': player.toJson(),
        });
      }
    });

    // Scanner via BLE et se connecter automatiquement au premier host trouvé
    _client!.startScan(
      (devices) async {
        if (devices.isNotEmpty) {
          await _client!.stopScan();
          await _client!.connectWithDevice(devices.first);
        }
      },
      timeout: const Duration(seconds: 30),
    );
  }

  void _handleMessage(String data) {
    try {
      final json = jsonDecode(data);
      final type = json['type'] as String;

      switch (type) {
        case 'game_state':
          onGameUpdate?.call(Game.fromJson(json['data']));
          break;
        case 'player_join':
          onPlayerJoined?.call(Player.fromJson(json['data']));
          if (_isHost) {
            _broadcast(data);
          }
          break;
        case 'player_left':
          onPlayerLeft?.call(json['data'] as String);
          break;
        case 'game_start':
          onGameStart?.call();
          break;
        case 'game_end':
          onGameEnd?.call();
          break;
        case 'word':
          final word = Word.fromJson(json['data']);
          if (_isHost) {
            onWordReceived?.call(word);
            _broadcast(data);
          } else {
            onWordReceived?.call(word);
          }
          break;
        case 'new_game_vote':
          onNewGameVote?.call(json['data'] as String);
          break;
      }
    } catch (_) {
      // Ignorer les erreurs de parsing
    }
  }

  void _broadcast(String message) {
    _host?.broadcastText(message);
  }

  Future<void> _sendMessage(Map<String, dynamic> message) async {
    final data = jsonEncode(message);
    if (_isHost) {
      _host?.broadcastText(data);
    } else {
      _client?.broadcastText(data);
    }
  }

  @override
  void broadcastGameState(Game game) {
    _sendMessage({
      'type': 'game_state',
      'data': game.toJson(),
    });
  }

  @override
  void broadcastGameStart() {
    _sendMessage({'type': 'game_start'});
  }

  @override
  void broadcastGameEnd() {
    _sendMessage({'type': 'game_end'});
  }

  @override
  void sendWord(Word word) {
    _sendMessage({
      'type': 'word',
      'data': word.toJson(),
    });
  }

  @override
  void sendNewGameVote(String playerId) {
    _sendMessage({
      'type': 'new_game_vote',
      'data': playerId,
    });
  }

  @override
  void disconnect() {
    _stateSubscription?.cancel();
    _textSubscription?.cancel();
    _host?.removeGroup();
    _client?.disconnect();
    _host?.dispose();
    _client?.dispose();
    _host = null;
    _client = null;
  }
}
