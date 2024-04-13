import 'package:budget_buddy/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Home Widget Tests', () {
    testWidgets('Should display the correct initial UI elements',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: Home()));

      // Verify that certain widgets are found in the tree.
      expect(find.text('Total Balance'), findsOneWidget);
      expect(find.byType(ToggleButtons), findsOneWidget);
      // Add more checks as needed
    });
  });
}
