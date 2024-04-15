import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

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

  final mockAuth = MockFirebaseAuth(user: mockUser);

  // Use `mockAuth` in your tests as needed.
  // Example:
  test('Test for current user', () {
    expect(mockAuth.currentUser, isNotNull);
    expect(mockAuth.currentUser!.displayName, equals('Test User'));
  });
}
