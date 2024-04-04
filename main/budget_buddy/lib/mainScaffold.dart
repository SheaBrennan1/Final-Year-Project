import 'package:budget_buddy/budget_screen.dart';
import 'package:budget_buddy/home.dart';
import 'package:budget_buddy/settings.dart';
import 'package:budget_buddy/statistics.dart';
import 'package:budget_buddy/user_profile_screen.dart';
import 'package:budget_buddy/widgets/bottomnavigationbar.dart';
import 'package:flutter/material.dart';

class MainScaffold extends StatefulWidget {
  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _widgetOptions = <Widget>[
    Home(),
    Statistics(),
    BudgetScreen(),
    UserProfileScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      bottomNavigationBar: Bottom(
        initialIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
