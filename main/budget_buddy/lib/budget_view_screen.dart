import 'package:budget_buddy/add.dart';
import 'package:budget_buddy/budget_screen.dart';
import 'package:budget_buddy/create_budget_screen.dart';
import 'package:budget_buddy/home.dart';
import 'package:budget_buddy/main.dart';
import 'package:budget_buddy/statistics.dart';
import 'package:budget_buddy/user_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'budget.dart';

class BudgetViewScreen extends StatefulWidget {
  final Budget budget;

  BudgetViewScreen({Key? key, required this.budget}) : super(key: key);

  @override
  _BudgetViewScreenState createState() => _BudgetViewScreenState();
}

class _BudgetViewScreenState extends State<BudgetViewScreen> {
  int index_color = 2;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Budget Details', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        elevation: 2,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _confirmAndDeleteBudget(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBudgetSummaryCard(theme),
              const SizedBox(height: 12),
              // Conditionally show the category spending details or the standard budget breakdown
              widget.budget.type == BudgetType.standard
                  ? _buildStandardBudgetDetails()
                  : _buildCategorySpendingDetails(theme),
            ],
          ),
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
        // Omitting shape property
        color: Colors.white, // Set your desired color
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

  Future<Map<String, double>> fetchAndCalculateSpending(
      String userId, DateTime startDate, DateTime endDate) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref('expenses/$userId');
    Map<String, double> spendingPerCategory = {};

    // Firebase Realtime Database doesn't support direct querying by date range in the same way as Firestore.
    // You'd fetch all expenses and then filter them client-side. This may not be efficient for a large dataset.
    DatabaseEvent event = await ref.once();

    if (event.snapshot.exists) {
      Map<dynamic, dynamic> expenses =
          event.snapshot.value as Map<dynamic, dynamic>;
      expenses.forEach((key, value) {
        Map<String, dynamic> expenseData = Map<String, dynamic>.from(value);
        DateTime expenseDate = DateTime.parse(expenseData['date']);
        String category = expenseData['category'];
        double amount = (expenseData['amount'] as num).toDouble();

        // Filtering expenses within the date range of the budget
        if (expenseDate.isAfter(startDate) && expenseDate.isBefore(endDate)) {
          if (spendingPerCategory.containsKey(category)) {
            spendingPerCategory[category] =
                spendingPerCategory[category]! + amount;
          } else {
            spendingPerCategory[category] = amount;
          }
        }
      });
    }

    return spendingPerCategory;
  }

  Widget _buildCategorySpendingDetails(ThemeData theme) {
    final String budgetId = widget.budget.id;
    final User? user = FirebaseAuth.instance.currentUser;
    final String userId = user!.uid;

    // Begin FutureBuilder to fetch current spending
    return FutureBuilder<Map<String, double>>(
      future: fetchAndCalculateSpending(
          userId,
          widget.budget.startDate,
          widget.budget
              .endDate), // Future method to fetch and calculate current spending
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (!snapshot.hasData) {
          return Text("No spending data available.");
        }

        Map<String, double> currentSpendingPerCategory = snapshot.data!;
        Map<String, dynamic> categoryAllocations =
            widget.budget.categoryAllocations;

        // Build column for each category with allocated and spent amounts
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Custom Budget Details", style: theme.textTheme.headline6),
            ...categoryAllocations.entries.map((entry) {
              String category = entry.key;
              double allocatedAmount =
                  entry.value.toDouble(); // Allocated amount for this category
              double spentAmount = currentSpendingPerCategory[category] ??
                  0.0; // Spent amount, default to 0 if not found

              // Decide the color based on whether the allocated amount has been exceeded
              Color spentAmountColor =
                  spentAmount > allocatedAmount ? Colors.red : Colors.green;
              String imagePath = getImagePathForCategory(
                  category); // Fetch image path for category

              return ListTile(
                leading: imagePath.isNotEmpty
                    ? Image.asset(imagePath,
                        width: 40, height: 40) // Display category image
                    : null, // No image found case
                title: Text(category), // Category name
                subtitle:
                    Text("Allocated: £$allocatedAmount"), // Allocated amount
                trailing: Text(
                  "Spent: £$spentAmount",
                  style: TextStyle(
                    color: spentAmountColor, // Color coding based on condition
                    fontSize: 16, // Make text a little bigger
                    fontWeight: FontWeight.bold, // Make text bold
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

// Example function to get image path for a category
  String getCategoryImagePath(String category) {
    // Placeholder for your actual logic
    switch (category.toLowerCase()) {
      case 'food':
        return 'assets/images/Food.png';
      // Add more cases as needed
      default:
        return ''; // Return a default image or empty if not found
    }
  }

  Widget _buildStandardBudgetDetails() {
    // Mapping standard budget categories to icons
    Map<String, IconData> standardCategoryIcons = {
      "Needs": Icons.home,
      "Wants": Icons.shopping_cart,
      "Savings": Icons.account_balance_wallet,
    };

    // Widget to display budget details for standard categories
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'Standard Budget Breakdown',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        _buildStandardCategoryDetail("Needs", standardCategoryIcons["Needs"]!),
        _buildStandardCategoryDetail("Wants", standardCategoryIcons["Wants"]!),
        _buildStandardCategoryDetail(
            "Savings", standardCategoryIcons["Savings"]!),
      ],
    );
  }

// Helper method to build each budget detail item
  Widget _buildBudgetDetailItem(
      String category, double allocated, double spent) {
    Color textColor = spent <= allocated ? Colors.green : Colors.red;
    return ListTile(
      title: Text("$category Allocated: £${allocated.toStringAsFixed(2)}"),
      subtitle: Text(
        "$category Spent: £${spent.toStringAsFixed(2)}",
        style: TextStyle(
            color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStandardCategoryDetail(String category, IconData icon) {
    Future<double> spendingFuture =
        _getCategorySpending(widget.budget.id, category);

    return FutureBuilder<double>(
      future: spendingFuture,
      builder: (context, snapshot) {
        double spentAmount = snapshot.data ?? 0.0;
        double allocatedAmount =
            widget.budget.categoryAllocations[category] ?? 0.0;
        Color spentAmountColor =
            spentAmount > allocatedAmount ? Colors.red : Colors.green;
        double spendingProgress =
            allocatedAmount > 0 ? spentAmount / allocatedAmount : 0.0;
        spendingProgress = spendingProgress.clamp(0.0, 1.0);

        return ListTile(
          leading: Icon(icon, size: 40),
          title: Text(category),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Allocated: £${allocatedAmount.toStringAsFixed(2)}"),
              SizedBox(height: 4),
              LinearProgressIndicator(
                value: spendingProgress,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(spentAmountColor),
                minHeight: 10.0,
              ),
            ],
          ),
          trailing: Text(
            "Spent: £${spentAmount.toStringAsFixed(2)}",
            style: TextStyle(
              color: spentAmountColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  bool _isBudgetExpired(DateTime endDate) {
    return endDate.isBefore(DateTime.now());
  }

  void _confirmAndDeleteBudget(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Budget'),
          content: Text(
              'Are you sure you want to delete this budget? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                _deleteBudget();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteBudget() async {
    Navigator.of(context).pop(); // Close the confirmation dialog

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No user found - unable to delete budget.");
      return;
    }

    final String budgetDocPath =
        'budgets/${user.uid}/userBudgets/${widget.budget.id}';
    print("Attempting to delete budget at Firestore path: $budgetDocPath");

    try {
      await FirebaseFirestore.instance.doc(budgetDocPath).delete();

      print("Budget deleted successfully from Firestore.");

      // Optionally, show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Budget deleted successfully')),
      );

      // Navigate back or to another screen as needed
      Navigator.of(context).pop();
    } catch (e) {
      // Log the detailed error message
      print("Error deleting budget from Firestore: $e");

      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting budget: $e')),
      );
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
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => BudgetScreen()));
        break;
      case 3:
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => UserProfileScreen()));
        break;
    }
  }

  Future<double> _getTotalSpending(String budgetId) async {
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
          // Check if the expense's category is in the budget
          if (widget.budget.categoryAllocations
              .containsKey(value['category'])) {
            DateTime expenseDate = DateTime.parse(value['date']);
            if (expenseDate.isAtSameMomentAs(widget.budget.startDate) ||
                expenseDate.isAtSameMomentAs(widget.budget.endDate) ||
                (expenseDate.isAfter(widget.budget.startDate) &&
                    expenseDate.isBefore(
                        widget.budget.endDate.add(Duration(days: 1))))) {
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

  Future<double> _getCategorySpending(
      String budgetId, String budgetCategory) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return 0.0;

    DatabaseReference expensesRef =
        FirebaseDatabase.instance.ref('expenses/${user.uid}');
    double totalSpending = 0.0;

    // Map direct categories to standard budget categories
    Map<String, String> categoryMapping = {
      // Populate this based on your expenseCategories structure
      "Food": "Needs",
      "Home": "Needs",
      // Add all mappings here...
    };

    try {
      DataSnapshot snapshot = await expensesRef.get();
      if (snapshot.exists) {
        Map<dynamic, dynamic> expenses =
            snapshot.value as Map<dynamic, dynamic>;

        expenses.forEach((key, value) {
          String directCategory = value['category'];
          // Use the mapping to get the standard budget category
          String mappedCategory = categoryMapping[directCategory] ?? "";

          if (mappedCategory == budgetCategory) {
            DateTime expenseDate = DateTime.parse(value['date']);
            if ((expenseDate.isAfter(widget.budget.startDate) ||
                    expenseDate.isAtSameMomentAs(widget.budget.startDate)) &&
                (expenseDate.isBefore(widget.budget.endDate) ||
                    expenseDate.isAtSameMomentAs(widget.budget.endDate))) {
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

  Widget _buildBudgetSummaryCard(ThemeData theme) {
    bool budgetExpired = _isBudgetExpired(widget.budget.endDate);

    // Future to get total spending. This would ideally take into account the type of budget.
    Future<double> totalSpendingFuture = _getTotalSpending(widget.budget.id);

    // Assuming your Budget model has a way to identify if it's a standard or custom budget,
    // for example, `widget.budget.type` that returns `BudgetType.standard` or `BudgetType.custom`.
    double totalAllocated = widget.budget
        .totalBudget; // This should dynamically reflect based on the budget type.

    return Card(
      color: budgetExpired ? Colors.blue.shade100 : Colors.blue.shade300,
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.budget.name,
              style: theme.textTheme.headline5?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            if (budgetExpired)
              Text(
                'This budget has expired',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
            SizedBox(height: 8),
            FutureBuilder<double>(
              future: totalSpendingFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                double totalSpent = snapshot.data ?? 0.0;
                double remainingBudget = totalAllocated - totalSpent;
                bool isOverBudget = remainingBudget < 0;

                double progressValue =
                    (totalSpent / totalAllocated).clamp(0.0, 1.0);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: progressValue,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          isOverBudget ? Colors.red : Colors.green),
                      minHeight: 20.0,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Total Budget: £${totalAllocated.toStringAsFixed(2)}',
                      style: theme.textTheme.subtitle1?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Total Spent: £${totalSpent.toStringAsFixed(2)}',
                      style: theme.textTheme.subtitle1
                          ?.copyWith(color: Colors.black),
                    ),
                    Text(
                      isOverBudget
                          ? 'Over Budget by: £${(-remainingBudget).toStringAsFixed(2)}'
                          : 'Remaining Budget: £${remainingBudget.toStringAsFixed(2)}',
                      style: theme.textTheme.subtitle1?.copyWith(
                        color: isOverBudget
                            ? Colors.red
                            : Color.fromARGB(255, 60, 112, 1),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySpendingCard(
      MapEntry<String, double> entry, ThemeData theme) {
    return FutureBuilder<double>(
      future: _getCategorySpending(widget.budget.id, entry.key),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        double spentAmount = snapshot.data ?? 0;
        double allocatedAmount = entry.value;
        bool isOverBudget = spentAmount > allocatedAmount;

        // Assuming you have a method or map `getImagePathForCategory` that returns a String path for each category's image
        String imagePath = getImagePathForCategory(entry.key);

        return Card(
          margin: EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: imagePath.isNotEmpty
                ? Image.asset(imagePath,
                    width: 40,
                    height: 40) // Displaying the image for the category
                : SizedBox(
                    width: 40,
                    height: 40), // Empty space if no image is available
            title: Text(
              entry.key,
              style: theme.textTheme.bodyText1?.copyWith(
                  color: Colors.black), // Making the category name black
            ),
            subtitle: Text(
              'Allocated: £${allocatedAmount.toStringAsFixed(2)}',
              style: theme.textTheme.caption,
            ),
            trailing: Text(
              'Spent: £${spentAmount.toStringAsFixed(2)}',
              style: TextStyle(
                  color: isOverBudget ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
          ),
        );
      },
    );
  }

// Example method to get an image path based on the category name
  String getImagePathForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return 'images/Food.png';
      case 'transport':
        return 'images/Transportation.png';
      case 'utilities':
        return 'images/utilities.png';
      case 'shopping':
        return 'images/Shopping.png';
      case 'home':
        return 'images/Home.png';
      case 'bills & fees':
        return 'images/Bills & Fees.png.png';
      case 'fun':
        return 'images/Entertainment.png';
      case 'car':
        return 'images/Car.png';
      case 'travel':
        return 'images/Travel.png';
      case 'education':
        return 'images/Education.png';
      case 'personal':
        return 'images/Family & Personal.png';
      case 'health':
        return 'images/Health.png';
      case 'groceries':
        return 'images/Groceries.png';
      case 'gifts':
        return 'images/Gifts.png';
      case 'sports':
        return 'images/Sports & Hobbies.png';
      case 'beauty':
        return 'images/Beauty.png';
      case 'work':
        return 'images/Work.png';
      case 'netflix':
        return 'images/netflix.png';
      case 'amazon':
        return 'images/prime.png';
      case 'spotify':
        return 'images/spotify.png';
      case 'other':
        return 'images/Other.png';
      default:
        return ''; // Return an empty string or a default image path if the category does not match
    }
  }

  Future<void> notifyBudgetLimitReached(
      String category, double limit, double currentSpending) async {
    if (currentSpending >= limit) {
      const int notificationId = 1; // Unique ID for this type of notification
      String title = "Budget Alert!";
      String body = "You've reached your $category budget limit of $limit.";

      await showNotification(notificationId, title, body);
    }
  }

  Future<void> showNotification(
      int notificationId, String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'channel_description',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      title, // Notification title
      body, // Notification body/content
      platformDetails, // Platform-specific details
    );
  }
}
