import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../models/game.dart';
import '../../models/player.dart';
import '../../models/word.dart';
import 'connection_interface.dart';

class BluetoothConnection implements ConnectionInterface {
  static const String serviceUuid = '4fafc201-1fb5-459e-8fcc-c5c9c331914b';
  static const String characteristicUuid = 'beb5483e-36e1-4688-b7f5-ea07361b26a8';

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _characteristic;
  StreamSubscription? _scanSubscription;
  StreamSubscription? _characteristicSubscription;
  String? _deviceName;

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
  Future<void> hostGame(Game game) async {
    _deviceName = 'Boggle Host';
    // En mode host, on attend les connexions
    // Note: Flutter Blue Plus ne supporte pas le mode peripheral/advertiser
    // On utilise un mode simplifié où le host scanne aussi
    await _startScanning();
  }

  @override
  Future<void> joinGame(String address, Player player) async {
    await _startScanning();
  }

  Future<void> _startScanning() async {
    // Vérifier si Bluetooth est activé
    if (await FlutterBluePlus.isSupported == false) {
      throw Exception('Bluetooth non supporté sur cet appareil');
    }

    // Attendre que Bluetooth soit activé
    await FlutterBluePlus.adapterState
        .where((state) => state == BluetoothAdapterState.on)
        .first
        .timeout(const Duration(seconds: 10));

    // Scanner les appareils
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        // Chercher un appareil avec notre service
        if (result.advertisementData.serviceUuids.contains(Guid(serviceUuid))) {
          _connectToDevice(result.device);
          FlutterBluePlus.stopScan();
          break;
        }
      }
    });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      _connectedDevice = device;
      _deviceName = device.platformName;

      // Découvrir les services
      List<BluetoothService> services = await device.discoverServices();

      for (BluetoothService service in services) {
        if (service.uuid == Guid(serviceUuid)) {
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            if (characteristic.uuid == Guid(characteristicUuid)) {
              _characteristic = characteristic;
              await characteristic.setNotifyValue(true);
              _characteristicSubscription = characteristic.onValueReceived.listen(_handleData);
              break;
            }
          }
        }
      }
    } catch (e) {
      throw Exception('Erreur de connexion Bluetooth: $e');
    }
  }

  void _handleData(List<int> data) {
    try {
      final message = utf8.decode(data);
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
        case 'new_game_vote':
          onNewGameVote?.call(json['data'] as String);
          break;
      }
    } catch (_) {
      // Ignorer les erreurs de parsing
    }
  }

  Future<void> _sendMessage(Map<String, dynamic> message) async {
    if (_characteristic == null) return;

    final data = utf8.encode(jsonEncode(message));
    await _characteristic!.write(data);
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
    _scanSubscription?.cancel();
    _characteristicSubscription?.cancel();
    _connectedDevice?.disconnect();
    _connectedDevice = null;
    _characteristic = null;
  }
}
