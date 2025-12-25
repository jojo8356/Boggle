import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/game_provider.dart';
import 'services/dictionary_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Charger le dictionnaire au démarrage
  final dictionary = DictionaryService();
  await dictionary.loadDictionary();

  runApp(const BoggleApp());
}

class BoggleApp extends StatelessWidget {
  const BoggleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameProvider(),
      child: MaterialApp(
        title: 'Boggle',
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
