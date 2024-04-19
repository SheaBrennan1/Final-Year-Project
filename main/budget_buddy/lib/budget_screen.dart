import 'package:budget_buddy/add.dart';
import 'package:budget_buddy/home.dart';
import 'package:budget_buddy/statistics.dart';
import 'package:budget_buddy/user_profile_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'budget.dart';
import 'budgetservice.dart';
import 'budget_view_screen.dart';
import 'package:intl/intl.dart';
import 'create_budget_screen.dart';

class BudgetScreen extends StatefulWidget {
  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late Future<List<Budget>> budgetsFuture;
  int index_color = 2;

  @override
  void initState() {
    super.initState();
    fetchUserBudgets();
  }

  void fetchUserBudgets() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final BudgetService budgetService = BudgetService();
      budgetsFuture = budgetService.getBudgets(user.uid);
    } else {
      print("User not logged in");
    }
  }

  bool _isBudgetExpired(DateTime endDate) {
    return endDate.isBefore(DateTime.now());
  }

  Future<double> getTotalSpent(Budget budget) async {
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
          if (budget.categoryAllocations.containsKey(value['category'])) {
            DateTime expenseDate = DateTime.parse(value['date']);
            if ((expenseDate.isAfter(budget.startDate) ||
                    expenseDate.isAtSameMomentAs(budget.startDate)) &&
                (expenseDate.isBefore(budget.endDate.add(Duration(days: 1))) ||
                    expenseDate.isAtSameMomentAs(budget.endDate))) {
              totalSpending += (value['amount'] as num).toDouble();
            }
          }
        });
      }
      return totalSpending;
    } catch (e) {
      print('Error fetching total spending: $e');
      return 0.0;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      index_color = index;
    });
    switch (index) {
      case 0:
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) => Home()));
        break;
      case 1:
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => Statistics()));
        break;
      case 2:
        break;
      case 3:
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => UserProfileScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Budgets',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Enclosing the descriptive section within a blue Card
            Card(
              color: Colors.blue.shade100,
              margin: EdgeInsets.all(16.0), // Margin around the card
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manage Your Budgets',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Create and track your budgets to manage your spending more effectively. Set up a budget for different categories, such as groceries, bills, or entertainment, and monitor your expenses to stay on track.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            FutureBuilder<List<Budget>>(
              future: budgetsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No budgets available'));
                }

                // Filtering the budgets into active and expired.
                var activeBudgets = snapshot.data!
                    .where((budget) => !_isBudgetExpired(budget.endDate))
                    .toList();
                var expiredBudgets = snapshot.data!
                    .where((budget) => _isBudgetExpired(budget.endDate))
                    .toList();

                return Column(
                  children: [
                    // Active budgets list
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Text(
                        "Active Budgets",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                    ),
                    ...activeBudgets
                        .map((budget) => _budgetCard(budget, false)),
                    if (expiredBudgets.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: Text(
                          "Expired Budgets",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        ),
                      ),
                    // Expired budgets list
                    ...expiredBudgets
                        .map((budget) => _budgetCard(budget, true)),
                  ],
                );
              },
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateBudgetScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: Text(
                  'Create a new budget',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => Add_Screen()));
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.home,
                ),
                onPressed: () {
                  _onItemTapped(0);
                }),
            IconButton(
                icon: Icon(Icons.bar_chart),
                onPressed: () {
                  _onItemTapped(1);
                }),
            IconButton(
                icon: Icon(Icons.savings_sharp, color: Colors.blue),
                onPressed: () {
                  _onItemTapped(2);
                }),
            IconButton(
                icon: Icon(Icons.account_circle),
                onPressed: () {
                  _onItemTapped(3);
                }),
          ],
        ),
      ),
    );
  }

  Widget _budgetCard(Budget budget, bool isExpired) {
    // Wrap the LinearProgressIndicator in a FutureBuilder
    return FutureBuilder<double>(
      future: getTotalSpent(budget),
      builder: (context, snapshot) {
        double progress = 0.0;

        if (snapshot.hasData) {
          final double totalSpent = snapshot.data!;
          final double totalBudget = budget.totalBudget;
          progress = totalSpent / totalBudget;
        }

        // Now progress is a double that can be safely used
        return Card(
          elevation: 3.0,
          margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          color: isExpired ? Colors.grey.shade300 : Colors.blue.shade100,
          child: ListTile(
            leading: Icon(Icons.account_balance_wallet,
                size: 30.0, color: isExpired ? Colors.grey : Colors.blue),
            title: Text(
              budget.name,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isExpired ? Colors.black : Colors.black),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                LinearProgressIndicator(
                  value: isExpired ? 1.0 : progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.grey[400],
                  valueColor: AlwaysStoppedAnimation<Color>(
                      isExpired ? Colors.red : Colors.blue),
                  minHeight: 10.0,
                ),
                SizedBox(height: 5),
                Text(
                  '${(progress * 100).toStringAsFixed(2)}% used of £${budget.totalBudget.toStringAsFixed(2)}',
                  style: TextStyle(
                      color: progress > 1 ? Colors.red : Colors.black),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMM d, yyyy')
                          .format(budget.startDate.toLocal()),
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      DateFormat('MMM d, yyyy')
                          .format(budget.endDate.toLocal()),
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isExpired ? Colors.red : Colors.black),
                    ),
                  ],
                ),
              ],
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BudgetViewScreen(budget: budget),
              ),
            ),
          ),
        );
      },
    );
  }
}
