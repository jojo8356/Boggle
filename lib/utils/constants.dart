import '../config/game_config.dart';

class GameConstants {
  static const int gameDurationSeconds = GameConfig.gameDurationSeconds;
  static const int gridSize = GameConfig.gridSize;
  static const int maxPlayers = GameConfig.maxPlayers;
  static const int minWordLength = GameConfig.minWordLength;

  static int getPoints(int wordLength) => GameConfig.getPoints(wordLength);
}

enum ConnectionType { internet, bluetooth, wifiDirect }

enum GameState { waiting, playing, finished }

enum PlayerState { connected, ready, playing, disconnected }
