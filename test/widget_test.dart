import 'package:flutter_test/flutter_test.dart';
import 'package:froggle_game/main.dart';
import 'package:froggle_game/services/settings_service.dart';
import 'package:froggle_game/services/auth_service.dart';

void main() {
  testWidgets('App launches correctly', (WidgetTester tester) async {
    final settings = SettingsService();
    final authService = AuthService();
    await tester.pumpWidget(FroggleApp(settings: settings, authService: authService));
    expect(find.text('FROGGLE'), findsOneWidget);
  });
}
