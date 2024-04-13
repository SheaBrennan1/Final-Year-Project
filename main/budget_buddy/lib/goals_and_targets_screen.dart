import 'package:budget_buddy/add.dart';
import 'package:budget_buddy/budget_screen.dart';
import 'package:budget_buddy/home.dart';
import 'package:budget_buddy/main.dart';
import 'package:budget_buddy/statistics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class GoalsAndTargetsScreen extends StatefulWidget {
  @override
  _GoalsAndTargetsScreenState createState() => _GoalsAndTargetsScreenState();
}

class _GoalsAndTargetsScreenState extends State<GoalsAndTargetsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _targetController = TextEditingController();
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;
  double? _yearlyTarget;
  double _currentProgress = 0.0; // This should be dynamically updated
  Map<String, double> categoryTargets = {};
  int index_color = 3;

  @override
  void initState() {
    super.initState();
    _fetchFinancialDataAndYearlyTarget();
    _fetchCategoryTargets();
  }

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _fetchYearlyTarget() async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    final DatabaseReference targetRef =
        FirebaseDatabase.instance.ref('yearlyTargets/$userId');

    final DataSnapshot targetSnapshot = await targetRef.get();
    if (targetSnapshot.exists && targetSnapshot.value != null) {
      final double targetValue = (targetSnapshot.value as num).toDouble();
      setState(() {
        _yearlyTarget = targetValue;
        if (_yearlyTarget != null) {
          _currentProgress = (_totalIncome - _totalExpenses) / _yearlyTarget!;
        }
      });
    }
  }

  void setCategoryTarget(String category, double target) async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    final ref =
        FirebaseDatabase.instance.ref('categoryTargets/$userId/$category');

    try {
      await ref.set(target);
      print('Category target updated successfully.');
      setState(() => categoryTargets[category] = target);
    } catch (e) {
      print("Error setting category target: $e");
    }
  }

  Widget _buildCategoryTargetsContainer() {
    // You can customize this method to fit the specific layout and data for category targets.
    return Container(
      padding: EdgeInsets.all(16.0),
      margin:
          EdgeInsets.only(top: 20.0), // Added some margin for visual separation
      decoration: BoxDecoration(
        color: Colors.blue.shade400,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200,
            blurRadius: 5.0,
            spreadRadius: 2.0,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category Targets',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          // Assuming buildCategoryTargets() builds the actual list of category targets.
          buildCategoryTargets(),
        ],
      ),
    );
  }

  Widget buildCategoryTargets() {
    // Your implementation goes here, similar to what you had before.
    // This widget can be a ListView.builder or a simpler Column with children depending on your needs.
    return Column(
      children: categoryTargets.entries.map((entry) {
        return ListTile(
          title: Text(entry.key, style: TextStyle(color: Colors.white)),
          subtitle: Text('Target: £${entry.value.toStringAsFixed(2)}',
              style: TextStyle(color: Colors.white70)),
        );
      }).toList(),
    );
  }

  void _setYearlyTarget() async {
    print("Attempting to set yearly target...");

    print("Form is valid. Parsing target value...");
    final double? targetValue = double.tryParse(_targetController.text);

    if (targetValue != null) {
      print("Parsed target value: $targetValue");
      await _saveYearlyTargetToDatabase(
          targetValue); // Await the database update
      setState(() {
        _yearlyTarget = targetValue;
        _currentProgress = (_totalIncome - _totalExpenses) / _yearlyTarget!;
        print('Updated state with new target and current progress.');
      });
    } else {
      print(
          "Failed to parse target value. Input was '${_targetController.text}'");
    }
  }

  Future<void> _fetchCategoryTargets() async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    final ref = FirebaseDatabase.instance.ref('categoryTargets/$userId');

    try {
      DataSnapshot snapshot = await ref.get();
      if (snapshot.exists && snapshot.value is Map) {
        final targets = Map<String, double>.from(
          (snapshot.value as Map).map((key, value) =>
              MapEntry(key as String, (value as num).toDouble())),
        );
        setState(() => categoryTargets = targets);
      }
    } catch (e) {
      print("Error fetching category targets: $e");
    }
  }

  Future<void> _saveYearlyTargetToDatabase(double targetValue) async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    print("Current user ID: $userId");

    if (userId == 'anonymous') {
      print(
          "Warning: User ID is 'anonymous'; may not have permissions to write to database.");
    }

    DatabaseReference ref =
        FirebaseDatabase.instance.ref('yearlyTargets/$userId');

    try {
      print("Attempting to save yearly target ($targetValue) to Firebase...");
      await ref.set(targetValue);
      print('Successfully updated yearly target in Firebase.');
    } catch (error) {
      print('Failed to update yearly target in Firebase: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Goals and Targets',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold, // Adjust as needed
          ),
        ),
        backgroundColor: Colors.blue.shade400,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProgressContainer(context),
            _buildCategoryTargetsContainer(),
            // If you have additional content to include outside the blue container, add it here...
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
                icon: Icon(Icons.savings_sharp),
                onPressed: () {
                  _onItemTapped(2);
                }),
            IconButton(
                icon: Icon(Icons.account_circle, color: Colors.blue),
                onPressed: () {
                  _onItemTapped(3);
                }),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressContainer(BuildContext context) {
    // Calculate progress percentage
    final double progressPercentage =
        _yearlyTarget != null && _yearlyTarget! > 0
            ? ((_totalIncome - _totalExpenses) / _yearlyTarget!).clamp(0.0, 1.0)
            : 0.0;
    bool targetMet = progressPercentage >= 1.0; // Check if the target is met

    Color progressColor =
        targetMet ? Colors.green : Theme.of(context).colorScheme.secondary;

    TextStyle headingStyle = TextStyle(
        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16);

    Widget keyValueRow(String key, String value) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(key, style: headingStyle),
            Text(value, style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        );

    return Container(
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.only(top: 10.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade400, // Adjusted darker shaded blue color
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200,
            blurRadius: 5.0,
            spreadRadius: 2.0,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set Your Yearly Savings Goal (£):',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _targetController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(color: Colors.blue[700]),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelStyle: TextStyle(color: Colors.blue[700]),
                    prefixText: '£',
                    prefixStyle:
                        TextStyle(color: Colors.blue[700], fontSize: 16),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 2.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.blue[700]!, width: 2.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.blue[700],
                  backgroundColor: Colors.white,
                ),
                onPressed: () {
                  _setYearlyTarget();
                },
                child: Text('Update'),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'Progress Towards Your Goal',
            style: headingStyle,
          ),
          SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 20.0,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) => Container(
                  height: 20.0,
                  width: constraints.maxWidth * progressPercentage,
                  decoration: BoxDecoration(
                    color: progressColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Center(
            child: Text(
              targetMet
                  ? "You have reached your target!"
                  : '${(progressPercentage * 100).toStringAsFixed(2)}% towards your goal of £${_yearlyTarget?.toStringAsFixed(2) ?? '0'}',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.blue.shade600, // Adjusted darker shaded blue color
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                keyValueRow(
                    'Yearly Income:', '£${_totalIncome.toStringAsFixed(2)}'),
                SizedBox(height: 8),
                keyValueRow('Yearly Expenses:',
                    '£${_totalExpenses.toStringAsFixed(2)}'),
                SizedBox(height: 8),
                keyValueRow('Current Amount:',
                    '£${(_totalIncome - _totalExpenses).toStringAsFixed(2)}'),
              ],
            ),
          ),
        ],
      ),
    );
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
        break;
    }
  }

  Future<void> fetchFinancialDataAndCalculateProgress() async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    final currentYear = DateTime.now().year;

    // Reset the totals to ensure fresh calculation
    double localTotalIncome = 0.0;
    double localTotalExpenses = 0.0;

    final DatabaseReference ref =
        FirebaseDatabase.instance.ref("expenses/$userId");
    DataSnapshot snapshot = await ref.get();

    if (snapshot.exists && snapshot.value is Map) {
      Map<dynamic, dynamic> entries =
          Map<dynamic, dynamic>.from(snapshot.value as Map);

      entries.forEach((key, value) {
        if (value is Map) {
          final entry = Map<String, dynamic>.from(value);
          final DateTime? date = DateTime.tryParse(entry['date']);

          if (date != null && date.year == currentYear) {
            final double amount = (entry['amount'] as num).toDouble();

            switch (entry['type']) {
              case 'Income':
                localTotalIncome += amount;
                break;
              case 'Expense':
                localTotalExpenses += amount;
                break;
            }
          }
        }
      });

      // Update the state with fetched values
      setState(() {
        _totalIncome = localTotalIncome;
        _totalExpenses = localTotalExpenses;
        if (_yearlyTarget != null) {
          _currentProgress = (_totalIncome - _totalExpenses) / _yearlyTarget!;
        } else {}
      });

      // Optionally fetch and update the yearly target if not already set
      if (_yearlyTarget == null) {
        await _fetchYearlyTarget();
      }
    }
  }

  Future<void> _fetchFinancialDataAndYearlyTarget() async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    final currentYear = DateTime.now().year;

    // Initialize local variables to calculate totals
    double localTotalIncome = 0.0;
    double localTotalExpenses = 0.0;

    // Fetch Yearly Target
    final DatabaseReference targetRef =
        FirebaseDatabase.instance.ref('yearlyTargets/$userId');
    final DataSnapshot targetSnapshot = await targetRef.get();
    if (targetSnapshot.exists && targetSnapshot.value != null) {
      _yearlyTarget = (targetSnapshot.value as num).toDouble();
    }

    // Fetch Financial Entries (Income and Expenses)
    final DatabaseReference entriesRef =
        FirebaseDatabase.instance.ref("expenses/$userId");
    final DataSnapshot entriesSnapshot = await entriesRef.get();
    if (entriesSnapshot.exists && entriesSnapshot.value is Map) {
      Map<dynamic, dynamic> entries =
          Map<dynamic, dynamic>.from(entriesSnapshot.value as Map);
      entries.forEach((key, value) {
        if (value is Map) {
          final entry = Map<String, dynamic>.from(value);
          final DateTime? date = DateTime.tryParse(entry['date']);
          final double amount = (entry['amount'] as num).toDouble();

          if (date != null && date.year == currentYear) {
            switch (entry['type']) {
              case 'Income':
                localTotalIncome += amount;
                break;
              case 'Expense':
                localTotalExpenses += amount;
                break;
            }
          }
        }
      });
    }

    // Update the state with the new values
    setState(() {
      _totalIncome = localTotalIncome;
      _totalExpenses = localTotalExpenses;
      // Recalculate progress if the yearly target is already set
      if (_yearlyTarget != null) {
        _currentProgress = (_totalIncome - _totalExpenses) / _yearlyTarget!;
      }
    });
  }

  Future<void> fetchFinancialEntries(String path, bool isIncome) async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    final DatabaseReference entriesRef = FirebaseDatabase.instance.ref(path);
    final DataSnapshot snapshot = await entriesRef.get();

    double totalAmount = 0.0;
    if (snapshot.exists && snapshot.value is Map) {
      Map<dynamic, dynamic> entries =
          Map<dynamic, dynamic>.from(snapshot.value as Map);
      entries.forEach((key, value) {
        final Map<String, dynamic> entry = Map<String, dynamic>.from(value);
        if (entry.containsKey('amount') && entry.containsKey('date')) {
          final date = DateTime.tryParse(entry['date']);
          final currentYear = DateTime.now().year;
          // Ensure that only entries from the current year are considered
          if (date != null && date.year == currentYear) {
            totalAmount += entry['amount'] as double;
          }
        }
      });
    }

    // Update total income or expenses based on the entry type
    if (isIncome) {
      _totalIncome = totalAmount;
    } else {
      _totalExpenses = totalAmount;
    }
  }

  Future<void> notifyBudgetLimitReached(
      String category, double limit, double currentSpending) async {
    if (currentSpending >= limit) {
      const int notificationId = 2; // Unique ID for this type of notification
      String title = "Spending Goal Reached!";
      String body =
          "Congratulations! You have reached your spending goal for the year!";

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
