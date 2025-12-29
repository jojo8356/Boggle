import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_provider.dart';
import '../services/settings_service.dart';
import '../utils/constants.dart';
import '../utils/platform_utils.dart';
import 'lobby_screen.dart';
import 'game_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showConnectionDialog(ConnectionType type) {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer votre nom')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _ConnectionDialog(
        connectionType: type,
        playerName: _nameController.text.trim(),
        onConnect: (isHost, hostAddress) {
          Navigator.pop(context);
          _navigateToLobby(type, isHost, hostAddress);
        },
      ),
    );
  }

  void _navigateToLobby(ConnectionType type, bool isHost, String? hostAddress) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LobbyScreen(
          connectionType: type,
          playerName: _nameController.text.trim(),
          isHost: isHost,
          hostAddress: hostAddress,
        ),
      ),
    );
  }

  void _startTestGame() {
    final playerName = _nameController.text.trim();
    if (playerName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer votre nom')),
      );
      return;
    }

    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final settings = Provider.of<SettingsService>(context, listen: false);
    gameProvider.startTestGame(playerName, gameDuration: settings.gameDuration);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GameScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[400]!, Colors.purple[400]!],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Bouton paramètres en haut à droite
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  },
                  icon: const Icon(Icons.settings, color: Colors.white, size: 28),
                ),
              ),
              // Contenu principal
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'FROGGLE',
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(2, 2),
                            blurRadius: 4,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '16 lettres • ${settings.formatDuration(settings.gameDuration)}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 48),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Votre nom',
                        prefixIcon: const Icon(Icons.person),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Choisir le mode de connexion',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ConnectionButton(
                      icon: Icons.wifi,
                      label: 'Internet',
                      description: 'Jouer en ligne',
                      color: Colors.green,
                      onTap: () => _showConnectionDialog(ConnectionType.internet),
                    ),
                    // Bluetooth - uniquement sur mobile
                    if (PlatformUtils.isBluetoothSupported) ...[
                      const SizedBox(height: 12),
                      _ConnectionButton(
                        icon: Icons.bluetooth,
                        label: 'Bluetooth',
                        description: 'Jouer à proximité',
                        color: Colors.blue,
                        onTap: () => _showConnectionDialog(ConnectionType.bluetooth),
                      ),
                    ],
                    // WiFi Direct - uniquement sur mobile
                    if (PlatformUtils.isWifiDirectSupported) ...[
                      const SizedBox(height: 12),
                      _ConnectionButton(
                        icon: Icons.wifi_tethering,
                        label: 'WiFi Direct',
                        description: 'Sans routeur WiFi',
                        color: Colors.orange,
                        onTap: () => _showConnectionDialog(ConnectionType.wifiDirect),
                      ),
                    ],
                    // Mode solo
                    const SizedBox(height: 12),
                    _ConnectionButton(
                      icon: Icons.person,
                      label: 'Solo',
                      description: 'Jouer seul',
                      color: Colors.purple,
                      onTap: _startTestGame,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConnectionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _ConnectionButton({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConnectionDialog extends StatefulWidget {
  final ConnectionType connectionType;
  final String playerName;
  final Function(bool isHost, String? hostAddress) onConnect;

  const _ConnectionDialog({
    required this.connectionType,
    required this.playerName,
    required this.onConnect,
  });

  @override
  State<_ConnectionDialog> createState() => _ConnectionDialogState();
}

class _ConnectionDialogState extends State<_ConnectionDialog> {
  final TextEditingController _addressController = TextEditingController();
  bool _isHost = true;

  String get _connectionName {
    switch (widget.connectionType) {
      case ConnectionType.internet:
        return 'Internet';
      case ConnectionType.bluetooth:
        return 'Bluetooth';
      case ConnectionType.wifiDirect:
        return 'WiFi Direct';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Connexion $_connectionName'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioGroup<bool>(
            groupValue: _isHost,
            onChanged: (value) => setState(() => _isHost = value ?? true),
            child: Column(
              children: [
                ListTile(
                  title: const Text('Créer une partie'),
                  leading: Radio<bool>(value: true),
                  onTap: () => setState(() => _isHost = true),
                ),
                ListTile(
                  title: const Text('Rejoindre une partie'),
                  leading: Radio<bool>(value: false),
                  onTap: () => setState(() => _isHost = false),
                ),
              ],
            ),
          ),
          if (!_isHost && widget.connectionType == ConnectionType.internet)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Adresse IP du host',
                  hintText: '192.168.1.100',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onConnect(
              _isHost,
              _isHost ? null : _addressController.text.trim(),
            );
          },
          child: Text(_isHost ? 'Créer' : 'Rejoindre'),
        ),
      ],
    );
  }
}
