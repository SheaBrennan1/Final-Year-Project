import 'package:budget_buddy/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/add.dart';
import 'package:mockito/mockito.dart'; // Update this import according to your project structure

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

  group('Add_Screen Tests', () {
    // Test to ensure the widget builds
    testWidgets('Add_Screen should build without crashing',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(MaterialApp(home: Add_Screen()));

      // Assert
      expect(find.byType(Add_Screen), findsOneWidget);
    });

    // Test to check if UI elements are present
    testWidgets(
        'Important UI Elements should be present when adding new expense',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(MaterialApp(home: Add_Screen()));

      // Assert
      expect(find.text('Add Expense'), findsOneWidget); // App bar title
      expect(find.text('Save Expense'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget); // Add button
      expect(find.byType(TextFormField), findsWidgets); // Input fields
    });
  });
}
