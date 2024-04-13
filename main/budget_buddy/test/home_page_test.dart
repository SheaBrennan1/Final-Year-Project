import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/home.dart';

void main() {
  testWidgets('Home Widget Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(home: Home()));

    // Verify that the Home widget creates the expected initial widgets.
    expect(find.text('Total Income'), findsOneWidget);
    expect(find.text('Total Expenses'), findsOneWidget);

    // You can also tap buttons and interact with the widget:
    // await tester.tap(find.byIcon(Icons.add));
    // await tester.pump();  // Rebuild the widget after the state has changed.
  });
}
