import '../../models/game.dart';
import '../../models/player.dart';
import '../../models/word.dart';

abstract class ConnectionInterface {
  String? get connectionInfo;

  Function(Game)? onGameUpdate;
  Function(Player)? onPlayerJoined;
  Function(String)? onPlayerLeft;
  Function()? onGameStart;
  Function()? onGameEnd;
  Function(String)? onNewGameVote;
  Function(Word)? onWordReceived;

  Future<void> hostGame(Game game);
  Future<void> joinGame(String address, Player player);
  void broadcastGameState(Game game);
  void broadcastGameStart();
  void broadcastGameEnd();
  void sendWord(Word word);
  void sendNewGameVote(String playerId);
  void disconnect();
}
