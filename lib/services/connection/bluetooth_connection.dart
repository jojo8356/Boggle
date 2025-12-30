import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart' as bt;
import '../../models/game.dart';
import '../../models/player.dart';
import '../../models/word.dart';
import 'connection_interface.dart';

class BluetoothConnection implements ConnectionInterface {
  bt.BluetoothConnection? _connection;
  StreamSubscription? _dataSubscription;
  String? _deviceName;
  String _buffer = '';

  @override
  String? get connectionInfo => _deviceName;

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

  /// Obtenir la liste des appareils appairés
  static Future<List<bt.BluetoothDevice>> getPairedDevices() async {
    return await bt.FlutterBluetoothSerial.instance.getBondedDevices();
  }

  /// Vérifier si le Bluetooth est activé
  static Future<bool> isBluetoothEnabled() async {
    return await bt.FlutterBluetoothSerial.instance.isEnabled ?? false;
  }

  /// Demander d'activer le Bluetooth
  static Future<bool?> requestEnable() async {
    return await bt.FlutterBluetoothSerial.instance.requestEnable();
  }

  @override
  Future<void> hostGame(Game game) async {
    _deviceName = 'Froggle Host';
    // En mode host avec Bluetooth Serial, on attend une connexion entrante
    // Le téléphone doit être en mode "discoverable"
    // Note: flutter_bluetooth_serial ne supporte pas le mode serveur directement
    // On utilise donc le même mécanisme que joinGame - l'hôte se connecte aussi
  }

  @override
  Future<void> joinGame(String address, Player player) async {
    if (address.isEmpty) {
      throw Exception('Adresse Bluetooth requise');
    }
    await connectToDevice(address);
  }

  /// Se connecter à un appareil par son adresse MAC
  Future<void> connectToDevice(String address) async {
    try {
      _connection = await bt.BluetoothConnection.toAddress(address);
      _deviceName = 'Connecté à $address';

      _dataSubscription = _connection!.input?.listen(_handleData);
    } catch (e) {
      throw Exception('Erreur de connexion Bluetooth: $e');
    }
  }

  void _handleData(Uint8List data) {
    try {
      _buffer += utf8.decode(data);

      // Traiter les messages complets (séparés par \n)
      while (_buffer.contains('\n')) {
        final index = _buffer.indexOf('\n');
        final message = _buffer.substring(0, index);
        _buffer = _buffer.substring(index + 1);

        if (message.isNotEmpty) {
          _processMessage(message);
        }
      }
    } catch (_) {
      // Ignorer les erreurs de décodage
    }
  }

  void _processMessage(String message) {
    try {
      final json = jsonDecode(message);
      final type = json['type'] as String;

      switch (type) {
        case 'game_state':
          onGameUpdate?.call(Game.fromJson(json['data']));
          break;
        case 'player_join':
          onPlayerJoined?.call(Player.fromJson(json['data']));
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
          onWordReceived?.call(word);
          break;
        case 'new_game_vote':
          onNewGameVote?.call(json['data'] as String);
          break;
      }
    } catch (_) {
      // Ignorer les erreurs de parsing
    }
  }

  Future<void> _sendMessage(Map<String, dynamic> message) async {
    if (_connection == null || !_connection!.isConnected) return;

    try {
      final data = '${jsonEncode(message)}\n';
      _connection!.output.add(Uint8List.fromList(utf8.encode(data)));
      await _connection!.output.allSent;
    } catch (_) {
      // Ignorer les erreurs d'envoi
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
    _dataSubscription?.cancel();
    _connection?.dispose();
    _connection = null;
    _buffer = '';
  }
}
