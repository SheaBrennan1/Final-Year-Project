import 'package:flutter/material.dart';

final List<Map<String, dynamic>> expenseCategories = [
  {
    "name": "Food",
    "image": "images/Food.png",
    "color": Colors.red,
    "category": "Needs",
    "type": "Expense"
  },
  {
    "name": "Shopping",
    "image": "images/Shopping.png",
    "color": Colors.blue,
    "category": "Wants",
    "type": "Expense"
  },
  {
    "name": "Transport",
    "image": "images/Transportation.png",
    "color": Colors.green,
    "category": "Needs",
    "type": "Expense"
  },
  {
    "name": "Home",
    "image": "images/Home.png",
    "color": Colors.purple,
    "category": "Needs",
    "type": "Expense"
  },
  {
    "name": "Bills & Fees",
    "image": "images/Bills & Fees.png",
    "color": Colors.orange,
    "category": "Needs",
    "type": "Expense"
  },
  {
    "name": "Fun",
    "image": "images/Entertainment.png",
    "color": Colors.yellow,
    "category": "Wants",
    "type": "Expense"
  },
  {
    "name": "Car",
    "image": "images/Car.png",
    "color": Colors.brown,
    "category": "Needs",
    "type": "Expense"
  },
  {
    "name": "Travel",
    "image": "images/Travel.png",
    "color": Colors.teal,
    "category": "Wants",
    "type": "Expense"
  },
  {
    "name": "Personal",
    "image": "images/Family & Personal.png",
    "color": Colors.cyan,
    "category": "Needs",
    "type": "Expense"
  },
  {
    "name": "Health",
    "image": "images/Health.png",
    "color": Colors.lime,
    "category": "Needs",
    "type": "Expense"
  },
  {
    "name": "Education",
    "image": "images/Education.png",
    "color": Colors.indigo,
    "category": "Wants",
    "type": "Expense"
  },
  {
    "name": "Groceries",
    "image": "images/Groceries.png",
    "color": Color.fromARGB(255, 233, 138, 33),
    "category": "Needs",
    "type": "Expense"
  },
  {
    "name": "Gifts",
    "image": "images/Gifts.png",
    "color": Colors.amber,
    "category": "Wants",
    "type": "Expense"
  },
  {
    "name": "Sports",
    "image": "images/Sports & Hobbies.png",
    "color": Colors.deepOrange,
    "category": "Wants",
    "type": "Expense"
  },
  {
    "name": "Beauty",
    "image": "images/Beauty.png",
    "color": Colors.lightGreen,
    "category": "Wants",
    "type": "Expense"
  },
  {
    "name": "Work",
    "image": "images/Work.png",
    "color": Colors.grey,
    "category": "Needs",
    "type": "Expense"
  },
  {
    "name": "Netflix",
    "image": "images/netflix.png",
    "color": Colors.grey,
    "category": "Wants",
    "type": "Expense"
  },
  {
    "name": "Spotify",
    "image": "images/spotify.png",
    "color": Colors.grey,
    "category": "Wants",
    "type": "Expense"
  },
  {
    "name": "Amazon",
    "image": "images/prime.png",
    "color": Colors.grey,
    "category": "Wants",
    "type": "Expense"
  },
  {
    "name": "Savings",
    "image": "images/savings.png",
    "color": Colors.lime,
    "category": "Savings",
    "type": "Expense"
  },
  {
    "name": "Other",
    "image": "images/Other.png",
    "color": Colors.black,
    "category": "Wants",
    "type": "Expense"
  },
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
      return category['color'];
    } else {
      print("Category: $categoryName, Color: ${category['color']}");
      return Colors.grey;
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
