import '../../services/connection/bluetooth_connection_stub.dart';
import '../../services/connection/connection_interface.dart';
import '../../services/connection/internet_connection.dart';
import '../../services/connection/wifi_direct_connection.dart';
import '../../services/connection/wifi_direct_connection_stub.dart';
import '../../utils/constants.dart';
import '../../utils/platform_utils.dart';

/// Factory pour créer les connexions selon le type demandé.
///
/// Gère automatiquement les stubs pour les plateformes non supportées.
class ConnectionFactory {
  static ConnectionInterface create(ConnectionType type) {
    switch (type) {
      case ConnectionType.internet:
        return InternetConnection();
      case ConnectionType.bluetooth:
        return BluetoothConnectionStub();
      case ConnectionType.wifiDirect:
        return PlatformUtils.isWifiDirectSupported
            ? WifiDirectConnection()
            : WifiDirectConnectionStub();
    }
  }
}
