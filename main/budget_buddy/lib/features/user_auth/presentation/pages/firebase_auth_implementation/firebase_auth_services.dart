import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUpWithEmailAndPassword(
      String email, String password, String username) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // Update the username in the user profile
      User? user = credential.user;
      if (user != null) {
        await user.updateProfile(displayName: username);
        await user.reload(); // Reload the user to ensure the profile is updated
      }

      return _auth.currentUser;
    } on FirebaseAuthException catch (e) {
      print("Error occurred during sign up: ${e.message}");
      return null;
    }
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      print("some error occured");
    }
    return null;
  }
}
