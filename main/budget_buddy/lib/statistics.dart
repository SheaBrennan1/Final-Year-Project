import 'package:budget_buddy/features/app/ExpenseCategoriesScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:budget_buddy/expense_model.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';

class Statistics extends StatefulWidget {
  Statistics() : super(key: ValueKey(DateTime.now()));

  @override
  _StatisticsState createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  DateTime selectedDate = DateTime.now();
  Map<String, double> categoryExpenses = {};
  bool isLoading = true;
  double totalExpenses = 0;
  List<Expense> expenses = [];
  List<Color> colors = [];

  @override
  void initState() {
    super.initState();
    fetchExpenses();
  }

  void fetchExpenses() async {
    var userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    DatabaseReference ref = FirebaseDatabase.instance.ref('expenses/$userId');

    DataSnapshot snapshot = await ref.get();

    if (snapshot.exists && snapshot.value != null) {
      Map data = Map<String, dynamic>.from(snapshot.value as Map);
      setState(() {
        expenses.clear();
        categoryExpenses.clear();
        totalExpenses = 0;
        data.forEach((key, value) {
          var expense = Expense.fromJson(Map<String, dynamic>.from(value), key);
          expenses.add(expense);
          if (expense.type == 'Expense') {
            totalExpenses += expense.amount;
          }
        });
        filterExpensesByMonth();
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  void filterExpensesByMonth() {
    var monthlyExpenses = expenses.where((expense) {
      return expense.date.year == selectedDate.year &&
          expense.date.month == selectedDate.month;
    }).toList();

    setState(() {
      categoryExpenses.clear();
      totalExpenses = 0;
      for (var expense in monthlyExpenses) {
        if (expense.type == 'Expense') {
          totalExpenses += expense.amount;
          categoryExpenses.update(
            expense.category,
            (existingAmount) => existingAmount + expense.amount,
            ifAbsent: () => expense.amount,
          );
        }
      }
      colors =
          _generateUniqueColors(categoryExpenses.length); // Regenerate colors
      isLoading = false;
    });
  }

  void changeMonth(bool next) {
    setState(() {
      if (next) {
        selectedDate = DateTime(selectedDate.year, selectedDate.month + 1, 1);
      } else {
        selectedDate = DateTime(selectedDate.year, selectedDate.month - 1, 1);
      }
      fetchExpenses();
    });
  }

  Map<List<PieChartSectionData>, List<Color>> getPieChartSections() {
    if (categoryExpenses.isEmpty) {
      return {
        []: [Colors.grey]
      };
    }

    double total = categoryExpenses.values.fold(0, (sum, item) => sum + item);
    List<PieChartSectionData> sections = [];

    int index = 0;
    categoryExpenses.entries.forEach((entry) {
      final percentage = (entry.value / total) * 100;
      final color = colors[index % colors.length]; // Safely reference color
      sections.add(PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xffffffff)),
        titlePositionPercentageOffset: 0.6,
      ));
      index++;
    });

    return {sections: colors};
  }

  List<Color> _generateUniqueColors(int count) {
    List<Color> colors = [];
    for (int i = 0; i < count; i++) {
      colors
          .add(HSVColor.fromAHSV(1.0, (360.0 / count) * i, 0.6, 0.7).toColor());
    }
    return colors;
  }

  @override
  Widget build(BuildContext context) {
    Map<List<PieChartSectionData>, List<Color>> pieChartSectionsAndColors =
        getPieChartSections();
    List<PieChartSectionData> pieChartSections =
        pieChartSectionsAndColors.keys.first;
    List<Color> colors = pieChartSectionsAndColors.values.first;

    // Sort expenses for ranking
    List<MapEntry<String, double>> sortedExpenses = categoryExpenses.entries
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Statistics for ${DateFormat('MMMM yyyy').format(selectedDate)}'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => changeMonth(false),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios),
            onPressed: () => changeMonth(true),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              'Expense Distribution',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 20),
                            SizedBox(
                              height: 300,
                              child: pieChartSections.isNotEmpty
                                  ? PieChart(
                                      PieChartData(
                                        sections: pieChartSections,
                                        centerSpaceRadius: 5,
                                        sectionsSpace: 2,
                                      ),
                                      key: ValueKey(
                                          totalExpenses), // Unique key for the PieChart
                                    )
                                  : Center(child: Text('No data')),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Expense Rankings',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Divider(),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: sortedExpenses.length,
                              itemBuilder: (context, index) {
                                final category = sortedExpenses[index].key;
                                final amount = sortedExpenses[index].value;
                                final percentage =
                                    (amount / totalExpenses) * 100;
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        colors[index % colors.length],
                                    child: Text((index + 1).toString()),
                                  ),
                                  title: Text(category),
                                  trailing: Text(
                                    '${NumberFormat.currency(symbol: '\$').format(amount)} (${percentage.toStringAsFixed(2)}%)',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
