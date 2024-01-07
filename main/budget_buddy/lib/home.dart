import 'package:budget_buddy/add.dart';
import 'package:budget_buddy/editExpenseScreen.dart';
import 'package:budget_buddy/features/app/ExpenseCategoriesScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'expense_model.dart'; // Make sure this path is correct
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DatabaseReference dbRef = FirebaseDatabase.instance.ref().child("expenses");
  List<Expense> expenses = [];
  List<Expense> filteredExpenses = [];
  String userName = 'User';
  DateTime selectedDate = DateTime.now();
  double totalIncome = 0;
  double totalExpenses = 0;
  double totalBalance = 0;

  @override
  void initState() {
    super.initState();
    setUserName();
    listenToExpenses();
  }

  void setUserName() {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      userName = currentUser.displayName ?? 'User';
    } else {
      userName = 'User';
    }
  }

  void listenToExpenses() {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    dbRef.child(userId).onValue.listen((event) {
      var data = event.snapshot.value;
      if (data is Map<dynamic, dynamic>) {
        final expensesData = data.map<String, dynamic>(
          (key, value) => MapEntry(key.toString(), value),
        );
        final newExpenses = expensesData.entries
            .map((e) =>
                Expense.fromJson(Map<String, dynamic>.from(e.value), e.key))
            .toList();

        // Sort expenses by date in descending order
        newExpenses.sort((a, b) => b.date.compareTo(a.date));

        setState(() {
          expenses = newExpenses;
          filterExpensesByMonth();
        });
      }
    });
  }

  void filterExpensesByMonth() {
    filteredExpenses = expenses.where((expense) {
      return expense.date.year == selectedDate.year &&
          expense.date.month == selectedDate.month;
    }).toList();
    calculateTotals();
  }

  void calculateTotals() {
    totalIncome = filteredExpenses
        .where((item) => item.type == 'Income')
        .fold(0, (sum, item) => sum + item.amount);
    totalExpenses = filteredExpenses
        .where((item) => item.type == 'Expense')
        .fold(0, (sum, item) => sum + item.amount);
    totalBalance = totalIncome - totalExpenses;
  }

  void changeMonth(bool next) {
    setState(() {
      if (next) {
        selectedDate = DateTime(selectedDate.year, selectedDate.month + 1, 1);
      } else {
        selectedDate = DateTime(selectedDate.year, selectedDate.month - 1, 1);
      }
      filterExpensesByMonth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _head(), // Directly call _head() here
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final history = filteredExpenses[index];
                  return _transactionTile(history);
                },
                childCount: filteredExpenses.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void removeExpense(String key) async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    await FirebaseDatabase.instance
        .ref()
        .child("expenses")
        .child(userId)
        .child(key)
        .remove();
    listenToExpenses();
  }

  Widget _transactionTile(Expense history) {
    String imagePath =
        ExpenseCategoriesScreen.getImagePathForCategory(history.category);
    String formattedDateTime =
        DateFormat('dd/MM/yyyy HH:mm').format(history.date);

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: 12.0, vertical: 4.0), // Reduced vertical padding
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(imagePath, height: 40, width: 40),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(history.category,
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold)),
                  Text(formattedDateTime,
                      style: TextStyle(fontSize: 12.0, color: Colors.grey)),
                ],
              ),
            ],
          ),
          Text(
            '${history.type == 'Income' ? "+" : "-"}\$${history.amount.toStringAsFixed(2)}',
            style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: history.type == 'Income' ? Colors.green : Colors.red),
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'Edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          EditExpenseScreen(expense: history)),
                );
              } else if (value == 'Delete') {
                removeExpense(history.key!);
              }
            },
            itemBuilder: (BuildContext context) {
              return {'Edit', 'Delete'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
            icon: Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }

  void removeAllExpenses() {
    setState(() {
      expenses.clear(); // Clear the expenses list
      filteredExpenses.clear(); // Clear the filtered expenses list
      totalIncome = 0; // Reset total income
      totalExpenses = 0; // Reset total expenses
      totalBalance = 0; // Reset total balance
    });
  }

  Widget _head() {
    final monthFormatter = DateFormat('MMMM yyyy');
    return Container(
      decoration: BoxDecoration(
        color: Color(0xff368983),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Date configuration at the very top
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => changeMonth(false),
                ),
                Text(
                  monthFormatter.format(selectedDate),
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios, color: Colors.white),
                  onPressed: () => changeMonth(true),
                ),
              ],
            ),
          ),
          // Total Balance section with date range button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Balance',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Colors.white),
                      ),
                      SizedBox(height: 7),
                      Text(
                        '£ ${totalBalance.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                            color: Colors.white),
                      ),
                      SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Income £ ${totalIncome.toStringAsFixed(2)}',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 17,
                                color: Colors.white),
                          ),
                          Text(
                            'Expenses £ ${totalExpenses.toStringAsFixed(2)}',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 17,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuSelection(String choice) {
    if (choice == 'Select Date Range') {
      _selectDateRange();
    }
  }

  void _selectDateRange() async {
    // Example: Show a date range picker and then remove expenses
    DateTimeRange? dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020), // Adjust as needed
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(Duration(days: 7)), // Last week
        end: DateTime.now(),
      ),
    );

    if (dateRange != null) {
      _removeExpensesInRange(dateRange.start, dateRange.end);
    }
  }

  void _removeExpensesInRange(DateTime startDate, DateTime endDate) async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    dbRef.child(userId).get().then((snapshot) {
      if (snapshot.exists && snapshot.value is Map) {
        Map data = snapshot.value as Map;
        data.forEach((key, value) {
          Expense expense = Expense.fromJson(value, key);
          if (expense.date.isAfter(startDate) &&
              expense.date.isBefore(endDate)) {
            dbRef.child(userId).child(key).remove();
          }
        });
      }
      listenToExpenses(); // Refresh the expenses list
    });
  }
}
