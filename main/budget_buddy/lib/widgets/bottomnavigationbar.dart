import 'package:budget_buddy/add.dart';
import 'package:budget_buddy/budget_screen.dart';
import 'package:budget_buddy/home.dart';
import 'package:budget_buddy/statistics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:budget_buddy/user_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:budget_buddy/settingsScreen.dart';

class Bottom extends StatefulWidget {
  const Bottom({Key? key}) : super(key: key);

  @override
  State<Bottom> createState() => _BottomState();
}

class _BottomState extends State<Bottom> {
  int index_color = 0;
  String? userProfilePictureUrl; // Add this line

  List<Widget> Screen = [
    Home(),
    Statistics(),
    BudgetScreen(),
    UserProfileScreen(),
    SettingsScreen(), // Added SettingsScreen
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserProfilePicture();
  }

  void _fetchUserProfilePicture() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print('User is not logged in.');
      return;
    }
    try {
      final ref = FirebaseStorage.instance
          .ref('user_profile_images/$userId/profile_picture.jpg');
      String url = await ref.getDownloadURL();
      print("Fetched URL: $url");
      setState(() {
        userProfilePictureUrl = url;
      });
    } catch (e) {
      print('Failed to load user profile picture: $e');
    }
  }

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
        child: Padding(
          padding: const EdgeInsets.only(top: 7.5, bottom: 7.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navBarItem(icon: Icons.home, index: 0, label: "Home"),
              _navBarItem(
                  icon: Icons.bar_chart_outlined, index: 1, label: "Stats"),
              SizedBox(width: 20), // Spacer for the FloatingActionButton
              _navBarItem(
                  icon: Icons.account_balance_wallet_outlined,
                  index: 2,
                  label: "Budget"),
              // Always display userProfilePictureNavItem regardless of index_color
              userProfilePictureNavItem(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navBarItem(
      {required IconData icon, required int index, required String label}) {
    return GestureDetector(
      onTap: () => setState(() => index_color = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 24,
              color: index_color == index ? Color(0xff368983) : Colors.grey),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color:
                      index_color == index ? Color(0xff368983) : Colors.grey)),
        ],
      ),
    );
  }

  Widget userProfilePictureNavItem() {
    return GestureDetector(
      onTap: () => setState(() => index_color = 3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundImage: userProfilePictureUrl != null
                ? NetworkImage(userProfilePictureUrl!)
                : null,
            backgroundColor: Colors.transparent,
          ),
          Text("Profile",
              style: TextStyle(fontSize: 12, color: Color(0xff368983))),
        ],
      ),
    );
  }
}
