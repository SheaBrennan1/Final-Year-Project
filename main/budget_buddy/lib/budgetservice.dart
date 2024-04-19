import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'budget.dart';

class BudgetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Budget>> getBudgets(String userId) async {
    try {
      var snapshot = await _firestore
          .collection('budgets')
          .doc(userId)
          .collection('userBudgets')
          .get();

      return snapshot.docs
          .map((doc) => Budget.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching budgets: $e');
      return [];
    }
  }

  Future<void> addOrUpdateBudget(Budget budget) async {
    try {
      await _firestore.collection('budgets').doc(budget.id).set(budget.toMap());
    } catch (e) {
      print('Error adding or updating budget: $e');
    }
  }

  Future<double> getCategorySpending(
      String userId, String budgetId, String category) async {
    try {
      var expensesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .where('budgetId', isEqualTo: budgetId)
          .where('category', isEqualTo: category)
          .get();

      return expensesSnapshot.docs.fold(
          0.0,
          (double sum, DocumentSnapshot doc) {
            var data = doc.data() as Map<String, dynamic>?;
            return sum + (data?['amount'] as num? ?? 0).toDouble();
          } as FutureOr<double> Function(FutureOr<double> previousValue,
              QueryDocumentSnapshot<Map<String, dynamic>> element));
    } catch (e) {
      print('Error fetching category spending: $e');
      return 0.0;
    }
  }
}
