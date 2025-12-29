import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Utilitaires pour la détection de plateforme
class PlatformUtils {
  /// Retourne true si on est sur une plateforme mobile (Android/iOS)
  static bool get isMobile {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  /// Retourne true si on est sur une plateforme desktop (Linux/Windows/macOS)
  static bool get isDesktop {
    if (kIsWeb) return false;
    return Platform.isLinux || Platform.isWindows || Platform.isMacOS;
  }

  /// Retourne true si le Bluetooth est supporté
  /// flutter_blue_plus supporte Android, iOS, macOS et Linux
  static bool get isBluetoothSupported {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS || Platform.isMacOS || Platform.isLinux;
  }

  /// Retourne true si le WiFi Direct est supporté
  static bool get isWifiDirectSupported => isMobile;

  /// Retourne true si la connexion Internet est supportée
  static bool get isInternetSupported => true;
}
