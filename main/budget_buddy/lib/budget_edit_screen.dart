import 'package:budget_buddy/budget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BudgetEditScreen extends StatefulWidget {
  final Budget? budget;

  BudgetEditScreen({Key? key, this.budget}) : super(key: key);

  @override
  _BudgetEditScreenState createState() => _BudgetEditScreenState();
}

class _BudgetEditScreenState extends State<BudgetEditScreen> {
  late TextEditingController _nameController;
  Map<String, TextEditingController> _categoryControllers = {};

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.budget?.name ?? '');

    widget.budget?.categoryAllocations.forEach((category, allocatedAmount) {
      _categoryControllers[category] =
          TextEditingController(text: allocatedAmount.toString());
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  void _saveBudget() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    Map<String, double> categoryAllocations = {};
    _categoryControllers.forEach((category, controller) {
      double? amount = double.tryParse(controller.text);
      if (amount != null) {
        categoryAllocations[category] = amount;
      }
    });

    Budget budget = Budget(
      id: widget.budget?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      startDate: widget.budget?.startDate ?? DateTime.now(),
      endDate: widget.budget?.endDate ?? DateTime.now(),
      categoryAllocations: categoryAllocations,
    );

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No user logged in')),
      );
      return;
    }

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final String userId = user.uid;

    try {
      await firestore
          .collection('budgets')
          .doc(userId)
          .collection('userBudgets')
          .doc(budget.id)
          .set(budget.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Budget saved successfully')),
      );
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving budget: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Budget')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Budgets Name'),
              ),
              ..._categoryControllers.entries.map((entry) {
                return TextField(
                  controller: entry.value,
                  decoration:
                      InputDecoration(labelText: '${entry.key} Allocation (£)'),
                  keyboardType: TextInputType.number,
                );
              }).toList(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveBudget,
                child: Text('Save Budget'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "editBudgetFAB",
        onPressed: _saveBudget,
        child: Icon(Icons.save),
      ),
    );
  }
}
