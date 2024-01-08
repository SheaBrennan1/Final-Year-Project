import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  double _monthlyTarget = 0;
  bool _notifyOnTargetApproach = false;
  bool _notifyOnOverspending = false;

  @override
  void initState() {
    super.initState();
    // TODO: Load existing settings from Firebase
  }

  void _saveSettings() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // TODO: Save these settings to Firebase
      // Show a confirmation message
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Settings saved')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration:
                    InputDecoration(labelText: 'Monthly Savings Target (\$)'),
                keyboardType: TextInputType.number,
                onSaved: (value) =>
                    _monthlyTarget = double.tryParse(value ?? '') ?? 0,
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SwitchListTile(
                title: Text('Notify on approaching monthly target'),
                value: _notifyOnTargetApproach,
                onChanged: (bool value) {
                  setState(() {
                    _notifyOnTargetApproach = value;
                  });
                },
              ),
              SwitchListTile(
                title: Text('Notify on overspending'),
                value: _notifyOnOverspending,
                onChanged: (bool value) {
                  setState(() {
                    _notifyOnOverspending = value;
                  });
                },
              ),
              ElevatedButton(
                onPressed: _saveSettings,
                child: Text('Save Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
