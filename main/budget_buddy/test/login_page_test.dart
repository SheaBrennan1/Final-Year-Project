import 'package:budget_buddy/features/user_auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginPage Tests', () {
    testWidgets('Email and password text fields update on input',
        (WidgetTester tester) async {
      // Create the widget by telling the tester to build it.
      await tester.pumpWidget(MaterialApp(home: LoginPage()));

      // Enter 'email' into the first text field.
      await tester.enterText(
          find.byType(TextFormField).at(0), 'test@example.com');
      await tester.pump();

      // Enter 'password' into the second text field.
      await tester.enterText(find.byType(TextFormField).at(1), 'password');
      await tester.pump();

      // Verify that the text fields contain the entered text.
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password'), findsOneWidget);
    });

    testWidgets('Pressing login button does not throw any exceptions',
        (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(MaterialApp(home: LoginPage()));

      // Enter some text into the text fields.
      await tester.enterText(
          find.byType(TextFormField).at(0), 'user@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password');
      await tester.pump();

      // Try tapping the login button and check if any exceptions occur.
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Here you could add additional checks to see if a new page is opened,
      // or check for the existence of a Snackbar if login fails, etc.
      // For now, we simply check that no exceptions were thrown.
      expect(tester.takeException(), isNull);
    });
  });
}
