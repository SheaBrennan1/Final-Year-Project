import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  String? key; // Unique identifier for the expense
  String category;
  String type; // 'Income' or 'Expense'
  double amount;
  String recurrence; // Recurrence pattern
  String reminder; // Reminder setting
  String description;
  DateTime date;

  Expense({
    this.key,
    required this.category,
    required this.type,
    required this.amount,
    required this.recurrence,
    required this.reminder,
    required this.description,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'type': type,
      'amount': amount,
      'recurrence': recurrence,
      'reminder': reminder,
      'description': description,
      'date': date.toIso8601String(),
    };
  }

  static Expense fromJson(Map<String, dynamic> json, String key) {
    return Expense(
      key: key,
      category: json['category'],
      type: json['type'],
      amount: (json['amount'] as num).toDouble(),
      recurrence: json['recurrence'],
      reminder: json['reminder'],
      description: json['description'],
      date: DateTime.parse(json['date']),
    );
  }
}
