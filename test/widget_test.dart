import 'package:flutter_test/flutter_test.dart';
import 'package:boggle_game/main.dart';

void main() {
  testWidgets('App launches correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const BoggleApp());
    expect(find.text('BOGGLE'), findsOneWidget);
  });
}
