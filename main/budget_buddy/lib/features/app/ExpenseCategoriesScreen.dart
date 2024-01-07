import 'package:flutter/material.dart';

final List<Map<String, dynamic>> expenseCategories = [
  {"name": "Food", "image": "images/Food.png", "type": "Expense"},
  {"name": "Shopping", "image": "images/Shopping.png", "type": "Expense"},
  {
    "name": "Transportation",
    "image": "images/Transportation.png",
    "type": "Expense"
  },
  {"name": "Home", "image": "images/Home.png", "type": "Expense"},
  {
    "name": "Bills & Fees",
    "image": "images/Bills & Fees.png",
    "type": "Expense"
  },
  {
    "name": "Entertainment",
    "image": "images/Entertainment.png",
    "type": "Expense"
  },
  {"name": "Car", "image": "images/Car.png", "type": "Expense"},
  {"name": "Travel", "image": "images/Travel.png", "type": "Expense"},
  {
    "name": "Family & Personal",
    "image": "images/Family & Personal.png",
    "type": "Expense"
  },
  {"name": "Health", "image": "images/Health.png", "type": "Expense"},
  {"name": "Education", "image": "images/Education.png", "type": "Expense"},
  {"name": "Groceries", "image": "images/Groceries.png", "type": "Expense"},
  {"name": "Gifts", "image": "images/Gifts.png", "type": "Expense"},
  {
    "name": "Sports & Hobbies",
    "image": "images/Sports & Hobbies.png",
    "type": "Expense"
  },
  {"name": "Beauty", "image": "images/Beauty.png", "type": "Expense"},
  {"name": "Work", "image": "images/Work.png", "type": "Expense"},
  {"name": "Other", "image": "images/Other.png", "type": "Expense"},
  // ... other categories with their corresponding image paths
];

final List<Map<String, dynamic>> incomeCategories = [
  {"name": "Salary", "image": "images/Salary.png", "type": "Income"},
  {"name": "Loan", "image": "images/Loan.png", "type": "Income"},
  {"name": "Gifts", "image": "images/Gifts.png", "type": "Income"},
  {"name": "Other", "image": "images/Other.png", "type": "Income"},
  // ... other income categories with their corresponding image paths
];

class ExpenseCategoriesScreen extends StatefulWidget {
  @override
  _ExpenseCategoriesScreenState createState() =>
      _ExpenseCategoriesScreenState();

  static String getImagePathForCategory(String categoryName) {
    // Try to find the category in expense categories
    var category = expenseCategories
        .firstWhere((cat) => cat['name'] == categoryName, orElse: () => {});

    // If not found in expense categories, try income categories
    if (category.isEmpty) {
      category = incomeCategories
          .firstWhere((cat) => cat['name'] == categoryName, orElse: () => {});
    }

    // Return image path if category is found, else return default image path
    return category.isNotEmpty ? category['image'] : "images/Default.png";
  }
}

class _ExpenseCategoriesScreenState extends State<ExpenseCategoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
            Navigator.pop(context, {
              'name': categories[index]['name'],
              'type': categories[index]['type'],
              'image': categories[index]['image']
            });
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
