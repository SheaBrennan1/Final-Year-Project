class Budget {
  String id;
  String name;
  DateTime startDate;
  DateTime endDate;
  Map<String, double> categoryAllocations;

  Budget({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.categoryAllocations,
  });

  double get totalBudget {
    return categoryAllocations.values.fold(0, (sum, amount) => sum + amount);
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as String? ?? 'default_id', // Provide a default value
      name: map['name'] as String? ?? 'Unnamed Budget',
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      categoryAllocations: Map<String, double>.from(map['categoryAllocations']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'categoryAllocations': categoryAllocations,
    };
  }

  // Additional methods and properties can be added as needed
}
