import 'dart:io';
import 'package:budget_buddy/add.dart';
import 'package:budget_buddy/budget_screen.dart';
import 'package:budget_buddy/home.dart';
import 'package:budget_buddy/statistics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_customization_screen.dart';
import 'goals_and_targets_screen.dart';
import 'settingsScreen.dart';
import 'package:budget_buddy/features/user_auth/presentation/pages/login_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  String? imageUrl; // URL of the user's profile picture
  String? userName; // User's display name
  int index_color = 3;

  @override
  void initState() {
    super.initState();
    _loadProfilePicture();
    _loadUserName();
  }

  void _loadProfilePicture() async {
    try {
      print('Initializing FirebaseStorage...');
      FirebaseStorage storage =
          FirebaseStorage.instance; // This line might fail
      print('FirebaseStorage initialized successfully.');

      String path = 'user_profile_images/${user?.uid}/profile_picture.jpg';
      print('Constructed path: $path');

      String url = await storage.ref(path).getDownloadURL();
      print('Retrieved URL: $url');

      setState(() {
        imageUrl = url;
      });
    } catch (e, stackTrace) {
      print('An error occurred: $e');
      print('StackTrace: $stackTrace');
    }
  }

  void _pickImage() async {
    // Your existing code to pick and upload an image
  }

  Future<void> _uploadImageToFirebase(File file) async {
    // Your existing code to upload image to Firebase
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      // Remove the shape property or set it to null for a rectangular look
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
                icon: Icon(Icons.home), onPressed: () => _onItemTapped(0)),
            IconButton(
                icon: Icon(Icons.bar_chart), onPressed: () => _onItemTapped(1)),
            IconButton(
                icon: Icon(Icons.account_balance_wallet),
                onPressed: () => _onItemTapped(2)),
            IconButton(
                icon: Icon(Icons.settings), onPressed: () => _onItemTapped(3)),
          ],
        ),
      ),
      color: Colors.white, // Background color of BottomAppBar
    );
  }

  void _loadUserName() async {
    if (user?.uid != null) {
      try {
        final docRef = FirebaseFirestore.instance
            .collection('userSettings')
            .doc(user!.uid);
        DocumentSnapshot doc = await docRef.get();
        if (doc.exists) {
          setState(() {
            userName = doc['username'] ?? user?.email; // Use email as fallback
          });
        }
      } catch (e) {
        print('Failed to load user name: $e');
        // Handle failure
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Profile',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold, // Adjust as needed
          ),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 20),
            CircleAvatar(
              radius: 60,
              backgroundImage: imageUrl != null
                  ? NetworkImage(imageUrl!)
                  : AssetImage('images/placeholder_image.png') as ImageProvider,
              backgroundColor: Colors.grey.shade300,
            ),
            SizedBox(height: 20),
            Text(
              userName ?? 'User Name',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            SizedBox(height: 10),
            Text(
              user?.email ?? 'Email not available',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            SizedBox(height: 30),
            _actionButton(context, Icons.edit, 'Edit Profile',
                ProfileCustomizationScreen()),
            _actionButton(context, Icons.track_changes_outlined,
                'Goals and Targets', GoalsAndTargetsScreen()),
            _actionButton(
                context, Icons.settings, 'Settings', SettingsScreen()),
            _actionButton(context, Icons.exit_to_app, 'Log Out', LoginPage(),
                isLogout: true),
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

  Widget _actionButton(
      BuildContext context, IconData icon, String text, Widget destination,
      {bool isLogout = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white),
        label: Text(text, style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: isLogout ? Colors.red : Colors.blue,
          minimumSize: Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () async {
          if (isLogout) {
            await FirebaseAuth.instance.signOut();
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => destination),
                (Route<dynamic> route) => false);
          } else {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => destination));
          }
        },
      ),
    );
  }
}
