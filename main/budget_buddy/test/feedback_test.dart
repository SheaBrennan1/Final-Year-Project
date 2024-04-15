import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/feedback.dart';
import 'package:mockito/mockito.dart'; // Import your FeedbackPage

class MockUser extends Mock implements User {
  final String _uid;
  final String _email;
  final String _displayName;
  final bool _isAnonymous;

  MockUser({
    String uid = 'testuid',
    String email = 'test@example.com',
    String displayName = 'Test User',
    bool isAnonymous = false,
  })  : _uid = uid,
        _email = email,
        _displayName = displayName,
        _isAnonymous = isAnonymous;

  @override
  String get uid => _uid;

  @override
  String get email => _email;

  @override
  String get displayName => _displayName;

  @override
  bool get isAnonymous => _isAnonymous;
}

class MockFirebaseAuth extends Mock implements FirebaseAuth {
  final User user;

  MockFirebaseAuth({required this.user});

  @override
  User? get currentUser => user;
}

void main() {
  final mockUser = MockUser(
    isAnonymous: false,
    uid: 'testuid',
    email: 'test@example.com',
    displayName: 'Test User',
  );
  group('FeedbackPage Tests', () {
    testWidgets('FeedbackPage builds and displays its widgets properly',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: FeedbackPage()));

      // Check for the presence of certain widgets.
      expect(find.text('Feedback'), findsOneWidget);
      expect(find.text('Feedback Title:'), findsOneWidget);
      expect(find.text('Select Topic:'), findsOneWidget);
      expect(find.text('Details:'), findsOneWidget);
      expect(find.byType(TextField),
          findsNWidgets(2)); // Assuming there are two TextFields
      expect(find.byType(DropdownButton<String>), findsOneWidget);
      expect(find.text('Submit Feedback'), findsOneWidget); // Button text
    });
  });

  testWidgets('Can select a topic from the Dropdown and enter text',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: FeedbackPage()));

    // Interact with the dropdown
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle(); // Finish the menu animation
    await tester.tap(find.text('Bug Report').last);
    await tester.pumpAndSettle(); // Finish the dropdown animation

    // Enter text in the title TextField
    await tester.enterText(
        find.widgetWithText(TextField, 'Enter your feedback title...'),
        'New Feature Request');

    // Enter text in the details TextField
    await tester.enterText(
        find.widgetWithText(TextField, 'Write your details here...'),
        'Please add dark mode.');

    // Assert that the selected dropdown item changed
    expect(find.text('Bug Report'), findsOneWidget);

    // Assert text has been entered into the TextField
    expect(find.text('New Feature Request'), findsOneWidget);
    expect(find.text('Please add dark mode.'), findsOneWidget);
  });
}
