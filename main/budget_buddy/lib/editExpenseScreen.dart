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
  late String _selectedCategory;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _amountController =
        TextEditingController(text: widget.expense.amount.toString());
    _descriptionController =
        TextEditingController(text: widget.expense.description);
    _selectedCategory = widget.expense.category;
    _selectedDate = widget.expense.date;
  }

  void updateExpense() async {
    Expense updatedExpense = Expense(
      key: widget.expense.key,
      category: _selectedCategory,
      amount: double.parse(_amountController.text),
      description: _descriptionController.text,
      date: _selectedDate,
      type: widget.expense.type,
      recurrence: widget.expense.recurrence,
      reminder: widget.expense.reminder,
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
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount',
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
              ),
            ),
            ListTile(
              title: Text('Category: $_selectedCategory'),
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
                  'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
              onTap: () async {
                DateTime? newDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateExpense,
              child: Text('Update Expense'),
            )
          ],
        ),
      ),
    );
  }
}
