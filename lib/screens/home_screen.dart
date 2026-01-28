import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart' as bt;
import '../services/game_provider.dart';
import '../services/settings_service.dart';
import '../services/auth_service.dart';
import '../services/connection/bluetooth_connection.dart';
import '../utils/constants.dart';
import 'lobby_screen.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'auth_screen.dart';
import 'stats_screen.dart';

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

  void _showAccountMenu(BuildContext context, AuthService authService) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.account_circle, size: 40),
              title: Text(
                authService.currentUser?.username ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: const Text('Connecté'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Statistiques'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StatsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Se déconnecter', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await authService.logout();
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBluetoothDialog() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer votre nom')),
      );
      return;
    }

    // Vérifier si Bluetooth est activé
    final isEnabled = await BluetoothConnection.isBluetoothEnabled();
    if (!isEnabled) {
      final enabled = await BluetoothConnection.requestEnable();
      if (enabled != true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bluetooth doit être activé')),
          );
        }
        return;
      }
    }

    // Récupérer les appareils appairés
    final devices = await BluetoothConnection.getPairedDevices();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => _BluetoothDeviceDialog(
        devices: devices,
        playerName: _nameController.text.trim(),
        onDeviceSelected: (device) {
          Navigator.pop(context);
          _navigateToLobby(ConnectionType.bluetooth, false, device.address);
        },
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
              // Boutons en haut à droite
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    // Bouton compte/stats
                    Consumer<AuthService>(
                      builder: (context, authService, _) {
                        if (authService.isLoggedIn) {
                          return Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const StatsScreen()),
                                  );
                                },
                                icon: const Icon(Icons.bar_chart, color: Colors.white, size: 28),
                                tooltip: 'Statistiques',
                              ),
                              IconButton(
                                onPressed: () => _showAccountMenu(context, authService),
                                icon: const Icon(Icons.account_circle, color: Colors.white, size: 28),
                                tooltip: authService.currentUser?.username ?? 'Compte',
                              ),
                            ],
                          );
                        }
                        return IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AuthScreen()),
                            );
                          },
                          icon: const Icon(Icons.login, color: Colors.white, size: 28),
                          tooltip: 'Se connecter',
                        );
                      },
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SettingsScreen()),
                        );
                      },
                      icon: const Icon(Icons.settings, color: Colors.white, size: 28),
                    ),
                  ],
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
                    const SizedBox(height: 12),
                    _ConnectionButton(
                      icon: Icons.bluetooth,
                      label: 'Bluetooth',
                      description: 'Jouer à proximité',
                      color: Colors.blue,
                      onTap: () => _showBluetoothDialog(),
                    ),
                    const SizedBox(height: 12),
                    _ShakeButton(
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
          ListTile(
            title: const Text('Créer une partie'),
            leading: Radio<bool>(
              value: true,
              groupValue: _isHost,
              onChanged: (value) => setState(() => _isHost = value ?? true),
            ),
            onTap: () => setState(() => _isHost = true),
          ),
          ListTile(
            title: const Text('Rejoindre une partie'),
            leading: Radio<bool>(
              value: false,
              groupValue: _isHost,
              onChanged: (value) => setState(() => _isHost = value ?? true),
            ),
            onTap: () => setState(() => _isHost = false),
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

class _BluetoothDeviceDialog extends StatelessWidget {
  final List<bt.BluetoothDevice> devices;
  final String playerName;
  final Function(bt.BluetoothDevice) onDeviceSelected;

  const _BluetoothDeviceDialog({
    required this.devices,
    required this.playerName,
    required this.onDeviceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Appareils Bluetooth'),
      content: SizedBox(
        width: double.maxFinite,
        child: devices.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Aucun appareil appairé trouvé.\n\nAppairez d\'abord votre appareil dans les paramètres Bluetooth.',
                  textAlign: TextAlign.center,
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
                  return ListTile(
                    leading: const Icon(Icons.bluetooth),
                    title: Text(device.name ?? 'Appareil inconnu'),
                    subtitle: Text(device.address),
                    onTap: () => onDeviceSelected(device),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
      ],
    );
  }
}

class _ShakeButton extends StatefulWidget {
  final VoidCallback onTap;

  const _ShakeButton({required this.onTap});

  @override
  State<_ShakeButton> createState() => _ShakeButtonState();
}

class _ShakeButtonState extends State<_ShakeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  bool _isShaking = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onPressed() async {
    if (_isShaking) return;

    setState(() {
      _isShaking = true;
    });

    // Vibration pattern
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.heavyImpact();

    // Shake animation
    await _shakeController.forward();
    _shakeController.reset();

    setState(() {
      _isShaking = false;
    });

    // Start game
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        final shake = _isShaking
            ? ((_shakeAnimation.value * 10) - 5) *
              (1 - _shakeAnimation.value) * 2
            : 0.0;
        return Transform.translate(
          offset: Offset(shake, 0),
          child: child,
        );
      },
      child: Material(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(16),
        elevation: 8,
        shadowColor: Colors.orange.withValues(alpha: 0.5),
        child: InkWell(
          onTap: _onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.casino,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Secouer !',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Jouer seul - Mélanger les dés',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
