import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/game.dart';
import '../models/player.dart';
import '../models/word.dart';
import '../utils/constants.dart';
import '../utils/platform_utils.dart';
import 'dictionary_service.dart';
import 'game_logic_service.dart';
import 'connection/connection_interface.dart';
import 'connection/internet_connection.dart';
import 'connection/bluetooth_connection.dart';
import 'connection/bluetooth_connection_stub.dart';
import 'connection/wifi_direct_connection.dart';
import 'connection/wifi_direct_connection_stub.dart';

class GameProvider extends ChangeNotifier {
  Game? _game;
  Player? _currentPlayer;
  ConnectionInterface? _connection;
  Timer? _gameTimer;
  final GameLogicService _gameLogic = GameLogicService();
  final DictionaryService _dictionary = DictionaryService();

  Game? get game => _game;
  Player? get currentPlayer => _currentPlayer;
  String? get currentPlayerId => _currentPlayer?.id;
  String? get connectionInfo => _connection?.connectionInfo;
  bool get isHost => _currentPlayer?.isHost ?? false;

  Future<void> loadDictionary() async {
    await _dictionary.loadDictionary();
  }

  Future<void> initConnection({
    required ConnectionType connectionType,
    required String playerName,
    required bool isHost,
    String? hostAddress,
  }) async {
    final playerId = const Uuid().v4();

    _currentPlayer = Player(
      id: playerId,
      name: playerName,
      isHost: isHost,
    );

    switch (connectionType) {
      case ConnectionType.internet:
        _connection = InternetConnection();
        break;
      case ConnectionType.bluetooth:
        _connection = PlatformUtils.isBluetoothSupported
            ? BluetoothConnection()
            : BluetoothConnectionStub();
        break;
      case ConnectionType.wifiDirect:
        _connection = PlatformUtils.isWifiDirectSupported
            ? WifiDirectConnection()
            : WifiDirectConnectionStub();
        break;
    }

    _connection!.onGameUpdate = _handleGameUpdate;
    _connection!.onPlayerJoined = _handlePlayerJoined;
    _connection!.onPlayerLeft = _handlePlayerLeft;
    _connection!.onGameStart = _handleGameStart;
    _connection!.onGameEnd = _handleGameEnd;
    _connection!.onNewGameVote = _handleNewGameVote;

    if (isHost) {
      _game = Game(id: const Uuid().v4());
      _game!.addPlayer(_currentPlayer!);
      await _connection!.hostGame(_game!);
    } else {
      await _connection!.joinGame(hostAddress ?? '', _currentPlayer!);
    }

    notifyListeners();
  }

  void _handleGameUpdate(Game updatedGame) {
    _game = updatedGame;
    notifyListeners();
  }

  void _handlePlayerJoined(Player player) {
    _game?.addPlayer(player);
    _connection?.broadcastGameState(_game!);
    notifyListeners();
  }

  void _handlePlayerLeft(String playerId) {
    _game?.removePlayer(playerId);
    _connection?.broadcastGameState(_game!);
    notifyListeners();
  }

  void _handleGameStart() {
    _game?.startGame();
    _startTimer();
    notifyListeners();
  }

  void _handleGameEnd() {
    _gameTimer?.cancel();
    _game?.endGame();
    notifyListeners();
  }

  void _handleNewGameVote(String playerId) {
    final player = _game?.getPlayer(playerId);
    if (player != null) {
      player.votedForNewGame = true;
      if (_game!.allPlayersVotedForNewGame()) {
        _startNewGame();
      }
      notifyListeners();
    }
  }

  void startGame() {
    if (_game == null || !isHost) return;

    _game!.startGame();
    _connection?.broadcastGameStart();
    _startTimer();
    notifyListeners();
  }

  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_game == null) {
        timer.cancel();
        return;
      }

      _game!.remainingSeconds--;

      if (_game!.remainingSeconds <= 0) {
        timer.cancel();
        endGame();
      }

      notifyListeners();
    });
  }

  void endGame() {
    _gameTimer?.cancel();
    _game?.endGame();
    _connection?.broadcastGameEnd();
    notifyListeners();
  }

  ValidationResult submitWord(String word) {
    if (_game == null || _currentPlayer == null) {
      return ValidationResult(isValid: false, error: 'Partie non initialisée');
    }

    final result = _gameLogic.validateWord(
      _game!.grid,
      word,
      _currentPlayer!.foundWords,
    );

    if (result.isValid) {
      final wordObj = Word(
        text: word.toUpperCase(),
        playerId: _currentPlayer!.id,
        path: result.path ?? [],
      );

      _currentPlayer!.addWord(word.toUpperCase());
      _game!.allWords.add(wordObj);
      _connection?.sendWord(wordObj);
      notifyListeners();
    }

    return result;
  }

  void voteForNewGame() {
    if (_currentPlayer == null) return;

    _currentPlayer!.votedForNewGame = true;
    _connection?.sendNewGameVote(_currentPlayer!.id);

    if (_game!.allPlayersVotedForNewGame()) {
      _startNewGame();
    }

    notifyListeners();
  }

  void _startNewGame() {
    _game?.resetForNewGame();
    _connection?.broadcastGameState(_game!);
    startGame();
  }

  /// Mode test - Démarre une partie solo sans connexion (debug uniquement)
  void startTestGame(String playerName) {
    final playerId = const Uuid().v4();

    _currentPlayer = Player(
      id: playerId,
      name: playerName,
      isHost: true,
    );

    _game = Game(id: const Uuid().v4());
    _game!.addPlayer(_currentPlayer!);
    _game!.startGame();
    _startTimer();
    notifyListeners();
  }

  /// Mode test - Vérifie si on est en mode test (pas de connexion)
  bool get isTestMode => _connection == null && _game != null;

  /// Arrête la partie immédiatement (mode test uniquement)
  void stopTestGame() {
    if (!isTestMode) return;
    endGame();
  }

  int getCurrentScore() {
    if (_currentPlayer == null || _game == null) return 0;

    int score = 0;
    for (var word in _game!.allWords.where((w) => w.playerId == _currentPlayer!.id)) {
      score += word.points;
    }
    return score;
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _connection?.disconnect();
    super.dispose();
  }
}
