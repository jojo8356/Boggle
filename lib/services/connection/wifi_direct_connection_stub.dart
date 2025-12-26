import '../../models/game.dart';
import '../../models/player.dart';
import '../../models/word.dart';
import 'connection_interface.dart';

/// Stub pour les plateformes qui ne supportent pas WiFi Direct (Linux, Web, etc.)
class WifiDirectConnectionStub implements ConnectionInterface {
  @override
  String? get connectionInfo => null;

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
    throw UnsupportedError('WiFi Direct non supporté sur cette plateforme');
  }

  @override
  Future<void> joinGame(String address, Player player) async {
    throw UnsupportedError('WiFi Direct non supporté sur cette plateforme');
  }

  @override
  void broadcastGameState(Game game) {}

  @override
  void broadcastGameStart() {}

  @override
  void broadcastGameEnd() {}

  @override
  void sendWord(Word word) {}

  @override
  void sendNewGameVote(String playerId) {}

  @override
  void disconnect() {}
}
