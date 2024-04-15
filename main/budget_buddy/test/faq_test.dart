import 'package:budget_buddy/faq.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FAQScreen Tests', () {
    testWidgets('FAQScreen builds correctly', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: FAQScreen()));

      expect(find.text('FAQ'), findsOneWidget);
    });

    testWidgets('All FAQ entries are present', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: FAQScreen()));

      final questions = [
        "How to use the budget feature?",
        "How to track expenses?",
        "How to set financial goals?",
        "What is the 50/30/20 budget rule?",
        "How can I edit or delete an expense?",
        "How do I view my spending over different time periods?",
      ];

      for (var question in questions) {
        expect(find.text(question), findsOneWidget);
      }
    });
  });
}
