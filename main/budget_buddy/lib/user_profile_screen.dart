import 'dart:io';

import 'package:budget_buddy/features/user_auth/presentation/pages/login_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  String? imageUrl; // URL of the user's profile picture

  @override
  void initState() {
    super.initState();
    // TODO: Load the user's profile picture URL from Firebase or another source
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      await _uploadImageToFirebase(file);
    }
  }

  Future<void> _uploadImageToFirebase(File file) async {
    try {
      // Create a reference to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref();
      final user = FirebaseAuth.instance.currentUser;
      final userProfileImageRef =
          storageRef.child('user_profile_images/${user?.uid}.jpg');

      // Upload the file
      final uploadTask = userProfileImageRef.putFile(file);

      // When complete, get the download URL
      final snapshot = await uploadTask.whenComplete(() => {});
      final url = await snapshot.ref.getDownloadURL();

      // Update user's profile picture URL in Firebase Auth
      await user?.updatePhotoURL(url);

      // Update the UI
      setState(() {
        imageUrl = url;
      });
    } catch (e) {
      print('Error occurred while uploading to Firebase: $e');
      // Handle errors here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    imageUrl != null ? NetworkImage(imageUrl!) : null,
                child:
                    imageUrl == null ? Icon(Icons.camera_alt, size: 50) : null,
              ),
            ),
            SizedBox(height: 20),
            Text(user?.displayName ?? 'User Name',
                style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Handle profile edit
              },
              child: Text('Edit Profile'),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (Route<dynamic> route) => false,
                );
              },
              child: Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}
