import 'package:flutter_test/flutter_test.dart';

import 'package:freightapp/main.dart';

void main() {
  testWidgets('App should build successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FreightMatchApp());

    // Verify that the splash screen shows "FreightMatch"
    expect(find.text('FreightMatch'), findsOneWidget);
  });
}
