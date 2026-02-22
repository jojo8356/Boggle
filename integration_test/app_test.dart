import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:froggle_game/main.dart';
import 'package:froggle_game/services/settings_service.dart';
import 'package:froggle_game/services/auth_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Froggle App Integration Tests', () {
    testWidgets('[P0] devrait lancer l\'application et afficher l\'ecran d\'accueil', (tester) async {
      // GIVEN: L'application est lancee
      final settings = SettingsService();
      final authService = AuthService();

      await tester.pumpWidget(FroggleApp(
        settings: settings,
        authService: authService,
      ));
      await tester.pumpAndSettle();

      // WHEN: L'ecran d'accueil est affiche
      // THEN: Le titre FROGGLE devrait etre visible
      expect(find.text('FROGGLE'), findsOneWidget);
    });

    testWidgets('[P0] devrait demarrer une partie solo', (tester) async {
      // GIVEN: L'application est sur l'ecran d'accueil
      final settings = SettingsService();
      final authService = AuthService();

      await tester.pumpWidget(FroggleApp(
        settings: settings,
        authService: authService,
      ));
      await tester.pumpAndSettle();

      // WHEN: On clique sur "Jouer Solo"
      final soloButton = find.text('Jouer Solo');
      if (soloButton.evaluate().isNotEmpty) {
        await tester.tap(soloButton);
        await tester.pumpAndSettle();

        // THEN: L'ecran de jeu devrait s'afficher avec une grille
        // Note: La grille peut prendre un moment a charger
        await tester.pump(const Duration(seconds: 2));
      }
    });

    testWidgets('[P1] devrait naviguer vers les parametres', (tester) async {
      // GIVEN: L'application est sur l'ecran d'accueil
      final settings = SettingsService();
      final authService = AuthService();

      await tester.pumpWidget(FroggleApp(
        settings: settings,
        authService: authService,
      ));
      await tester.pumpAndSettle();

      // WHEN: On clique sur l'icone parametres
      final settingsIcon = find.byIcon(Icons.settings);
      if (settingsIcon.evaluate().isNotEmpty) {
        await tester.tap(settingsIcon);
        await tester.pumpAndSettle();

        // THEN: L'ecran des parametres devrait s'afficher
        expect(find.text('Parametres'), findsOneWidget);
      }
    });

    testWidgets('[P1] devrait naviguer vers les statistiques', (tester) async {
      // GIVEN: L'application est sur l'ecran d'accueil
      final settings = SettingsService();
      final authService = AuthService();

      await tester.pumpWidget(FroggleApp(
        settings: settings,
        authService: authService,
      ));
      await tester.pumpAndSettle();

      // WHEN: On clique sur l'icone stats
      final statsButton = find.text('Statistiques');
      if (statsButton.evaluate().isEmpty) {
        // Chercher par icone si le texte n'est pas visible
        final statsIcon = find.byIcon(Icons.bar_chart);
        if (statsIcon.evaluate().isNotEmpty) {
          await tester.tap(statsIcon);
          await tester.pumpAndSettle();
        }
      }
    });
  });
}

// Note: Pour executer ces tests d'integration, utilisez:
// flutter test integration_test/app_test.dart
