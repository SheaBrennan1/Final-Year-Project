import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'budget.dart';

class BudgetViewScreen extends StatelessWidget {
  final Budget budget;

  BudgetViewScreen({Key? key, required this.budget}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Budget Details')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Budget Summary Card
              Card(
                margin: EdgeInsets.only(bottom: 16.0),
                elevation: 4.0,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: FutureBuilder<double>(
                    future: _getTotalSpending(budget.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      double totalSpent = snapshot.data ?? 0.0;
                      double totalAllocated = budget.categoryAllocations.values
                          .fold(0, (sum, e) => sum + e);
                      double remainingBudget = totalAllocated - totalSpent;
                      bool isOverBudget = remainingBudget < 0;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Total Budget: £${totalAllocated.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text('Total Spent: £${totalSpent.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 16)),
                          SizedBox(height: 8),
                          Text(
                            isOverBudget
                                ? 'Over Budget by: £${(-remainingBudget).toStringAsFixed(2)}'
                                : 'Remaining Budget: £${remainingBudget.toStringAsFixed(2)}',
                            style: TextStyle(
                                fontSize: 16,
                                color:
                                    isOverBudget ? Colors.red : Colors.green),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              // Category Spending Details
              ...budget.categoryAllocations.entries.map(
                (entry) => FutureBuilder<double>(
                  future: _getCategorySpending(budget.id, entry.key),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }

                    double spentAmount = snapshot.data ?? 0;
                    double allocatedAmount = entry.value;
                    bool isOverBudget = spentAmount > allocatedAmount;

                    return ListTile(
                      title: Text(entry.key),
                      subtitle: Text(
                          'Allocated: £${allocatedAmount.toStringAsFixed(2)}'),
                      trailing: Text(
                        'Spent: £${spentAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                            color: isOverBudget ? Colors.red : Colors.green),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<double> _getTotalSpending(String budgetId) async {
    // Logic to calculate total spending across all categories
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return 0.0;

    DatabaseReference expensesRef =
        FirebaseDatabase.instance.ref('expenses/${user.uid}');

    double totalSpending = 0.0;
    try {
      DataSnapshot snapshot = await expensesRef.get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> expenses =
            snapshot.value as Map<dynamic, dynamic>;
        expenses.forEach((key, value) {
          DateTime expenseDate = DateTime.parse(value['date']);
          if ((expenseDate.isAfter(budget.startDate) ||
                  expenseDate.isAtSameMomentAs(budget.startDate)) &&
              (expenseDate.isBefore(budget.endDate) ||
                  expenseDate.isAtSameMomentAs(budget.endDate))) {
            totalSpending += (value['amount'] as num).toDouble();
          }
        });
      }
      return totalSpending;
    } catch (e) {
      print('Error fetching total spending: $e');
      return 0.0;
    }
  }

  Future<double> _getCategorySpending(String budgetId, String category) async {
    // Existing logic to calculate spending for a specific category
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return 0.0;

    DatabaseReference expensesRef =
        FirebaseDatabase.instance.ref('expenses/${user.uid}');

    double totalSpending = 0.0;
    try {
      DataSnapshot snapshot = await expensesRef.get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> expenses =
            snapshot.value as Map<dynamic, dynamic>;
        expenses.forEach((key, value) {
          if (value['category'] == category) {
            DateTime expenseDate = DateTime.parse(value['date']);
            if ((expenseDate.isAfter(budget.startDate) ||
                    expenseDate.isAtSameMomentAs(budget.startDate)) &&
                (expenseDate.isBefore(budget.endDate) ||
                    expenseDate.isAtSameMomentAs(budget.endDate))) {
              totalSpending += (value['amount'] as num).toDouble();
            }
          }
        });
      }
      return totalSpending;
    } catch (e) {
      print('Error fetching category spending: $e');
      return 0.0;
    }
  }
}
