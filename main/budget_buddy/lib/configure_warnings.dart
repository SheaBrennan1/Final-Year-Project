import 'package:budget_buddy/add.dart';
import 'package:budget_buddy/budget_screen.dart';
import 'package:budget_buddy/home.dart';
import 'package:budget_buddy/statistics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigureWarningsPage extends StatefulWidget {
  @override
  _ConfigureWarningsPageState createState() => _ConfigureWarningsPageState();
}

class _ConfigureWarningsPageState extends State<ConfigureWarningsPage> {
  bool spendingWarningEnabled = false;
  double spendingThreshold = 100.0;

  bool budgetThresholdWarningEnabled = false;

  bool goalWarningEnabled = false;
  double goalThresholdPercentage = 90.0;

  int index_color = 3;

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      spendingWarningEnabled = prefs.getBool('spendingWarningEnabled') ?? false;
      budgetThresholdWarningEnabled =
          prefs.getBool('budgetThresholdWarningEnabled') ?? false;
      goalWarningEnabled = prefs.getBool('goalWarningEnabled') ?? false;
      // Assuming the thresholds are also stored, you can load them here as well
    });
  }

  Future<void> setPreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configure Warnings'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: Text("Enable Spending Goal Notifications"),
              subtitle: Text("Receive notification when saving is reached"),
              value: spendingWarningEnabled,
              onChanged: (bool value) async {
                setState(() {
                  spendingWarningEnabled = value;
                });
                await setPreference('spendingWarningEnabled', value);

                final user = FirebaseAuth.instance.currentUser;

                if (user != null) {
                  await FirebaseFirestore.instance
                      .collection('userSettings')
                      .doc(user.uid)
                      .set({'spendingGoalNotificationsEnabled': value},
                          SetOptions(merge: true));
                } else {
                  print("User not signed in. Cannot update user settings.");
                }
              },
            ),
            Divider(),
            SwitchListTile(
              title: Text("Enable Budget Warnings"),
              subtitle:
                  Text("Toggle to receive or disable budget usage warnings."),
              value: budgetThresholdWarningEnabled,
              onChanged: (bool value) async {
                setState(() {
                  budgetThresholdWarningEnabled = value;
                });
                await setPreference('budgetThresholdWarningEnabled', value);

                // Assuming _auth is your FirebaseAuth instance
                final user = FirebaseAuth.instance.currentUser;

                if (user != null) {
                  // Use the UID of the currently signed-in user
                  await FirebaseFirestore.instance
                      .collection('userSettings')
                      .doc(user.uid)
                      .set({'budgetWarningsEnabled': value},
                          SetOptions(merge: true));
                } else {
                  print("User not signed in. Cannot update user settings.");
                }
              },
            ),
            Divider(),
            SwitchListTile(
              title: Text("Enable Goal Warnings"),
              subtitle: Text(
                  "Receive warnings when you are close to reaching a financial goal."),
              value: goalWarningEnabled,
              onChanged: (bool value) {
                setState(() {
                  goalWarningEnabled = value;
                });
                setPreference('goalWarningEnabled', value);
              },
            ),
            if (goalWarningEnabled)
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: TextFormField(
                  initialValue: goalThresholdPercentage.toString(),
                  decoration: InputDecoration(
                    labelText: 'Goal Threshold (%)',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (String value) {
                    goalThresholdPercentage = double.tryParse(value) ?? 90.0;
                  },
                ),
              ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Logic to save configuration
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Warning configurations saved successfully!'),
                  ));
                },
                child: Text('Save Configurations'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
            ),
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
}
