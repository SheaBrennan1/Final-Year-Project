import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class TargetSettingsScreen extends StatefulWidget {
  @override
  _TargetSettingsScreenState createState() => _TargetSettingsScreenState();
}

class _TargetSettingsScreenState extends State<TargetSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  double _targetAmount = 0.0;
  double _totalSavings = 0.0; // Total amount saved so far
  bool _enableNotifications = false;
  String _notificationTime = '08:00';
  bool _hasSetTarget = false; // To check if the target is already set

  @override
  void initState() {
    super.initState();
    _fetchSettings();
    _fetchTotalSavings();
  }

  Future<void> _fetchSettings() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DatabaseReference settingsRef = FirebaseDatabase.instance
          .ref('userSettings/${user.uid}/targetAmount');
      DataSnapshot snapshot = await settingsRef.get();
      if (snapshot.exists && snapshot.value != null) {
        setState(() {
          var value = snapshot.value;
          if (value is int) {
            _targetAmount = value.toDouble();
          } else if (value is double) {
            _targetAmount = value;
          } else {
            _targetAmount = 0.0;
          }
          _hasSetTarget = true; // Set to true if target amount exists
        });
      } else {
        setState(() {
          _hasSetTarget = false; // Set to false if target amount does not exist
        });
      }
    }
  }

  Future<void> _fetchTotalSavings() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DatabaseReference expensesRef =
          FirebaseDatabase.instance.ref('expenses/${user.uid}');

      DateTime startDate = DateTime(2024, 1, 1);
      DateTime endDate = DateTime(2025, 1, 1);
      double totalBalance = 0.0;

      for (DateTime date = startDate;
          date.isBefore(endDate);
          date = DateTime(date.year, date.month + 1, 1)) {
        DataSnapshot snapshot = await expensesRef
            .orderByChild('date')
            .startAt(DateFormat('yyyy-MM-dd').format(date))
            .endAt(DateFormat('yyyy-MM-dd')
                .format(DateTime(date.year, date.month + 1, 0)))
            .get();

        if (snapshot.exists && snapshot.value != null) {
          Map<dynamic, dynamic> expenses =
              Map<dynamic, dynamic>.from(snapshot.value as Map);
          double monthlyIncome = 0.0;
          double monthlyExpenses = 0.0;

          expenses.forEach((key, value) {
            if (value['type'] == 'Income') {
              monthlyIncome += value['amount'];
            } else if (value['type'] == 'Expense') {
              monthlyExpenses += value['amount'];
            }
          });

          totalBalance += (monthlyIncome - monthlyExpenses);
        }
      }

      setState(() {
        _totalSavings = totalBalance;
      });
    }
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DatabaseReference settingsRef =
            FirebaseDatabase.instance.ref('userSettings/${user.uid}');
        await settingsRef.set({
          'targetAmount': _targetAmount,
          'enableNotifications': _enableNotifications,
          'notificationTime': _notificationTime,
        }).then((_) {
          setState(() {
            _hasSetTarget = true; // Update the flag after saving
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Settings saved successfully!')),
          );
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save settings: $error')),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double progress = _totalSavings / (_targetAmount > 0 ? _targetAmount : 1);

    return Scaffold(
      appBar: AppBar(
        title: Text('Set Targets'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _hasSetTarget
            ? _buildProgressDisplay(progress)
            : _buildSettingsForm(),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchSettings();
  }

  Widget _buildSettingsForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (!_hasSetTarget) // Only show this field if no target is set
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Target Amount (£)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a target amount';
                }
                return null;
              },
              onSaved: (value) {
                _targetAmount = double.parse(value!);
              },
            ),
          SwitchListTile(
            title: Text('Enable Notifications'),
            value: _enableNotifications,
            onChanged: (bool value) {
              setState(() {
                _enableNotifications = value;
              });
            },
          ),
          Visibility(
            visible: _enableNotifications,
            child: TextFormField(
              decoration: InputDecoration(
                labelText: 'Notification Time',
                hintText: 'HH:mm',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.datetime,
              validator: (value) {
                if (_enableNotifications && (value == null || value.isEmpty)) {
                  return 'Please enter a notification time';
                }
                return null;
              },
              onSaved: (value) {
                _notificationTime = value!;
              },
            ),
          ),
          ElevatedButton(
            onPressed: _saveSettings,
            child: Text('Save Settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDisplay(double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
        SizedBox(height: 10),
        Text(
          'Progress: £${_totalSavings.toStringAsFixed(2)} / £${_targetAmount.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.subtitle1,
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _hasSetTarget = false; // Allow user to set a new target
            });
          },
          child: Text('Set New Target'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

void main() => runApp(MaterialApp(home: TargetSettingsScreen()));
