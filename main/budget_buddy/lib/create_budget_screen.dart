import 'package:budget_buddy/add.dart';
import 'package:budget_buddy/budget_screen.dart';
import 'package:budget_buddy/expense_model.dart';
import 'package:budget_buddy/home.dart';
import 'package:budget_buddy/statistics.dart';
import 'package:budget_buddy/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:budget_buddy/budget.dart';
import 'package:budget_buddy/features/app/ExpenseCategoriesScreen.dart';

class CreateBudgetScreen extends StatefulWidget {
  @override
  _CreateBudgetScreenState createState() => _CreateBudgetScreenState();
}

class _CreateBudgetScreenState extends State<CreateBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _budgetNameController = TextEditingController();
  TextEditingController _budgetTotalController =
      TextEditingController(); // Declaration and initialization
  DateTime _startDate = DateTime.now();
  String _recurrence = 'Monthly';
  Map<String, bool> _selectedCategories = {};
  Map<String, TextEditingController> _categoryBudgetControllers = {};
  double _totalBudget = 0.0;
  BudgetType _selectedBudgetType = BudgetType.custom;
  final double needsPercentage = 50.0;
  final double wantsPercentage = 30.0;
  final double savingsPercentage = 20.0;

  final Color primaryColor = Colors.blue;
  final Color accentColor = Colors.blue;
  final List<String> _recurrenceOptions = [
    'Monthly',
    'Weekly',
    'Bi-Weekly',
    'Yearly'
  ];
  int index_color = 2;
  late Map<String, List<Map<String, dynamic>>> categorizedExpenses;
  late List<bool> _isOpen;

  @override
  void initState() {
    super.initState();
    _initializeCategorySelection();
  }

  void _initializeCategorySelection() {
    var categories = expenseCategories.map((e) => e['name'] as String).toList();
    for (var category in categories) {
      _selectedCategories[category] = false;
      _categoryBudgetControllers[category] = TextEditingController();
      _categoryBudgetControllers[category]!.text =
          '0'; // Initialize text to avoid null error
      _categoryBudgetControllers[category]!.addListener(_updateTotalBudget);
    }
  }

  @override
  void dispose() {
    _budgetNameController.dispose();
    _budgetTotalController.dispose();
    _categoryBudgetControllers.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
  }

  void _saveBudget() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill all required fields')));
      return; // Form is not valid
    }

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No user logged in')));
      return;
    }

    String budgetName = _budgetNameController.text;
    Map<String, double> categoryAllocations = {};

    if (_selectedBudgetType == BudgetType.custom) {
      // Keep the current logic for custom budget
      _selectedCategories.forEach((category, isSelected) {
        if (isSelected) {
          double? amount =
              double.tryParse(_categoryBudgetControllers[category]!.text);
          categoryAllocations[category] = amount ?? 0;
        }
      });
    } else {
      // For standard budget, allocate needs, wants, and savings based on the total budget
      double totalBudget = double.tryParse(_budgetTotalController.text) ?? 0;
      categoryAllocations['Needs'] = totalBudget * 0.5;
      categoryAllocations['Wants'] = totalBudget * 0.3;
      categoryAllocations['Savings'] = totalBudget * 0.2;
    }

    // Create a new Budget object
    Budget newBudget = Budget(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: budgetName,
      startDate: _startDate,
      endDate: _calculateEndDate(_startDate, _recurrence),
      categoryAllocations: categoryAllocations,
      type: _selectedBudgetType,
    );

    // Save the budget to Firestore
    try {
      await FirebaseFirestore.instance
          .collection('budgets')
          .doc(user.uid)
          .collection('userBudgets')
          .doc(newBudget.id)
          .set(newBudget.toMap());
      Navigator.pop(context, true); // Return true on successful save
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error saving budget: $error')));
    }
  }

  DateTime _calculateEndDate(DateTime startDate, String recurrence) {
    switch (recurrence) {
      case 'Weekly':
        return startDate.add(Duration(days: 7));
      case 'Bi-Weekly':
        return startDate.add(Duration(days: 14));
      case 'Yearly':
        return DateTime(startDate.year + 1, startDate.month, startDate.day);
      case 'Monthly':
      default:
        return DateTime(startDate.year, startDate.month + 1, startDate.day);
    }
  }

  void _updateTotalBudget() {
    double total = 0.0;
    _selectedCategories.forEach((category, isSelected) {
      if (isSelected) {
        double? amount =
            double.tryParse(_categoryBudgetControllers[category]!.text);
        total += amount ?? 0;
      }
    });
    setState(() {
      _totalBudget = total;
    });
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

  @override
  Widget build(BuildContext context) {
    // Use your application's primary and accent colors
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color accentColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Budget'),
        backgroundColor: primaryColor, // Use the primary color for the AppBar
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Select Budget Type",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor),
              ),
              ListTile(
                title: const Text('Standard 50/30/20 Budget'),
                leading: Radio<BudgetType>(
                  value: BudgetType.standard,
                  groupValue: _selectedBudgetType,
                  onChanged: (BudgetType? value) {
                    setState(() {
                      _selectedBudgetType = value!;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Custom Budget'),
                leading: Radio<BudgetType>(
                  value: BudgetType.custom,
                  groupValue: _selectedBudgetType,
                  onChanged: (BudgetType? value) {
                    setState(() {
                      _selectedBudgetType = value!;
                    });
                  },
                ),
              ),
              if (_selectedBudgetType == BudgetType.standard)
                _buildStandardBudgetForm()
              else
                _buildCustomBudgetForm(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed:
                    _saveBudget, // Make sure to implement the _saveBudget method
                child: Text('Save Budget'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: accentColor, // Button text color
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement your FAB action here
        },
        child: Icon(Icons.add),
        backgroundColor: accentColor, // Use the accent color for the FAB
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home, color: primaryColor),
              onPressed: () {/* Navigate to Home */},
            ),
            IconButton(
              icon: Icon(Icons.bar_chart, color: primaryColor),
              onPressed: () {/* Navigate to Statistics */},
            ),
            IconButton(
              icon: Icon(Icons.savings_sharp, color: accentColor),
              onPressed: () {/* Navigate to Budget Screen */},
            ),
            IconButton(
              icon: Icon(Icons.account_circle, color: primaryColor),
              onPressed: () {/* Navigate to User Profile Screen */},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardBudgetForm() {
    // Calculate individual category budgets based on the total budget
    double totalBudget = double.tryParse(_budgetTotalController.text) ?? 0;
    double needsBudget = totalBudget * (needsPercentage / 100);
    double wantsBudget = totalBudget * (wantsPercentage / 100);
    double savingsBudget = totalBudget * (savingsPercentage / 100);

    return Column(
      children: [
        TextFormField(
          controller: _budgetNameController,
          decoration: InputDecoration(labelText: 'Budget Name'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a budget name';
            }
            return null;
          },
        ),
        DropdownButtonFormField<String>(
          value: _recurrence,
          decoration: InputDecoration(labelText: 'Recurrence'),
          onChanged: (String? newValue) {
            setState(() {
              _recurrence = newValue!;
            });
          },
          items: _recurrenceOptions.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        TextFormField(
          controller: _budgetTotalController,
          decoration: InputDecoration(labelText: 'Total Budget (£)'),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setState(() {
              // Trigger UI update when total budget changes
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a total budget';
            }
            if (double.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Budget Allocation:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text('Needs (50%): £${needsBudget.toStringAsFixed(2)}'),
              Text('Wants (30%): £${wantsBudget.toStringAsFixed(2)}'),
              Text('Savings (20%): £${savingsBudget.toStringAsFixed(2)}'),
            ],
          ),
        ),
        buildCategorizedExpenses(),
      ],
    );
  }

  Map<String, List<Map<String, dynamic>>> categorizeExpenses(
      List<Map<String, dynamic>> expenses) {
    // Initialize categories with empty lists
    Map<String, List<Map<String, dynamic>>> categorizedExpenses = {
      'Needs': [],
      'Wants': [],
      'Savings': [],
    };

    // Iterate through each expense and categorize
    for (var expense in expenses) {
      String category = expense['category'];
      // Add the expense to the respective category list
      if (categorizedExpenses.containsKey(category)) {
        categorizedExpenses[category]!.add(expense);
      }
    }

    return categorizedExpenses;
  }

  Widget buildCategorizedExpenses() {
    // Categorizing expenses first
    Map<String, List<Map<String, dynamic>>> categorizedExpenses =
        categorizeExpenses(expenseCategories);

    // Creating a list of widgets for each category
    List<Widget> categoryWidgets = [];

    // Dynamically creating an ExpansionTile for each category
    categorizedExpenses.forEach((category, expenses) {
      Widget categoryWidget = ExpansionTile(
        title: Text(category,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        children: expenses
            .map((expense) => ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(expense['image']),
                    backgroundColor: expense['color'],
                  ),
                  title: Text(expense['name']),
                ))
            .toList(),
      );

      categoryWidgets.add(categoryWidget);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categoryWidgets,
    );
  }

  Widget _buildCustomBudgetForm() {
    // Implement your custom budget form here
    return Column(
      children: [
        // Your existing widgets for custom budget creation
        Text("Custom Budget Form Placeholder"),
      ],
    );
  }

  void _autoFillStandardBudget() {
    if (_categoryBudgetControllers.containsKey('Needs') &&
        _categoryBudgetControllers.containsKey('Wants') &&
        _categoryBudgetControllers.containsKey('Savings')) {
      const double totalBudget =
          1000; // Example total budget, replace with actual
      _categoryBudgetControllers['Needs']!.text =
          (totalBudget * 0.5).toString(); // 50%
      _categoryBudgetControllers['Wants']!.text =
          (totalBudget * 0.3).toString(); // 30%
      _categoryBudgetControllers['Savings']!.text =
          (totalBudget * 0.2).toString(); // 20%
      _updateTotalBudget();

      // Set selected categories for 50/30/20 budget
      setState(() {
        _selectedCategories['Needs'] = true;
        _selectedCategories['Wants'] = true;
        _selectedCategories['Savings'] = true;
      });
    } else {
      print("One or more category budget controllers are not initialized.");
      // Handle the case where controllers are not initialized
    }
  }

  void _clearBudgetAllocation() {
    _categoryBudgetControllers.forEach((key, controller) {
      controller.clear();
    });
    _updateTotalBudget();
  }

  List<Widget> _buildCategorySelectionWidgets() {
    return _selectedCategories.keys.map((category) {
      return CheckboxListTile(
        title: Row(
          children: [
            Image.asset(
              ExpenseCategoriesScreen.getImagePathForCategory(category),
              height: 30,
              width: 30,
            ),
            SizedBox(width: 10),
            Text(category),
          ],
        ),
        value: _selectedCategories[category],
        onChanged: (bool? value) {
          setState(() {
            _selectedCategories[category] = value!;
            if (!value) _categoryBudgetControllers[category]!.clear();
            _updateTotalBudget();
          });
        },
        secondary: _selectedCategories[category]!
            ? Container(
                width: 100,
                child: TextFormField(
                  controller: _categoryBudgetControllers[category],
                  decoration: InputDecoration(
                    labelText: '£',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (_selectedCategories[category]! &&
                        (value == null || value.isEmpty)) {
                      return 'Enter amount';
                    }
                    return null;
                  },
                ),
              )
            : null,
      );
    }).toList();
  }

// Moved outside _CreateBudgetScreenState
  Widget _buildCategoryIcon(
      List<Map<String, dynamic>> categories, String categoryType) {
    double percentage;
    if (categoryType == "Needs") {
      percentage = needsPercentage;
    } else if (categoryType == "Wants") {
      percentage = wantsPercentage;
    } else {
      percentage = savingsPercentage;
    }

    double totalBudget = _totalBudget * (percentage / 100);

    return Column(
      children: [
        Text(
          categoryType,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Column(
          children: categories.map<Widget>((category) {
            return Row(
              children: [
                Image.asset(
                  category["image"],
                  height: 30,
                  width: 30,
                ),
                SizedBox(width: 5),
                Text(
                  category["name"],
                  style: TextStyle(fontSize: 12),
                ),
              ],
            );
          }).toList(),
        ),
        Text(
          "£${totalBudget.toStringAsFixed(2)}",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
