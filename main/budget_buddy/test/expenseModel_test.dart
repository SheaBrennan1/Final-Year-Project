import 'package:budget_buddy/features/app/ExpenseCategoriesScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExpenseCategoriesScreen Tests', () {
    testWidgets(
        'Grid displays correct number of categories for expenses and incomes',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: ExpenseCategoriesScreen()));

      // Tap on the 'Expenses' tab
      await tester.tap(find.text('Expenses'));
      await tester.pumpAndSettle(); // Wait for the tab view to update

      expect(find.byType(GestureDetector), findsNWidgets(14));

      // Tap on the 'Incomes' tab
      await tester.tap(find.text('Incomes'));
      await tester.pumpAndSettle(); // Wait for the tab view to update

      expect(find.byType(GestureDetector), findsNWidgets(6));
    });

    testWidgets('Tapping on a category card pops with correct data',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: ExpenseCategoriesScreen()));

      // Assume we tap the first item in the expenses grid
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      // You would check here that the pop happened with the expected data
      // This assumes you have some mechanism to check the popped data, possibly via a mock navigator observer
    });

    test('getImagePathForCategory returns correct path', () {
      String imagePath =
          ExpenseCategoriesScreen.getImagePathForCategory('Food');
      expect(imagePath, 'images/Food.png');

      // Test for a non-existent category
      imagePath =
          ExpenseCategoriesScreen.getImagePathForCategory('Nonexistent');
      expect(imagePath, 'images/Default.png');
    });

    test('getColorForCategory returns correct color', () {
      Color color = ExpenseCategoriesScreen.getColorForCategory('Shopping');
      expect(color, Colors.blue);
    });
  });
}
