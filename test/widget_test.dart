import 'package:flutter_test/flutter_test.dart';
import 'package:froggle_game/main.dart';

void main() {
  testWidgets('App launches correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const FroggleApp());
    expect(find.text('FROGGLE'), findsOneWidget);
  });
}
