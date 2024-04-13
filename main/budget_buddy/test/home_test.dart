import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../lib/home.dart';  // Adjust the path as necessary

// Create mock classes
class MockFirebaseDatabase extends Mock implements FirebaseDatabase {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class FakeDatabaseReference extends Fake implements DatabaseReference {
  @override
  Stream<Event> onValue() {
    // Return a stream of fake data
    return Stream.fromIterable([
      Event(DataSnapshot(null, {
        'expenses': {
          '1': {'amount': 100, 'date': '2021-04-01', 'category': 'Food', 'type': 'Expense'}
        }
      }, DatabaseError.noError())),
    ]);
  }
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  });

  // Create mock instances
  final mockFirebaseDatabase = MockFirebaseDatabase();
  final mockFirebaseAuth = MockFirebaseAuth();
  final mockUser = MockUser();
  final fakeDatabaseReference = FakeDatabaseReference();

  // Setup mock returns
  setUp(() {
    when(mockFirebaseDatabase.ref()).thenReturn(fakeDatabaseReference);
    when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('testuid');
  });

  // Home widget tests
  group('Home Widget Tests', () {
    testWidgets('Home initializes and displays total balance', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: Home()));

      // Verify initial state shows mocked data
      await tester.pumpAndSettle();
      expect(find.text('£100.00'), findsOneWidget); // Assuming your UI shows this data somewhere
    });

    // Additional tests for other functionalities
  });
}
