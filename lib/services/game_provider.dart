import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../core/di/connection_factory.dart';
import '../models/game.dart';
import '../models/player.dart';
import '../models/word.dart';
import '../utils/constants.dart';
import 'connection/connection_interface.dart';
import 'dictionary_service.dart';
import 'game_logic_service.dart';
import 'score_service.dart';
import 'timer_service.dart';

class GameProvider extends ChangeNotifier {
  Game? _game;
  Player? _currentPlayer;
  ConnectionInterface? _connection;
  TimerService? _timerService;
  final GameLogicService _gameLogic = GameLogicService();
  final DictionaryService _dictionary = DictionaryService();
  final ScoreService _scoreService = ScoreService();

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

    _currentPlayer = Player(id: playerId, name: playerName, isHost: isHost);

    _connection = ConnectionFactory.create(connectionType);

    _connection!.onGameUpdate = _handleGameUpdate;
    _connection!.onPlayerJoined = _handlePlayerJoined;
    _connection!.onPlayerLeft = _handlePlayerLeft;
    _connection!.onGameStart = _handleGameStart;
    _connection!.onGameEnd = _handleGameEnd;
    _connection!.onNewGameVote = _handleNewGameVote;
    _connection!.onWordReceived = _handleWordReceived;

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
    _timerService?.stop();
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

  void _handleWordReceived(Word word) {
    if (_game == null) return;

    // Ajouter le mot à la liste des mots du jeu s'il n'existe pas déjà
    final alreadyExists = _game!.allWords.any(
      (w) => w.text == word.text && w.playerId == word.playerId,
    );

    if (!alreadyExists) {
      _game!.allWords.add(word);
      notifyListeners();
    }
  }

  void startGame() {
    if (_game == null || !isHost) return;

    _game!.startGame();
    // Envoyer d'abord l'état complet du jeu (avec la grille) puis le signal de démarrage
    _connection?.broadcastGameState(_game!);
    _connection?.broadcastGameStart();
    _startTimer();
    notifyListeners();
  }

  void _startTimer() {
    _timerService?.dispose();
    _timerService = TimerService(
      initialDuration: _game!.remainingSeconds,
      onTick: (remainingSeconds) {
        if (_game != null) {
          _game!.remainingSeconds = remainingSeconds;
          notifyListeners();
        }
      },
      onTimeUp: () {
        endGame();
      },
    );
    _timerService!.start();
  }

  void endGame() {
    _timerService?.stop();

    // En mode multijoueur, valider les mots contre le dictionnaire maintenant
    if (!isTestMode && _game != null) {
      _validateWordsAgainstDictionary();
    }

    _game?.endGame();
    _connection?.broadcastGameEnd();
    notifyListeners();
  }

  /// Valide tous les mots contre le dictionnaire (appelé à la fin en multijoueur)
  void _validateWordsAgainstDictionary() {
    if (_game == null) return;

    for (var word in _game!.allWords) {
      if (!_gameLogic.isValidWord(word.text)) {
        word.isInvalid = true;
      }
    }
  }

  ValidationResult submitWord(String word, {List<int>? path}) {
    if (_game == null || _currentPlayer == null) {
      return ValidationResult(isValid: false, error: 'Partie non initialisée');
    }

    // En mode multijoueur, on ne vérifie pas le dictionnaire immédiatement
    // La validation se fera à la fin de la partie
    final isMultiplayer = !isTestMode;

    final result = _gameLogic.validateWord(
      _game!.grid,
      word,
      _currentPlayer!.foundWords,
      providedPath: path,
      skipDictionaryCheck: isMultiplayer,
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

  void replaySameGrid() {
    _game?.resetWithSameGrid();
    _connection?.broadcastGameState(_game!);
    startGame();
  }

  /// Mode test - Démarre une partie solo sans connexion (debug uniquement)
  void startTestGame(String playerName, {int? gameDuration}) {
    final playerId = const Uuid().v4();

    _currentPlayer = Player(id: playerId, name: playerName, isHost: true);

    _game = Game(
      id: const Uuid().v4(),
      remainingSeconds: gameDuration ?? GameConstants.gameDurationSeconds,
    );
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

  /// Termine la partie immédiatement (mode debug uniquement, fonctionne aussi en multijoueur)
  void forceEndGame() {
    if (!kDebugMode || _game == null) return;
    endGame();
  }

  int getCurrentScore() {
    if (_currentPlayer == null || _game == null) return 0;
    return _scoreService.calculatePlayerScore(
      _game!.allWords,
      _currentPlayer!.id,
    );
  }

  @override
  void dispose() {
    _timerService?.dispose();
    _connection?.disconnect();
    super.dispose();
  }
}
