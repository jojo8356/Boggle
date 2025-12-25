class GameConstants {
  static const int gameDurationSeconds = 180; // 3 minutes
  static const int gridSize = 3;
  static const int maxPlayers = 6;
  static const int minWordLength = 3;

  static int getPoints(int wordLength) {
    if (wordLength <= 2) return 0;
    if (wordLength <= 4) return 1;
    if (wordLength == 5) return 2;
    if (wordLength == 6) return 3;
    if (wordLength == 7) return 5;
    return 11; // 8+ lettres
  }
}

enum ConnectionType { internet, bluetooth, wifiDirect }

enum GameState { waiting, playing, finished }

enum PlayerState { connected, ready, playing, disconnected }
