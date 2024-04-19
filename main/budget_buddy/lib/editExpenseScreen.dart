import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:budget_buddy/expense_model.dart';
import 'package:budget_buddy/features/app/ExpenseCategoriesScreen.dart';
import 'package:intl/intl.dart';

class EditExpenseScreen extends StatefulWidget {
  final Expense expense;

  const EditExpenseScreen({Key? key, required this.expense}) : super(key: key);

  @override
  _EditExpenseScreenState createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  String? _selectedCategory;
  DateTime? _selectedDate;
  String? _selectedRecurrence;
  String? _selectedReminder;

  final List<String> _recurrenceOptions = [
    'Never',
    'Every Minute',
    'Every Day',
    'Every 3 Days',
    'Every Week'
  ];

  final List<String> _reminderOptions = [
    'Never',
    '1 Minute Before',
    '1 Day Before',
    '3 Days Before',
    '1 Week Before'
  ];

  @override
  void initState() {
    super.initState();
    _amountController =
        TextEditingController(text: widget.expense.amount.toString());
    _descriptionController =
        TextEditingController(text: widget.expense.description);
    _selectedCategory = widget.expense.category;
    _selectedDate = widget.expense.date;
    _selectedRecurrence = widget.expense.recurrence;
    _selectedReminder = widget.expense.reminder;
  }

  void updateExpense() async {
    Expense updatedExpense = Expense(
      key: widget.expense.key,
      category: _selectedCategory!,
      amount: double.parse(_amountController.text),
      description: _descriptionController.text,
      date: _selectedDate!,
      type: widget.expense.type,
      recurrence: _selectedRecurrence!,
      reminder: _selectedReminder!,
    );

    DatabaseReference ref = FirebaseDatabase.instance.ref().child("expenses");
    String userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    await ref
        .child(userId)
        .child(widget.expense.key!)
        .update(updatedExpense.toJson());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Expense'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              ListTile(
                title: Text(
                    'Category: ${_selectedCategory ?? "Select a Category"}'),
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ExpenseCategoriesScreen()),
                  );
                  if (result != null && result is Map) {
                    setState(() {
                      _selectedCategory = result['name'];
                    });
                  }
                },
              ),
              ListTile(
                title: Text(
                    'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate ?? DateTime.now())}'),
                onTap: () async {
                  DateTime? newDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (newDate != null) {
                    setState(() {
                      _selectedDate = newDate;
                    });
                  }
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedRecurrence,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRecurrence = newValue!;
                  });
                },
                items: _recurrenceOptions
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Recurrence',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_selectedRecurrence !=
                  'Never') // Only show reminders if recurrence is not 'Never'
                DropdownButtonFormField<String>(
                  value: _selectedReminder,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedReminder = newValue!;
                    });
                  },
                  items: _reminderOptions
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Reminder',
                    border: OutlineInputBorder(),
                  ),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: updateExpense,
                child: Text('Update Expense'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
