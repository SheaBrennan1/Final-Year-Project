import 'package:cloud_firestore/cloud_firestore.dart';
import 'budget.dart';

class BudgetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Assuming your budgets are stored in a collection named 'budgets'
  Future<List<Budget>> getBudgets(String userId) async {
    try {
      var snapshot = await _firestore
          .collection('budgets')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => Budget.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching budgets: $e');
      return [];
    }
  }

  // Method to add or update a budget
  Future<void> addOrUpdateBudget(Budget budget) async {
    try {
      await _firestore.collection('budgets').doc(budget.id).set(budget.toMap());
    } catch (e) {
      print('Error adding or updating budget: $e');
      // Handle the error appropriately
    }
  }
}
