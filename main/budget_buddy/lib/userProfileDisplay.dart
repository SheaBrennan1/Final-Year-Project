import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserProfileDisplay extends StatefulWidget {
  @override
  _UserProfileDisplayState createState() => _UserProfileDisplayState();
}

class _UserProfileDisplayState extends State<UserProfileDisplay> {
  String? userProfilePictureUrl;
  int index_color =
      3; // If this is used for navigation index tracking, it should be passed down or managed by a state management solution.

  @override
  void initState() {
    super.initState();
    _fetchUserProfilePicture();
  }

  @override
  Widget build(BuildContext context) {
    return userProfilePictureNavItem();
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
                ? NetworkImage(userProfilePictureUrl!) as ImageProvider<Object>
                : AssetImage('assets/default_avatar.png')
                    as ImageProvider<Object>,
            backgroundColor: Colors.transparent,
          ),
          Text(
            "Profile",
            style: TextStyle(fontSize: 12, color: Color(0xff368983)),
          ),
        ],
      ),
    );
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
      setState(() {
        userProfilePictureUrl = null;
      });
    }
  }
}
