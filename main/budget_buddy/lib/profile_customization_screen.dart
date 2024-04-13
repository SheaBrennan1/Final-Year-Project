import 'dart:io';
import 'package:budget_buddy/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home.dart';
import 'add.dart';
import 'budget_screen.dart';
import 'settings.dart';
import 'statistics.dart';

class ProfileCustomizationScreen extends StatefulWidget {
  @override
  _ProfileCustomizationScreenState createState() =>
      _ProfileCustomizationScreenState();
}

class _ProfileCustomizationScreenState
    extends State<ProfileCustomizationScreen> {
  File? _image;
  final TextEditingController _usernameController = TextEditingController();
  int index_color = 3;
  String? userProfilePictureUrl;

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? selectedImage = await _picker.pickImage(source: source);
    if (selectedImage != null) {
      setState(() {
        _image = File(selectedImage.path);
      });
      await _uploadImageToFirebase(_image!);
    }
  }

  Future<void> _uploadImageToFirebase(File image) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String userId = user.uid;
        Reference ref = FirebaseStorage.instance
            .ref()
            .child('user_profile_images/$userId/profile_picture.jpg');
        UploadTask uploadTask = ref.putFile(image);
        await uploadTask.whenComplete(() => null);
        final url = await ref.getDownloadURL();
        await user.updatePhotoURL(url);
        DocumentReference docRef =
            FirebaseFirestore.instance.collection('userSettings').doc(userId);
        await docRef.set({'photoURL': url}, SetOptions(merge: true));
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Profile picture updated successfully.")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to upload profile picture.")));
    }
  }

  Future<void> _updateUsername() async {
    String newUsername = _usernameController.text.trim();
    if (newUsername.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Username cannot be empty.")));
      return;
    }
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentReference docRef =
          FirebaseFirestore.instance.collection('userSettings').doc(userId);
      await docRef.update({'username': newUsername});
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Username updated successfully.")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to update username.")));
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
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
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => UserProfileScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    String? userProfileUrl = user?.photoURL;

    ImageProvider avatarImage = _image != null
        ? FileImage(_image!)
            as ImageProvider // Explicitly casting to ImageProvider
        : userProfileUrl != null && userProfileUrl.isNotEmpty
            ? NetworkImage(userProfileUrl)
                as ImageProvider // Explicitly casting to ImageProvider
            : AssetImage('images/placeholder_image.png')
                as ImageProvider; // Explicitly casting to ImageProvider

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
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
          children: [
            SizedBox(height: 20),
            CircleAvatar(radius: 60, backgroundImage: avatarImage),
            SizedBox(height: 10),
            TextButton.icon(
                icon: Icon(Icons.image, color: Colors.blue),
                label: Text('Change Profile Picture',
                    style: TextStyle(color: Colors.blue)),
                onPressed: () => _pickImage(ImageSource.gallery)),
            TextButton.icon(
                icon: Icon(Icons.camera_alt, color: Colors.blue),
                label: Text('Take a New Picture',
                    style: TextStyle(color: Colors.blue)),
                onPressed: () => _pickImage(ImageSource.camera)),
            Divider(),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Customize your profile settings below:',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue)),
                  TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(labelText: 'New Username')),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _updateUsername,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: Text('Update Username',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => Add_Screen()));
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
