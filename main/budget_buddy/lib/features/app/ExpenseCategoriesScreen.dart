import 'package:flutter/material.dart';

final List<Map<String, dynamic>> expenseCategories = [
  {
    "name": "Food",
    "image": "images/Food.png",
    "color": Colors.red,
    "type": "Expense"
  },
  {
    "name": "Shopping",
    "image": "images/Shopping.png",
    "color": Colors.blue,
    "type": "Expense"
  },
  {
    "name": "Transportation",
    "image": "images/Transportation.png",
    "color": Colors.green,
    "type": "Expense"
  },
  {
    "name": "Home",
    "image": "images/Home.png",
    "color": Colors.purple,
    "type": "Expense"
  },
  {
    "name": "Bills & Fees",
    "image": "images/Bills & Fees.png",
    "color": Colors.orange,
    "type": "Expense"
  },
  {
    "name": "Entertainment",
    "image": "images/Entertainment.png",
    "color": Colors.yellow,
    "type": "Expense"
  },
  {
    "name": "Car",
    "image": "images/Car.png",
    "color": Colors.brown,
    "type": "Expense"
  },
  {
    "name": "Travel",
    "image": "images/Travel.png",
    "color": Colors.teal,
    "type": "Expense"
  },
  {
    "name": "Family & Personal",
    "image": "images/Family & Personal.png",
    "color": Colors.cyan,
    "type": "Expense"
  },
  {
    "name": "Health",
    "image": "images/Health.png",
    "color": Colors.lime,
    "type": "Expense"
  },
  {
    "name": "Education",
    "image": "images/Education.png",
    "color": Colors.indigo,
    "type": "Expense"
  },
  {
    "name": "Groceries",
    "image": "images/Groceries.png",
    "color": Color.fromARGB(255, 233, 138, 33),
    "type": "Expense"
  },
  {
    "name": "Gifts",
    "image": "images/Gifts.png",
    "color": Colors.amber,
    "type": "Expense"
  },
  {
    "name": "Sports & Hobbies",
    "image": "images/Sports & Hobbies.png",
    "color": Colors.deepOrange,
    "type": "Expense"
  },
  {
    "name": "Beauty",
    "image": "images/Beauty.png",
    "color": Colors.lightGreen,
    "type": "Expense"
  },
  {
    "name": "Work",
    "image": "images/Work.png",
    "color": Colors.grey,
    "type": "Expense"
  },
  {
    "name": "Other",
    "image": "images/Other.png",
    "color": Colors.black,
    "type": "Expense"
  },
  // ... other categories with their corresponding image paths
];

final List<Map<String, dynamic>> incomeCategories = [
  {
    "name": "Salary",
    "image": "images/Salary.png",
    "color": Colors.blueGrey,
    "type": "Income"
  },
  {
    "name": "Loan",
    "image": "images/Loan.png",
    "color": Colors.lightBlue,
    "type": "Income"
  },
  {
    "name": "Gifts",
    "image": "images/Gifts.png",
    "color": Colors.purpleAccent,
    "type": "Income"
  },
  {
    "name": "Other",
    "image": "images/Other.png",
    "color": Colors.deepPurple,
    "type": "Income"
  },
  // ... other income categories with their corresponding image paths
];

class ExpenseCategoriesScreen extends StatefulWidget {
  @override
  _ExpenseCategoriesScreenState createState() =>
      _ExpenseCategoriesScreenState();

  static String getImagePathForCategory(String categoryName) {
    var category = expenseCategories
        .firstWhere((cat) => cat['name'] == categoryName, orElse: () => {});

    if (category.isEmpty) {
      category = incomeCategories
          .firstWhere((cat) => cat['name'] == categoryName, orElse: () => {});
    }

    return category.isNotEmpty ? category['image'] : "images/Default.png";
  }

  static Color getColorForCategory(String categoryName) {
    var category = expenseCategories
        .firstWhere((cat) => cat['name'] == categoryName, orElse: () => {});

    if (category.isEmpty) {
      category = incomeCategories
          .firstWhere((cat) => cat['name'] == categoryName, orElse: () => {});
    }

    if (category.isNotEmpty && category.containsKey('color')) {
      print("Category: $categoryName, Color: ${category['color']}");
      return category['color']; // return the color directly
    } else {
      print("Category: $categoryName, Color: ${category['color']}");
      return Colors.grey; // Default color if no match found or color is null
    }
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
