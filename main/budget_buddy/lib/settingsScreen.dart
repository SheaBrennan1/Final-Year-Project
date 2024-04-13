import 'package:budget_buddy/add.dart';
import 'package:budget_buddy/budget_screen.dart';
import 'package:budget_buddy/configure_warnings.dart';
import 'package:budget_buddy/faq.dart';
import 'package:budget_buddy/feedback.dart';
import 'package:budget_buddy/home.dart';
import 'package:budget_buddy/statistics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;
  int index_color = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold, // Adjust as needed
          ),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _settingsCategory('Account', [
              _customListTile(
                  title: 'Wipe All Expenses',
                  icon: Icons.delete,
                  onTap: _wipeAllExpenses),
            ]),
            _settingsCategory('Preferences', [
              _warningsTile(),
              _feedbackTile(),
              _faqTile(),
            ]),
            // Additional categories and settings can be added here
          ],
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

  void _configureWarnings() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ConfigureWarningsPage()));
  }

  Widget _settingsCategory(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(title,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        Card(
          elevation: 2,
          color: Colors
              .white, // Adjust based on UserProfileScreen's theme, if necessary
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _feedbackTile() {
    return _customListTile(
      title: 'Feedback',
      icon: Icons.feedback,
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => FeedbackPage()));
      },
    );
  }

  Widget _faqTile() {
    return _customListTile(
      title: 'FAQ',
      icon: Icons.description_outlined,
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => FAQScreen()));
      },
    );
  }

  Widget _warningsTile() {
    return _customListTile(
      title: 'Configure Warnings and Notifications',
      icon: Icons.warning,
      onTap: _configureWarnings,
    );
  }

  Future<void> _showConfirmationDialog() async {
    // Implementation remains similar but ensures the dialog's UI is consistent with the app's theme
  }

  Widget _customListTile(
      {required String title, required IconData icon, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue), // Match UserProfileScreen theme
      title: Text(title, style: TextStyle(fontSize: 18)),
      onTap: onTap,
      trailing: Icon(Icons.arrow_forward_ios,
          size: 16, color: Colors.blue), // Consistent color scheme
    );
  }

  Future<void> _wipeAllExpenses() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      bool? shouldWipe = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm'),
            content: Text('Are you sure you want to wipe all expenses?'),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context)
                      .pop(false); // User pressed Cancel button
                },
              ),
              TextButton(
                child: Text('Yes'),
                onPressed: () {
                  Navigator.of(context).pop(true); // User pressed Yes button
                },
              ),
            ],
          );
        },
      );

      if (shouldWipe == true) {
        DatabaseReference expensesRef =
            FirebaseDatabase.instance.ref('expenses/${user.uid}');
        await expensesRef.remove().then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('All expenses wiped successfully!')),
          );
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to wipe expenses: $error')),
          );
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in')),
      );
    }
  }
}
