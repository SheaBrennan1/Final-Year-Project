// bottom_nav_bar_util.dart
import 'package:flutter/material.dart';
import 'home.dart'; // Ensure these imports match your file structure
import 'statistics.dart';
import 'budget_screen.dart';
import 'settings.dart';

class BottomNavBarUtil {
  static BottomNavigationBar buildBottomNavigationBar({
    required int currentIndex,
    required void Function(int) onTap,
  }) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Statistics'),
        BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Budget'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
      currentIndex: currentIndex,
      onTap: onTap,
    );
  }
}
