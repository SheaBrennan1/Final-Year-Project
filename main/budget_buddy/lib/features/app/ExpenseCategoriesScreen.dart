import 'package:flutter/material.dart';

class ExpenseCategoriesScreen extends StatefulWidget {
  @override
  _ExpenseCategoriesScreenState createState() =>
      _ExpenseCategoriesScreenState();
}

class _ExpenseCategoriesScreenState extends State<ExpenseCategoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> expenseCategories = [
    {"name": "Food", "image": "images/Food.png"},
    {"name": "Shopping", "image": "images/Shopping.png"},
    {"name": "Transportation", "image": "images/Transportation.png"},
    {"name": "Home", "image": "images/Home.png"},
    {"name": "Bills & Fees", "image": "images/Bills & Fees.png"},
    {"name": "Entertainment", "image": "images/Entertainment.png"},
    {"name": "Car", "image": "images/Car.png"},
    {"name": "Travel", "image": "images/Travel.png"},
    {"name": "Family & Personal", "image": "images/Family & Personal.png"},
    {"name": "Health", "image": "images/Health.png"},
    {"name": "Education", "image": "images/Education.png"},
    {"name": "Groceries", "image": "images/Groceries.png"},
    {"name": "Gifts", "image": "images/Gifts.png"},
    {"name": "Sports & Hobbies", "image": "images/Sports & Hobbies.png"},
    {"name": "Beauty", "image": "images/Beauty.png"},
    {"name": "Work", "image": "images/Work.png"},
    {"name": "Other", "image": "images/Other.png"},
    // ... other categories with their corresponding image paths
  ];

  final List<Map<String, dynamic>> incomeCategories = [
    {"name": "Salary", "image": "images/Salary.png"},
    {"name": "Loan", "image": "images/Loan.png"},
    {"name": "Gifts", "image": "images/Gifts.png"},
    {"name": "Other", "image": "images/Other.png"},
    // ... other income categories with their corresponding image paths
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Category"),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Expenses'),
            Tab(text: 'Incomes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildCategoryGrid(expenseCategories),
          buildCategoryGrid(incomeCategories),
        ],
      ),
    );
  }

  Widget buildCategoryGrid(List<Map<String, dynamic>> categories) {
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        String? imagePath = categories[index]["image"];
        Widget imageWidget;

        if (imagePath != null && imagePath.isNotEmpty) {
          imageWidget = Image.asset(imagePath, height: 40);
        } else {
          // Fallback to a default icon if the image path is not provided
          imageWidget = Icon(Icons.category, size: 40);
        }

        return GestureDetector(
          onTap: () {
            Navigator.pop(context, categories[index]);
          },
          child: Card(
            elevation: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                imageWidget,
                SizedBox(height: 8),
                Text(
                  categories[index]["name"] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
