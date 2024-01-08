class Budget {
  String id;
  int month;
  int year;
  Map<String, double> categoryAllocations;
  Map<String, double> categorySpending;

  Budget({
    required this.id,
    required this.month,
    required this.year,
    required this.categoryAllocations,
    this.categorySpending = const {},
  });

  // Getter to calculate the total budget
  double get totalBudget {
    return categoryAllocations.values.fold(0, (sum, amount) => sum + amount);
  }

  // Convert a Budget object into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'month': month,
      'year': year,
      'categoryAllocations': categoryAllocations,
      'categorySpending': categorySpending,
    };
  }

  // Create a Budget object from a Map
  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      month: map['month'],
      year: map['year'],
      categoryAllocations: Map<String, double>.from(map['categoryAllocations']),
      categorySpending: Map<String, double>.from(map['categorySpending']),
    );
  }
}
