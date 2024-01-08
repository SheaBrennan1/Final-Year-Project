import 'package:flutter/material.dart';
import 'budget.dart';

class BudgetViewScreen extends StatelessWidget {
  final Budget budget;

  BudgetViewScreen({Key? key, required this.budget}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Budget Details for ${budget.month}/${budget.year}')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total Budget: \$${budget.totalBudget.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: budget.categoryAllocations.length,
                itemBuilder: (context, index) {
                  String category =
                      budget.categoryAllocations.keys.elementAt(index);
                  double allocatedAmount =
                      budget.categoryAllocations[category]!;
                  double spentAmount = budget.categorySpending[category] ?? 0;
                  double remaining = allocatedAmount - spentAmount;

                  return Card(
                    child: ListTile(
                      title: Text(category),
                      subtitle: Text(
                          "Allocated: \$${allocatedAmount.toStringAsFixed(2)}"),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Spent: \$${spentAmount.toStringAsFixed(2)}",
                            style: TextStyle(color: Colors.red),
                          ),
                          Text(
                            "Remaining: \$${remaining.toStringAsFixed(2)}",
                            style: TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
