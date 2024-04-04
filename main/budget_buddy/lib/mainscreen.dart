import 'package:budget_buddy/add.dart';
import 'package:budget_buddy/budget_screen.dart';
import 'package:budget_buddy/home.dart';
import 'package:budget_buddy/settings.dart';
import 'package:budget_buddy/statistics.dart';
import 'package:budget_buddy/user_profile_screen.dart';
import 'package:budget_buddy/widgets/bottomnavigationbar.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Initialize with the index of the default screen

  final List<Widget> _widgetOptions = [
    Home(),
    Statistics(),
    BudgetScreen(),
    UserProfileScreen(),
    SettingsScreen(),
    Add_Screen(), // Ensure Add_Screen is part of your widget list
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex, // The index of the screen to display
        children: _widgetOptions, // The list of screens
      ),
      // Your FloatingActionButton and BottomNavigationBar setup goes here
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _selectedIndex =
                5; // Adjust this to the index of Add_Screen in _widgetOptions
          });
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Statistics'),
          // Add other BottomNavigationBarItems here
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
