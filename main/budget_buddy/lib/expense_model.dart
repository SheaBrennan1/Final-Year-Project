class Expense {
  String? key; // Add a key field
  String category;
  String type; // Income or Expense
  double amount;
  String recurrence;
  String description;
  DateTime date;

  Expense({
    this.key, // Include key in the constructor
    required this.category,
    required this.type,
    required this.amount,
    required this.recurrence,
    required this.description,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'type': type,
      'amount': amount,
      'recurrence': recurrence,
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
      recurrence: json['recurrence'], // Add this line
      description: json['description'],
      date: DateTime.parse(json['date']),
    );
  }
}
