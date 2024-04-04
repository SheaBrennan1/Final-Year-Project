import 'package:budget_buddy/add.dart';
import 'package:budget_buddy/budget_screen.dart';
import 'package:budget_buddy/features/app/ExpenseCategoriesScreen.dart';
import 'package:budget_buddy/home.dart';
import 'package:budget_buddy/user_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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

enum ChartType { pie, bar }

enum ViewMode { day, month, year }

class _StatisticsState extends State<Statistics> {
  DateTime selectedDate = DateTime.now();
  Map<String, double> categoryExpenses = {};
  Map<String, double> categoryIncomes = {};
  Map<String, int> categoryColorIndexMap =
      {}; // Added: Map to store category color index
  bool isLoading = true;
  double totalExpenses = 0;
  List<Expense> expenses = [];
  double totalIncomes = 0;
  List<Expense> incomes = [];
  List<Color> colors = [];
  int _segmentedControlValue = 0; // 0 for Expenses, 1 for Incomes
  late ThemeData theme;
  late Color iconColor;
  ChartType _currentChartType = ChartType.pie;
  int index_color = 1;
  final List<Color> predefinedColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
    Colors.cyan,
    Colors.pink,
    Colors.teal,
    Colors.lime,
    Colors.indigo,
    Colors.deepPurple,
    Colors.amber,
    Colors.brown,
    Colors.grey,
    // This color palette offers a broad range of hues. For even more variety, consider custom colors.
  ];

  @override
  void initState() {
    super.initState();
    fetchExpenses();
    fetchIncomes();
    // Remove the theme and iconColor initialization from here
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Now it's safe to fetch theme data using context
    theme = Theme.of(context); // This will correctly fetch the theme data
    iconColor = theme
        .colorScheme.onPrimary; // Adjust based on your theme's color scheme
    // Ensure any widgets that depend on theme or iconColor are updated accordingly
  }

  Color getColorForCategory(String category, Map<String, double> categoryMap) {
    int index = categoryMap.keys.toList().indexOf(category);
    return predefinedColors[index % predefinedColors.length];
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

  void fetchIncomes() async {
    var userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    DatabaseReference ref = FirebaseDatabase.instance.ref('expenses/$userId');

    DataSnapshot snapshot = await ref.get();

    if (snapshot.exists && snapshot.value != null) {
      Map data = Map<String, dynamic>.from(snapshot.value as Map);
      setState(() {
        incomes.clear();
        categoryIncomes.clear();
        totalIncomes = 0;
        data.forEach((key, value) {
          var income = Expense.fromJson(Map<String, dynamic>.from(value), key);
          incomes.add(income);
          if (income.type == 'Income') {
            totalIncomes += income.amount;
          }
        });
        filterIncomesByMonth();
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
      categoryColorIndexMap.clear(); // Reset color index map

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

      int colorIndex = 0;
      for (var category in categoryExpenses.keys) {
        categoryColorIndexMap[category] = colorIndex++;
      }

      colors =
          _generateUniqueColors(categoryExpenses.length); // Regenerate colors
      isLoading = false;
    });
  }

  void filterIncomesByMonth() {
    var monthlyIncomes = incomes.where((income) {
      return income.date.year == selectedDate.year &&
          income.date.month == selectedDate.month;
    }).toList();

    setState(() {
      categoryIncomes.clear();
      totalIncomes = 0;
      categoryColorIndexMap.clear(); // Reset color index map

      for (var income in monthlyIncomes) {
        if (income.type == 'Income') {
          totalIncomes += income.amount;
          categoryIncomes.update(
            income.category,
            (existingAmount) => existingAmount + income.amount,
            ifAbsent: () => income.amount,
          );
        }
      }

      int colorIndex = 0;
      for (var category in categoryIncomes.keys) {
        categoryColorIndexMap[category] = colorIndex++;
      }

      colors =
          _generateUniqueColors(categoryIncomes.length); // Regenerate colors
      isLoading = false;
    });
  }

  void changeMonth(bool next) {
    setState(() {
      int delta = next ? 1 : -1;
      selectedDate = DateTime(
        selectedDate.year,
        selectedDate.month + delta,
        1,
      );
    });
    fetchData(); // Fetch and filter data for the new month
  }

  Map<List<PieChartSectionData>, List<Color>> getPieChartSections() {
    List<PieChartSectionData> sections = [];
    final categoryData =
        _segmentedControlValue == 0 ? categoryExpenses : categoryIncomes;

    // Calculate total amount for the current dataset
    double total = categoryData.values.fold(0, (sum, item) => sum + item);

    // Ensure colors are regenerated based on the number of categories
    colors = _generateUniqueColors(categoryData.length);

    categoryData.forEach((category, amount) {
      double percentage = amount / total * 100;
      Color color =
          getColorForCategory(category, categoryData); // Use the new function
      sections.add(PieChartSectionData(
        color: color,
        value: amount,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xffffffff)),
      ));
    });

    return {sections: predefinedColors}; // Update as necessary for your logic
  }

  Map<List<PieChartSectionData>, List<Color>> getIncomePieChartSections() {
    if (categoryIncomes.isEmpty) {
      return {
        []: [Colors.grey]
      };
    }

    double total = categoryIncomes.values.fold(0, (sum, item) => sum + item);
    List<PieChartSectionData> sections = [];

    categoryIncomes.entries.forEach((entry) {
      Color color = getColorForCategory(entry.key, categoryIncomes);
      final percentage = (entry.value / total) * 100;
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
    });

    return {sections: predefinedColors};
  }

  List<Color> _generateUniqueColors(int count) {
    List<Color> colors = [];
    for (int i = 0; i < count; i++) {
      colors
          .add(HSVColor.fromAHSV(1.0, (360.0 / count) * i, 0.7, 0.9).toColor());
    }
    return colors;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    // Preparing data for charts
    Map<List<PieChartSectionData>, List<Color>> pieChartSectionsAndColors =
        _segmentedControlValue == 0
            ? getPieChartSections()
            : getIncomePieChartSections();
    List<PieChartSectionData> pieChartSections =
        pieChartSectionsAndColors.keys.first;
    List<Color> pieColors = pieChartSectionsAndColors.values.first;
    List<BarChartGroupData> barChartGroups = _prepareBarChartData();

    // Sorting items for the rankings card
    List<MapEntry<String, double>> sortedItems = _segmentedControlValue == 0
        ? categoryExpenses.entries.toList()
        : categoryIncomes.entries.toList();
    sortedItems.sort((a, b) => b.value.compareTo(a.value));
    String title =
        _segmentedControlValue == 0 ? 'Expense Rankings' : 'Income Rankings';
    double total = _segmentedControlValue == 0 ? totalExpenses : totalIncomes;

    return Scaffold(
      appBar: buildAppBar(context),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    _buildChartSelectionButtons(),
                    SizedBox(height: 20),
                    _buildSegmentedControl(),
                    SizedBox(height: 20),
                    _currentChartType == ChartType.pie
                        ? _buildPieChartCard(pieChartSections, pieColors)
                        : _currentChartType == ChartType.bar
                            ? _buildBarChartCard(barChartGroups)
                            : SizedBox.shrink(),
                    SizedBox(height: 20),
                    _buildRankingsCard(sortedItems, pieColors, title, total),
                  ],
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => Add_Screen()));
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      bottomNavigationBar: BottomAppBar(
        // Omitting shape property
        color: Colors.white, // Set your desired color
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.home,
                ),
                onPressed: () {
                  _onItemTapped(0);
                }),
            IconButton(
                icon: Icon(Icons.bar_chart, color: Colors.blue),
                onPressed: () {
                  _onItemTapped(1);
                }),
            IconButton(
                icon: Icon(Icons.savings_sharp),
                onPressed: () {
                  _onItemTapped(2);
                }),
            IconButton(
                icon: Icon(Icons.account_circle),
                onPressed: () {
                  _onItemTapped(3);
                }),
          ],
        ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min, // Use minimum space
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_left, color: Colors.white, size: 30),
            onPressed: () => changeMonth(false),
          ),
          InkWell(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
                selectableDayPredicate: (day) => day.day == 1,
              );
              if (picked != null && picked != selectedDate) {
                setState(() {
                  selectedDate = DateTime(picked.year, picked.month);
                  fetchData();
                });
              }
            },
            child: Text(
              DateFormat('MMMM yyyy').format(selectedDate),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_right, color: Colors.white, size: 30),
            onPressed: () => changeMonth(true),
          ),
        ],
      ),
      backgroundColor: Colors.blue,
      centerTitle: true,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      index_color = index;
    });
    switch (index) {
      case 0:
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) => Home()));
        break;
      case 1:
        break;
      case 2:
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => BudgetScreen()));
        break;
      case 3:
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => UserProfileScreen()));
        break;
    }
  }

  void fetchData() async {
    setState(() => isLoading = true);
    fetchExpenses();
    fetchIncomes();
    // After fetching, filtering happens within fetch methods so no need to call filter methods here.
    setState(() => isLoading = false);
  }

  void filterDataBySelectedMonth() {
    // Assuming expenses and incomes are already populated with the fetched data.
    setState(() {
      categoryExpenses.clear();
      categoryIncomes.clear();
      for (var expense in expenses) {
        if (expense.date.year == selectedDate.year &&
            expense.date.month == selectedDate.month) {
          categoryExpenses.update(
              expense.category, (value) => value + expense.amount,
              ifAbsent: () => expense.amount);
        }
      }
      for (var income in incomes) {
        if (income.date.year == selectedDate.year &&
            income.date.month == selectedDate.month) {
          categoryIncomes.update(
              income.category, (value) => value + income.amount,
              ifAbsent: () => income.amount);
        }
      }
    });
  }

  Widget _buildChartSelectionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
          onPressed: () => setState(() => _currentChartType = ChartType.pie),
          child: Text('Pie Chart'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: _currentChartType == ChartType.pie
                ? Colors.blue // Use Colors.teal for active selection
                : Colors
                    .blueGrey, // Ensure text color contrasts well with the button color
            textStyle: TextStyle(
                fontWeight:
                    FontWeight.bold), // Optional: Enhance text appearance
          ),
        ),
        SizedBox(width: 10), // Spacing between buttons
        ElevatedButton(
          onPressed: () => setState(() => _currentChartType = ChartType.bar),
          child: Text('Bar Chart'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: _currentChartType == ChartType.bar
                ? Colors.blue // Similarly, use Colors.teal for active selection
                : Colors
                    .grey, // This ensures text color is white for readability
            textStyle: TextStyle(
                fontWeight: FontWeight
                    .bold), // Optional: To match Pie Chart button style
          ),
        ),
      ],
    );
  }

  Widget _buildPieChartCard(
      List<PieChartSectionData> sections, List<Color> colors) {
    // Check if there are sections to display
    if (categoryExpenses.isEmpty && _segmentedControlValue == 0 ||
        categoryIncomes.isEmpty && _segmentedControlValue == 1) {
      return Center(
        child: Text(
          "No data for this period",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              _segmentedControlValue == 0
                  ? 'Expense Distribution'
                  : 'Income Distribution',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 48,
                  sectionsSpace: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChartCard(List<BarChartGroupData> barGroups) {
    if (categoryExpenses.isEmpty && _segmentedControlValue == 0 ||
        categoryIncomes.isEmpty && _segmentedControlValue == 1) {
      return Center(
        child: Text(
          "No data for this period",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      );
    }
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              _segmentedControlValue == 0
                  ? 'Expense Distribution'
                  : 'Income Distribution',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  barGroups: barGroups,
                  alignment: BarChartAlignment.spaceAround,
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false, // To remove category names
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles:
                            false, // Assuming you might not want the left Y axis labels
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          // Add padding to move the numbers slightly to the right
                          return Padding(
                            padding: const EdgeInsets.only(
                                left: 8), // Adjust the padding as needed
                            child: Text('£${value.toInt()}',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16)),
                          );
                        },
                        reservedSize:
                            48, // Adjust the reserved size to accommodate the padding
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  barTouchData: BarTouchData(enabled: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _prepareBarChartData() {
    List<BarChartGroupData> barGroups = [];
    final categoryData =
        _segmentedControlValue == 0 ? categoryExpenses : categoryIncomes;
    int index = 0;

    categoryData.forEach((category, amount) {
      // Use getColorForCategory to get color based on the category
      Color color = getColorForCategory(category, categoryData);

      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: amount,
              color: color, // Use predefined color
              width: 16,
            ),
          ],
        ),
      );
      index++;
    });

    return barGroups;
  }

  Widget _buildSegmentedControl() {
    return Container(
      child: CupertinoSegmentedControl<int>(
        children: {
          0: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Expenses')),
          1: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Incomes')),
        },
        onValueChanged: (int value) {
          setState(() {
            _segmentedControlValue = value;
          });
        },
        groupValue: _segmentedControlValue,
        selectedColor: Colors.blue,
        borderColor: Colors.blue,
        pressedColor: Colors.blue.withOpacity(0.5),
      ),
    );
  }

  Widget _buildDistributionCard(
      List<PieChartSectionData> sections, List<Color> colors) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              _segmentedControlValue == 0
                  ? 'Expense Distribution'
                  : 'Income Distribution',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: sections.isNotEmpty
                  ? PieChart(
                      PieChartData(
                        sections: sections,
                        centerSpaceRadius: 48,
                        sectionsSpace: 2,
                      ),
                      key: ValueKey(_segmentedControlValue == 0
                          ? totalExpenses
                          : totalIncomes),
                    )
                  : Center(
                      child: Text('No data available',
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingsCard(List<MapEntry<String, double>> sortedItems,
      List<Color> colors, String title, double total) {
    // Assuming sortedItems are already sorted
    if (sortedItems.isEmpty) {
      // Optionally, return an empty Container, SizedBox.shrink(), or similar if you don't want anything to show up
      return SizedBox.shrink();
    }
    // Instead of passing `colors`, we'll use `predefinedColors` directly inside this method.
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Divider(),
            ListView.separated(
              shrinkWrap: true,
              physics:
                  NeverScrollableScrollPhysics(), // Important for nested ListViews
              itemCount: sortedItems.length,
              itemBuilder: (context, index) {
                final category = sortedItems[index].key;
                final amount = sortedItems[index].value;
                final percentage = (amount / total) * 100;

                // Directly use predefinedColors based on category's original index in the map
                // This ensures that the color matches across different parts of the app
                Color color = getColorForCategory(
                    category,
                    _segmentedControlValue == 0
                        ? categoryExpenses
                        : categoryIncomes);

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color,
                    child: Text('${index + 1}',
                        style: TextStyle(color: Colors.white)),
                  ),
                  title: Text(category, style: TextStyle(fontSize: 16)),
                  trailing: Text(
                    '£${amount.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                );
              },
              separatorBuilder: (context, index) => const Divider(),
            ),
          ],
        ),
      ),
    );
  }
}
