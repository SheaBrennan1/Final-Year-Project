import 'package:budget_buddy/features/user_auth/presentation/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  group('LoginPage Tests', () {
    late MockFirebaseAuth mockAuth;

    setUp(() {
      mockAuth = MockFirebaseAuth();
    });

    testWidgets('Email and password text fields update on input',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: LoginPage()));
      await tester.enterText(
          find.byType(TextFormField).at(0), 'test@example.com');
      await tester.pump();
      await tester.enterText(find.byType(TextFormField).at(1), 'password');
      await tester.pump();

      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password'), findsOneWidget);
    });

    testWidgets('Pressing login button triggers authentication',
        (WidgetTester tester) async {
      when(mockAuth.signInWithEmailAndPassword(
              email: any<String>(named: 'email'),
              password: any<String>(named: 'password')))
          .thenAnswer((_) async => MockUserCredential());

      await tester.pumpWidget(MaterialApp(home: LoginPage()));
      await tester.enterText(
          find.byType(TextFormField).at(0), 'user@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password');
      await tester.pump();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      verify(mockAuth.signInWithEmailAndPassword(
              email: any<String>(named: 'email'),
              password: any<String>(named: 'password')))
          .called(1);
    });
  });
}
