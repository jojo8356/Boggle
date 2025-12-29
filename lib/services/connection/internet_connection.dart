import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import '../../models/game.dart';
import '../../models/player.dart';
import '../../models/word.dart';
import 'connection_interface.dart';

class InternetConnection implements ConnectionInterface {
  HttpServer? _server;
  final List<WebSocketChannel> _clients = [];
  WebSocketChannel? _clientConnection;
  String? _hostAddress;
  bool _isHost = false;

  @override
  String? get connectionInfo => _hostAddress;

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

    // Trouver l'adresse IP locale
    final interfaces = await NetworkInterface.list();
    String? localIP;
    for (var interface in interfaces) {
      for (var addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
          localIP = addr.address;
          break;
        }
      }
    }

    _server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
    _hostAddress = '${localIP ?? 'localhost'}:8080';

    _server!.transform(WebSocketTransformer()).listen((WebSocket webSocket) {
      final channel = IOWebSocketChannel(webSocket);
      _clients.add(channel);

      channel.stream.listen(
        (message) => _handleMessage(message, channel),
        onDone: () => _handleClientDisconnect(channel),
        onError: (error) => _handleClientDisconnect(channel),
      );

      // Envoyer l'état actuel du jeu au nouveau client
      channel.sink.add(jsonEncode({
        'type': 'game_state',
        'data': game.toJson(),
      }));
    });
  }

  @override
  Future<void> joinGame(String address, Player player) async {
    _isHost = false;

    final uri = Uri.parse('ws://$address');
    _clientConnection = WebSocketChannel.connect(uri);

    await _clientConnection!.ready;

    _clientConnection!.stream.listen(
      (message) => _handleMessage(message, null),
      onDone: () => disconnect(),
      onError: (error) => disconnect(),
    );

    // Envoyer les infos du joueur
    _clientConnection!.sink.add(jsonEncode({
      'type': 'player_join',
      'data': player.toJson(),
    }));
  }

  void _handleMessage(dynamic message, WebSocketChannel? sender) {
    try {
      final data = jsonDecode(message as String);
      final type = data['type'] as String;

      switch (type) {
        case 'game_state':
          final game = Game.fromJson(data['data']);
          onGameUpdate?.call(game);
          break;

        case 'player_join':
          final player = Player.fromJson(data['data']);
          onPlayerJoined?.call(player);
          break;

        case 'player_left':
          final playerId = data['data'] as String;
          onPlayerLeft?.call(playerId);
          break;

        case 'game_start':
          onGameStart?.call();
          break;

        case 'game_end':
          onGameEnd?.call();
          break;

        case 'word':
          final word = Word.fromJson(data['data']);
          // Le host reçoit un mot d'un joueur, l'ajoute au jeu et le broadcast
          if (_isHost) {
            onWordReceived?.call(word);
            _broadcast(message, exclude: sender);
          } else {
            // Le client reçoit un mot d'un autre joueur
            onWordReceived?.call(word);
          }
          break;

        case 'new_game_vote':
          final playerId = data['data'] as String;
          onNewGameVote?.call(playerId);
          break;
      }
    } catch (_) {
      // Ignorer les erreurs de parsing
    }
  }

  void _handleClientDisconnect(WebSocketChannel channel) {
    _clients.remove(channel);
  }

  void _broadcast(String message, {WebSocketChannel? exclude}) {
    for (var client in _clients) {
      if (client != exclude) {
        client.sink.add(message);
      }
    }
  }

  @override
  void broadcastGameState(Game game) {
    final message = jsonEncode({
      'type': 'game_state',
      'data': game.toJson(),
    });

    if (_isHost) {
      _broadcast(message);
    }
  }

  @override
  void broadcastGameStart() {
    final message = jsonEncode({'type': 'game_start'});
    if (_isHost) {
      _broadcast(message);
    }
  }

  @override
  void broadcastGameEnd() {
    final message = jsonEncode({'type': 'game_end'});
    if (_isHost) {
      _broadcast(message);
    }
  }

  @override
  void sendWord(Word word) {
    final message = jsonEncode({
      'type': 'word',
      'data': word.toJson(),
    });

    if (_isHost) {
      _broadcast(message);
    } else {
      _clientConnection?.sink.add(message);
    }
  }

  @override
  void sendNewGameVote(String playerId) {
    final message = jsonEncode({
      'type': 'new_game_vote',
      'data': playerId,
    });

    if (_isHost) {
      _broadcast(message);
    } else {
      _clientConnection?.sink.add(message);
    }
  }

  @override
  void disconnect() {
    for (var client in _clients) {
      client.sink.close();
    }
    _clients.clear();
    _clientConnection?.sink.close();
    _server?.close();
  }
}
