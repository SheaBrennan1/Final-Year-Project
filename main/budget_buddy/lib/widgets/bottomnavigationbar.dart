import 'package:budget_buddy/add.dart';
import 'package:budget_buddy/budget_screen.dart';
import 'package:budget_buddy/home.dart';
import 'package:budget_buddy/statistics.dart';
import 'package:flutter/material.dart';
import 'package:budget_buddy/user_profile_screen.dart';

class Bottom extends StatefulWidget {
  const Bottom({Key? key}) : super(key: key);

  @override
  State<Bottom> createState() => _BottomState();
}

class _BottomState extends State<Bottom> {
  int index_color = 0;

  // Explicitly define the list as a list of widgets
  List<Widget> Screen = [
    Home(),
    Statistics(),
    BudgetScreen(),
    UserProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Screen[index_color],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => Add_Screen()));
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xff368983),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.only(top: 7.5, bottom: 7.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Home
              _navBarItem(icon: Icons.home, index: 0),
              // Statistics
              _navBarItem(icon: Icons.bar_chart_outlined, index: 1),
              SizedBox(width: 20),
              // Wallet or another option
              _navBarItem(
                  icon: Icons.account_balance_wallet_outlined, index: 2),
              // Profile
              _navBarItem(
                  icon: Icons.person_outline,
                  index: 3), // Changed icon for profile
            ],
          ),
        ),
      ),
    );
  }

  Widget _navBarItem({required IconData icon, required int index}) {
    return GestureDetector(
      onTap: () => setState(() => index_color = index),
      child: Icon(
        icon,
        size: 30,
        color: index_color == index ? Color(0xff368983) : Colors.grey,
      ),
    );
  }
}
