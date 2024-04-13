import 'package:budget_buddy/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyCHnqK-G12Gv7EkOQnbq3TtMPWtsC04eSA",
        appId: "1:162550313227:android:d91dd69c9c8e3505aef20e",
        messagingSenderId: "162550313227",
        projectId: "budget-buddy-a49f1",
        databaseURL:
            "https://budget-buddy-a49f1-default-rtdb.europe-west1.firebasedatabase.app/",
        storageBucket: "budget-buddy-a49f1.appspot.com",
      ),
    );
  });

  testWidgets('Should display the correct initial UI elements',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Home()));

    // Ensure all async operations are completed
    await tester.pumpAndSettle();

    // Check for the presence of certain widgets.
    expect(find.text('Total Balance'), findsOneWidget);
  });
}
