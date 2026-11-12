import 'package:flutter_test/flutter_test.dart';

import 'package:aeronova_travel/main.dart';

void main() {
  testWidgets('AeroNova app renders the dashboard', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AeroNovaApp());

    expect(find.text('AeroNova Command Center'), findsOneWidget);
  });
}
