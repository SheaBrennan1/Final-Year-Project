import 'package:budget_buddy/budgetservice.dart';
import 'package:budget_buddy/create_budget_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'budget.dart';
import 'budgetservice.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Budgets')),
      body: FutureBuilder<List<Budget>>(
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

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Budget budget = snapshot.data![index];
              return ListTile(
                title: Text('${budget.name}'),
                subtitle: Text(
                    'Budget Period: ${budget.startDate.toLocal()} - ${budget.endDate.toLocal()}'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BudgetViewScreen(budget: budget),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateBudgetScreen()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xff368983),
      ),
    );
  }
}
