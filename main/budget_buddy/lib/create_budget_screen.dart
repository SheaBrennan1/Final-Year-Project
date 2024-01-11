import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:budget_buddy/budget.dart';
import 'package:intl/intl.dart';
import 'package:budget_buddy/features/app/ExpenseCategoriesScreen.dart';

class CreateBudgetScreen extends StatefulWidget {
  @override
  _CreateBudgetScreenState createState() => _CreateBudgetScreenState();
}

class _CreateBudgetScreenState extends State<CreateBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _budgetNameController = TextEditingController();
  DateTime _startDate = DateTime.now();
  String _recurrence = 'Monthly';
  Map<String, bool> _selectedCategories = {};
  Map<String, TextEditingController> _categoryBudgetControllers = {};
  double _totalBudget = 0.0;
  final List<String> _recurrenceOptions = [
    'Monthly',
    'Weekly',
    'Bi-Weekly',
    'Yearly'
  ];

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
      _categoryBudgetControllers[category]!.addListener(_updateTotalBudget);
    }
  }

  @override
  void dispose() {
    _budgetNameController.dispose();
    _categoryBudgetControllers.forEach((key, controller) {
      controller.removeListener(_updateTotalBudget);
      controller.dispose();
    });
    super.dispose();
  }

  void _saveBudget() async {
    if (!_formKey.currentState!.validate()) {
      return; // Form is not valid
    }

    String budgetName = _budgetNameController.text;
    Map<String, double> categoryAllocations = {};
    _selectedCategories.forEach((category, isSelected) {
      if (isSelected) {
        double? amount =
            double.tryParse(_categoryBudgetControllers[category]!.text);
        categoryAllocations[category] = amount ?? 0;
      }
    });

    Budget newBudget = Budget(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: budgetName,
      startDate: _startDate,
      endDate: _calculateEndDate(_startDate, _recurrence),
      categoryAllocations: categoryAllocations,
    );

    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('budgets')
            .doc(user.uid)
            .collection('userBudgets')
            .doc(newBudget.id)
            .set(newBudget.toMap());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Budget saved successfully')),
        );
        Navigator.pop(context);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving budget: $error')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No user logged in')),
      );
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

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a value';
        }
        return null;
      },
    );
  }

  Widget _buildRecurrenceDropdown() {
    return DropdownButtonFormField<String>(
      value: _recurrence,
      onChanged: (String? newValue) {
        setState(() {
          _recurrence = newValue!;
        });
      },
      items: _recurrenceOptions.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: 'Recurrence',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildCategorySelection() {
    return ExpansionTile(
      title: Text("Select Categories"),
      children: _selectedCategories.keys.map((category) {
        return CheckboxListTile(
          title: Row(
            children: [
              Image.asset(
                  ExpenseCategoriesScreen.getImagePathForCategory(category),
                  height: 30,
                  width: 30),
              SizedBox(width: 10),
              Text(category)
            ],
          ),
          value: _selectedCategories[category],
          onChanged: (bool? value) {
            setState(() {
              _selectedCategories[category] = value!;
              if (!value) {
                _categoryBudgetControllers[category]!.clear();
              }
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
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Budget')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_budgetNameController, 'Budget Name'),
              SizedBox(height: 20),
              _buildRecurrenceDropdown(),
              SizedBox(height: 20),
              _buildCategorySelection(),
              SizedBox(height: 20),
              Text('Total Budget: £${_totalBudget.toStringAsFixed(2)}'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveBudget,
                child: Text('Save Budget'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
