import 'package:budget_buddy/add.dart';
import 'package:budget_buddy/budget_screen.dart';
import 'package:budget_buddy/home.dart';
import 'package:budget_buddy/statistics.dart';
import 'package:flutter/material.dart';

class FAQScreen extends StatefulWidget {
  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  int index_color = 3;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FAQ',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: EdgeInsets.all(8.0),
        children: [
          ExpansionTile(
            title: Text("How to use the budget feature?"),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  "To use the budget feature, navigate to the 'Budgets' section from the main menu. Click on 'Create a new budget' to start setting up your budget. You can specify the budget name, total amount, start and end dates, and allocate amounts to different categories. Once saved, your budget will be visible in the 'Budgets' section, where you can track your spending against it.",
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text("How to track expenses?"),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  "Track your expenses/incomes by navigating to the 'add' buttons in the middle of the navigation bar. Here, you can add new expenses by specifying the amount, category, and date. You can also edit or delete existing expenses. The app will automatically categorize and deduct these from your budget, giving you a real-time view of your spending.",
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text("How to set financial goals?"),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  "Set financial goals by accessing the 'Goals and Targets' feature in the app. Here, you can add a new goal by detailing the target amount. The app will help you track your progress towards these goals, providing insights and reminders along the way.",
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text("What is the 50/30/20 budget rule?"),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  "The 50/30/20 budget rule is a simple guideline to manage your finances. It suggests you should spend approximately 50% of your after-tax income on necessities (like housing and food), 30% on wants (like dining out and entertainment), and save the remaining 20% (for emergencies, savings, and debt repayment). Our app can automatically create a budget for you based on this rule once you input your total income.",
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text("How can I edit or delete an expense?"),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  "To edit or delete an expense, navigate to the 'Home' section where your recent expenses are listed. Tap on the more options icon (three vertical dots) next to the expense you wish to modify. Select 'Edit' to update the details of your expense or 'Delete' to remove it from your records.",
                ),
              ),
            ],
          ),
          ExpansionTile(
            title:
                Text("How do I view my spending over different time periods?"),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  "In the 'Home' section, you can view your spending for a day, month, or year by selecting the respective option at the top of the screen. To pick a specific date or month, tap on the date displayed and choose the desired period from the calendar.",
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text("How does the statistics page help me?"),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  "The 'Statistics' page provides visual insights into your financial activities. You can view your expenses and income distribution through pie or bar charts, helping you understand where your money is going. Toggle between the expenses and income view to get detailed information about each category.",
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text("What is the purpose of the feedback feature?"),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  "The feedback feature allows you to communicate directly with the app developers. Whether you have a question, encountered a bug, or want to request a new feature, your feedback is invaluable for improving the app's functionality and user experience. Select a topic, provide details, and submit.",
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text("Can I add a new expense category?"),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  "Currently, the app provides a predefined set of categories for managing your expenses and income. If you have suggestions for new categories, please use the feedback feature to let us know, and we'll consider adding them in future updates.",
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text("How can I change my profile picture?"),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  "To change your profile picture, navigate to the 'Edit Profile' section from your profile page. There, you can choose to either upload a photo from your gallery or take a new picture using your camera. After selecting or taking a photo, it will be automatically uploaded and set as your new profile picture.",
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text("How do I update my username?"),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  "In the 'Edit Profile' section, you'll find an option to update your username. Simply enter your new username into the field provided and tap the 'Update Username' button. Your username will be updated across the app immediately.",
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text("What formats are supported for profile pictures?"),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  "The app supports most common image formats for profile pictures, including JPG, PNG, and GIF. Please ensure the photo is not too large, as there might be upload size limitations.",
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text("How do I ensure my profile picture looks its best?"),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  "For the best results, use a clear, well-lit photo where your face is easily recognizable. Square photos work best, as the app may crop your photo to fit into a circular frame. Avoid using photos with busy backgrounds to keep the focus on you.",
                ),
              ),
            ],
          ),
        ],
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
                icon: Icon(Icons.bar_chart),
                onPressed: () {
                  _onItemTapped(1);
                }),
            IconButton(
                icon: Icon(Icons.savings_sharp),
                onPressed: () {
                  _onItemTapped(2);
                }),
            IconButton(
                icon: Icon(Icons.account_circle, color: Colors.blue),
                onPressed: () {
                  _onItemTapped(3);
                }),
          ],
        ),
      ),
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
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => Statistics()));
        break;
      case 2:
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => BudgetScreen()));
        break;
      case 3:
        break;
    }
  }
}
