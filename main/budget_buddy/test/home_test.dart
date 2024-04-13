import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../lib/home.dart';  // Adjust the path as necessary

// Create mock classes
class MockFirebaseDatabase extends Mock implements FirebaseDatabase {}
class MockDatabaseReference extends Mock implements DatabaseReference {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}

void main() {
  // Setup Firebase
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  });

  // Create mock instances
  final mockFirebaseDatabase = MockFirebaseDatabase();
  final mockDatabaseReference = MockDatabaseReference();
  final mockFirebaseAuth = MockFirebaseAuth();
  final mockUser = MockUser();

  // Setup mock returns
  setUp(() {
    when(mockFirebaseDatabase.ref()).thenReturn(mockDatabaseReference);
    when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('testuid');
    // Correct usage of any with type specification
    when(mockDatabaseReference.child(any<String>())).thenReturn(mockDatabaseReference);
  });

  // Home widget tests
  group('Home Widget Tests', () {
    testWidgets('Home initializes and displays total balance', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: Home()));

      // Verify initial state
      expect(find.text('£0.00'), findsWidgets);
      expect(find.byType(ToggleButtons), findsOneWidget);
    });

    testWidgets('Toggle view mode', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: Home()));
      final toggleButtons = find.byType(ToggleButtons);
      await tester.tap(toggleButtons);
      await tester.pumpAndSettle();

      // Verify view mode toggle
      expect(find.text('Year'), findsWidgets);
    });

    // Additional tests for other functionalities
  });
}