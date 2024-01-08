import 'package:budget_buddy/budgetservice.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'budget.dart';
import 'budgetservice.dart'; // Make sure this is the correct import for BudgetService
import 'budget_view_screen.dart';
import 'budget_edit_screen.dart';

class BudgetScreen extends StatefulWidget {
  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late Future<List<Budget>> budgetsFuture;

  @override
  void initState() {
    super.initState();
    final BudgetService budgetService = BudgetService();
    final User? user = FirebaseAuth.instance.currentUser;

    // Assuming getBudgets is a method that fetches all budgets for the user
    budgetsFuture = budgetService.getBudgets(user?.uid ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Budgets')),
      body: FutureBuilder<List<Budget>>(
        future: budgetsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No budgets available'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Budget budget = snapshot.data![index];
                return ListTile(
                  title: Text('Budget for ${budget.month}/${budget.year}'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BudgetViewScreen(budget: budget),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: // Within your BudgetScreen class

          FloatingActionButton(
        onPressed: () {
          // Navigate to BudgetEditScreen with null or a new Budget object for creating a new budget
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BudgetEditScreen(
                    budget: null)), // Pass null or a new Budget instance
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xff368983),
      ),
    );
  }
}
