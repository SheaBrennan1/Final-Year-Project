import 'package:budget_buddy/features/user_auth/presentation/pages/login_page.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('LoginPage Tests', () {
    late MockFirebaseAuth mockAuth;

    setUp(() {
      mockAuth = MockFirebaseAuth();
    });

    testWidgets('Email and password text fields update on input',
        (WidgetTester tester) async {
      // Build our app and trigger a frame.
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

    testWidgets('Pressing login button triggers authentication',
        (WidgetTester tester) async {
      // Assuming signInWithEmailAndPassword is being called in your signIn function.
      when(mockAuth.signInWithEmailAndPassword(
              email: anyNamed('email'), password: anyNamed('password')))
          .thenAnswer((_) async => MockUserCredential());

      // Build our app and trigger a frame.
      await tester.pumpWidget(MaterialApp(home: LoginPage()));

      // Enter some text into the text fields.
      await tester.enterText(
          find.byType(TextFormField).at(0), 'user@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password');
      await tester.pump();

      // Tap on the login button.
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Verify that signInWithEmailAndPassword was called.
      verify(mockAuth.signInWithEmailAndPassword(
              email: 'user@example.com', password: 'password'))
          .called(1);
    });

    // Add more tests for different scenarios like handling errors, etc.
  });
}
