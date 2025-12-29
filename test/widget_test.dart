import 'package:flutter_test/flutter_test.dart';
import 'package:froggle_game/main.dart';
import 'package:froggle_game/services/settings_service.dart';

void main() {
  testWidgets('App launches correctly', (WidgetTester tester) async {
    final settings = SettingsService();
    await tester.pumpWidget(FroggleApp(settings: settings));
    expect(find.text('FROGGLE'), findsOneWidget);
  });
}
