import 'package:budget_buddy/features/user_auth/presentation/pages/login_page.dart';
import 'package:budget_buddy/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/mockito.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockUser extends Mock implements UserCredential {}

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockFirebaseMessaging mockFirebaseMessaging;
  late MockFirebaseFirestore mockFirebaseFirestore;
  late MockGoogleSignIn mockGoogleSignIn;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirebaseMessaging = MockFirebaseMessaging();
    mockFirebaseFirestore = MockFirebaseFirestore();
    mockGoogleSignIn = MockGoogleSignIn();
  });

  Widget makeTestableWidget({required Widget child}) {
    return MaterialApp(
      home: child,
    );
  }

  group('LoginPage Tests', () {
    testWidgets('Email and password fields are present',
        (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(child: LoginPage()));
      expect(find.byType(TextFormField),
          findsNWidgets(2)); // Assuming there are exactly two TextFormFields
    });

    testWidgets('Login button calls signIn method',
        (WidgetTester tester) async {
      when(mockFirebaseAuth.signInWithEmailAndPassword(
              email: ('email'), password: ('password')))
          .thenAnswer((_) async => MockUser());
      await tester.pumpWidget(makeTestableWidget(child: LoginPage()));
      await tester.tap(find.text('Login'));
      await tester.pump();
      verify(mockFirebaseAuth.signInWithEmailAndPassword(
              email: ('email'), password: ('password')))
          .called(1);
    });

    testWidgets('Successful login navigates to home page',
        (WidgetTester tester) async {
      when(mockFirebaseAuth.signInWithEmailAndPassword(
              email: ('email'), password: ('password')))
          .thenAnswer((_) async => MockUser());
      await tester.pumpWidget(makeTestableWidget(child: LoginPage()));
      await tester.enterText(find.byType(TextFormField).first, 'test@test.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      expect(find.byType(Home), findsOneWidget);
    });
  });
}
