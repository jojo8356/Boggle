import 'package:get_it/get_it.dart';

import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../services/dictionary_service.dart';
import '../../services/game_logic_service.dart';
import '../../services/settings_service.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Services singletons
  getIt.registerLazySingleton<DictionaryService>(() => DictionaryService());
  getIt.registerLazySingleton<SettingsService>(() => SettingsService());
  getIt.registerLazySingleton<DatabaseService>(() => DatabaseService.instance);
  getIt.registerLazySingleton<AuthService>(() => AuthService());

  // Services factories (nouvelle instance à chaque appel)
  getIt.registerFactory<GameLogicService>(() => GameLogicService());
}
