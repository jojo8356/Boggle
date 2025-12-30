import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/game_provider.dart';
import 'services/dictionary_service.dart';
import 'services/settings_service.dart';
import 'services/auth_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Charger le dictionnaire au démarrage
  final dictionary = DictionaryService();
  await dictionary.loadDictionary();

  // Charger les paramètres
  final settings = SettingsService();
  await settings.loadSettings();

  // Charger l'authentification
  final authService = AuthService();
  await authService.init();

  runApp(FroggleApp(settings: settings, authService: authService));
}

class FroggleApp extends StatelessWidget {
  final SettingsService settings;
  final AuthService authService;

  const FroggleApp({super.key, required this.settings, required this.authService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GameProvider()),
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: authService),
      ],
      child: MaterialApp(
        title: 'Froggle',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
