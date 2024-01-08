import 'package:budget_buddy/budgetservice.dart';
import 'package:flutter/material.dart';
import 'package:budget_buddy/budget.dart';
import 'package:budget_buddy/budgetservice.dart';

class CreateBudgetScreen extends StatefulWidget {
  @override
  _CreateBudgetScreenState createState() => _CreateBudgetScreenState();
}

class _CreateBudgetScreenState extends State<CreateBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  Map<String, TextEditingController> _categoryControllers = {};

  @override
  void initState() {
    super.initState();
    // Initialize with one category as a starting point
    _addCategoryController();
  }

  @override
  void dispose() {
    _categoryControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _addCategoryController() {
    var categoryController = TextEditingController();
    setState(() {
      _categoryControllers['Category ${_categoryControllers.length + 1}'] =
          categoryController;
    });
  }

  void _saveBudget() {
    if (_formKey.currentState!.validate()) {
      Map<String, double> categoryAllocations = _categoryControllers.map(
        (category, controller) =>
            MapEntry(category, double.tryParse(controller.text) ?? 0),
      );

      Budget newBudget = Budget(
        id: DateTime.now()
            .millisecondsSinceEpoch
            .toString(), // Generate a unique ID
        month: _selectedMonth,
        year: _selectedYear,
        categoryAllocations: categoryAllocations,
      );

      BudgetService().addOrUpdateBudget(newBudget);
      Navigator.pop(context); // Return to previous screen after saving
    }
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
              // Dropdowns for selecting month and year
              // Iterate over _categoryControllers to create text fields for each category
              ..._categoryControllers.entries.map((entry) {
                return TextFormField(
                  controller: entry.value,
                  decoration: InputDecoration(labelText: entry.key),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        double.tryParse(value) == null) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                );
              }).toList(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addCategoryController,
                child: Text('Add Another Category'),
              ),
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
