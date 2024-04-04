import 'package:budget_buddy/add.dart';
import 'package:budget_buddy/budget_screen.dart';
import 'package:budget_buddy/editExpenseScreen.dart';
import 'package:budget_buddy/features/app/ExpenseCategoriesScreen.dart';
import 'package:budget_buddy/statistics.dart';
import 'package:budget_buddy/user_profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'expense_model.dart';
import 'package:intl/intl.dart';

enum ViewMode { day, month, year }

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DatabaseReference dbRef = FirebaseDatabase.instance.ref().child("expenses");
  List<Expense> expenses = [];
  List<Expense> filteredExpenses = [];
  Set<String> selectedExpenses = Set<String>();
  bool isEditMode = false;
  String userName = 'User';
  DateTime selectedDate = DateTime.now();
  double totalIncome = 0;
  double totalExpenses = 0;
  double totalBalance = 0;
  ViewMode viewMode = ViewMode.month; // Default to month view
  int viewSelection = 0; // 0 for month, 1 for year
  Map<int, List<Expense>> expensesGroupedByMonth = {};
  int index_color = 0;

  @override
  void initState() {
    super.initState();
    setUserName();
    listenToExpenses();
  }

  Widget _viewModeToggle() {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: ToggleButtons(
            borderColor: Colors.transparent,
            fillColor: Colors.blue.shade900,
            selectedBorderColor: Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            isSelected: [
              viewMode == ViewMode.day,
              viewMode == ViewMode.month,
              viewMode == ViewMode.year
            ],
            onPressed: (index) {
              setState(() {
                viewMode = ViewMode.values[index];
                filterExpensesByPeriod();
              });
            },
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text("Day",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text("Month",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text("Year",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void filterExpensesByPeriod() {
    DateTime now = DateTime.now();
    switch (viewMode) {
      case ViewMode.day:
        filteredExpenses = expenses.where((expense) {
          return expense.date.year == selectedDate.year &&
              expense.date.month == selectedDate.month &&
              expense.date.day == selectedDate.day;
        }).toList();
        break;
      case ViewMode.month:
        filteredExpenses = expenses.where((expense) {
          return expense.date.year == selectedDate.year &&
              expense.date.month == selectedDate.month;
        }).toList();
        break;
      case ViewMode.year:
        filteredExpenses = expenses.where((expense) {
          return expense.date.year == selectedDate.year;
        }).toList();
        break;
    }
    calculateTotals();
    setState(() {});
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

        newExpenses.sort((a, b) => b.date.compareTo(a.date));

        setState(() {
          expenses = newExpenses;
          filterExpensesByMonth();
        });
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Referencing the selectedDate
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        filterExpensesByPeriod(); // Ensure to call this to filter based on the new date
      });
    }
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

  void toggleEditMode() {
    setState(() {
      isEditMode = !isEditMode;
      if (!isEditMode) {
        selectedExpenses.clear();
      }
    });
  }

  void deleteSelectedExpenses() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    DatabaseReference expensesRef =
        FirebaseDatabase.instance.ref('expenses/$userId');

    // Iterate over selected expenses and delete each one
    for (String expenseKey in selectedExpenses) {
      await expensesRef.child(expenseKey).remove();
    }

    selectedExpenses.clear(); // Clear the selection
    listenToExpenses(); // Refresh the list of expenses
    toggleEditMode(); // Exit edit mode
  }

  Widget _transactionTile(Expense history) {
    String imagePath =
        ExpenseCategoriesScreen.getImagePathForCategory(history.category);
    String formattedDateTime =
        DateFormat('dd/MM/yyyy HH:mm').format(history.date);

    return InkWell(
      onTap: () {
        if (isEditMode) {
          setState(() {
            if (selectedExpenses.contains(history.key)) {
              selectedExpenses.remove(history.key);
            } else {
              selectedExpenses.add(history.key!);
            }
          });
        } else {
          // Show details popup if not in edit mode
          _showExpenseDetailsPopup(context, history);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade500)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (isEditMode)
              Checkbox(
                value: selectedExpenses.contains(history.key),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      selectedExpenses.add(history.key!);
                    } else {
                      selectedExpenses.remove(history.key);
                    }
                  });
                },
              ),
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
                        style: TextStyle(
                            fontSize: 12.0, color: Colors.grey.shade600)),
                  ],
                ),
              ],
            ),
            Text(
              '${history.type == 'Income' ? "+" : "-"}\£${history.amount.toStringAsFixed(2)}',
              style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: history.type == 'Income'
                      ? Colors.green.shade600
                      : Colors.red.shade600),
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
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      index_color = index;
    });
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => Statistics()));
        break;
      case 2:
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => BudgetScreen()));
        break;
      case 3:
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => UserProfileScreen()));
        break;
    }
  }

  Widget _editButtonSection() {
    return Column(
      children: [
        Padding(
          padding:
              EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0, bottom: 8.0),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Align items on opposite ends
            children: [
              // "History" title
              Text(
                "History",
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color:
                      Colors.blue.shade800, // Adjust color to match your theme
                ),
              ),
              // Edit and Delete Selected Buttons
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: toggleEditMode,
                    icon: Icon(
                      isEditMode ? Icons.close : Icons.edit,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: Text(
                      isEditMode ? "Cancel Edit" : "Edit",
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isEditMode ? Colors.grey[600] : Colors.blue,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  SizedBox(width: 8), // Space between buttons
                  if (isEditMode)
                    ElevatedButton.icon(
                      onPressed: deleteSelectedExpenses,
                      icon: Icon(Icons.delete, size: 18),
                      label: Text(
                        "Delete Selected",
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        Divider(
          color: Colors.grey, // Color of the divider
          thickness: 1, // Thickness of the divider line
          height: 2, // The height of the space on either side of the divider
        ),
      ],
    );
  }

  Map<int, List<Expense>> groupExpensesByMonth(List<Expense> yearlyExpenses) {
    Map<int, List<Expense>> groupedByMonth = {};

    for (var expense in yearlyExpenses) {
      if (!groupedByMonth.containsKey(expense.date.month)) {
        groupedByMonth[expense.date.month] = [];
      }
      groupedByMonth[expense.date.month]?.add(expense);
    }

    return groupedByMonth;
  }

  ThemeData appTheme() {
    return ThemeData(
      primarySwatch: Colors.blue,
      hintColor: Colors.blue,
      fontFamily: 'Roboto',
      textTheme: TextTheme(
        headline6: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
      ),
    );
  }

  Widget _head() {
    final DateFormat monthFormatter = DateFormat('MMMM yyyy');
    final DateFormat yearFormatter = DateFormat('yyyy');
    final DateFormat dayFormatter = DateFormat('dd MMMM yyyy');

    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          _viewModeToggle(),
          SizedBox(height: 10),
          if (viewMode == ViewMode.day)
            InkWell(
// Inside InkWell onTap for Day viewMode:
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2050),
                );
                if (picked != null && picked != selectedDate) {
                  setState(() {
                    selectedDate = picked;
                    filterExpensesByPeriod();
                  });
                }
              },

              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade900,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  dayFormatter.format(selectedDate),
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          if (viewMode == ViewMode.month || viewMode == ViewMode.year)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(18),
                color: Colors.blue.shade900,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => changeDateRange(false),
                  ),
                  Text(
                    viewMode == ViewMode.month
                        ? monthFormatter.format(selectedDate)
                        : yearFormatter.format(selectedDate),
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios, color: Colors.white),
                    onPressed: () => changeDateRange(true),
                  ),
                ],
              ),
            ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _summaryItem('Total Balance',
                  '£${totalBalance.toStringAsFixed(2)}', Colors.white),
              _summaryItem(
                  'Income', '£${totalIncome.toStringAsFixed(2)}', Colors.green),
              _summaryItem('Expenses', '£${totalExpenses.toStringAsFixed(2)}',
                  Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  void changeDateRange(bool next) {
    if (viewMode == ViewMode.month) {
      int monthIncrement = next ? 1 : -1;
      selectedDate =
          DateTime(selectedDate.year, selectedDate.month + monthIncrement, 1);
    } else if (viewMode == ViewMode.year) {
      int yearIncrement = next ? 1 : -1;
      selectedDate =
          DateTime(selectedDate.year + yearIncrement, selectedDate.month, 1);
    }
    filterExpensesByPeriod();
  }

  void filterExpenses() {
    if (viewMode == ViewMode.month) {
      // Month view logic remains the same
    } else {
      // Year view logic
      List<Expense> yearlyExpenses = expenses.where((expense) {
        return expense.date.year == selectedDate.year;
      }).toList();

      expensesGroupedByMonth = groupExpensesByMonth(yearlyExpenses);
    }

    // Force UI update
    setState(() {});
  }

  Widget _summaryItem(String title, String amount, Color textColor) {
    return Container(
      width: 120, // Fixed width
      height: 100, // Fixed height
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.blue.shade900, // Background color of the box
        borderRadius: BorderRadius.circular(5), // Rounded corners for the box
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade600, // Shadow color
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1), // Position of the shadow
          ),
        ],
        border: Border.all(
            color: Colors.white, width: 2), // White border around the box
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // Center the content vertically
        children: [
          Text(
            title,
            textAlign: TextAlign.center, // Center the text horizontally
            style: TextStyle(
              fontWeight:
                  FontWeight.bold, // Increased font weight for the title
              fontSize: 15, // Increased font size for the title
              color: Colors.white, // Color of the title
            ),
          ),
          SizedBox(height: 5),
          Text(
            amount,
            textAlign: TextAlign.center, // Center the text horizontally
            style: TextStyle(
              fontWeight: FontWeight.bold, // Bold text for the amount
              fontSize: 20, // Increased font size for the amount
              color: textColor, // Dynamic text color passed to the method
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(child: _head()),
          SliverToBoxAdapter(child: _editButtonSection()),
          // Check if there are any filtered expenses to display
          filteredExpenses.isNotEmpty
              ? SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      Expense expense = filteredExpenses[index];
                      // Use your existing _transactionTile method or widget
                      return _transactionTile(expense);
                    },
                    childCount: filteredExpenses.length,
                  ),
                )
              : SliverFillRemaining(
                  // This will fill the remaining space if there's no data
                  child: Center(
                    child: Text(
                      "No data for this period",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
        ],
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
        // Omitting shape property
        color: Colors.white, // Set your desired color
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.home,
                  color: Colors.blue,
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
                icon: Icon(Icons.savings_sharp),
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

  void _showExpenseDetailsPopup(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: ThemeData.light().copyWith(
            dialogBackgroundColor:
                Colors.blue.shade50, // Light blue background color
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    Colors.blue.shade600, // Dark blue text color for buttons
              ),
            ),
          ),
          child: AlertDialog(
            title: Row(
              children: [
                Icon(
                  expense.type == 'Income'
                      ? Icons.trending_up
                      : Icons.trending_down,
                  color: expense.type == 'Income' ? Colors.green : Colors.red,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    expense.type == 'Income'
                        ? "Income Details"
                        : "Expense Details",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors
                          .blue.shade800, // Dark blue color for title text
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  _detailItem("Category", expense.category),
                  _detailItem(
                      "Amount", "£${expense.amount.toStringAsFixed(2)}"),
                  _detailItem("Type", expense.type),
                  _detailItem(
                      "Date", DateFormat('dd/MM/yyyy').format(expense.date)),
                  _detailItem("Description", expense.description ?? 'N/A'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text("Close", style: TextStyle(fontSize: 18)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "$label: ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
                fontSize: 18,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void changeMonth(bool next) {
    setState(() {
      selectedDate = next
          ? DateTime(selectedDate.year, selectedDate.month + 1, 1)
          : DateTime(selectedDate.year, selectedDate.month - 1, 1);
      filterExpensesByPeriod(); // This should update your filteredExpenses list
    });
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

  void removeAllExpenses() {
    setState(() {
      expenses.clear();
      filteredExpenses.clear();
      totalIncome = 0;
      totalExpenses = 0;
      totalBalance = 0;
    });
  }
}
