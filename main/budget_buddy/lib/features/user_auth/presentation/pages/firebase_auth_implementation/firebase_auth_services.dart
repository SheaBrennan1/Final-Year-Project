import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print("User cancelled the Google Sign-In process.");
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Preliminary check to see if email is already associated with a user.
      final signInMethods = await FirebaseAuth.instance
          .fetchSignInMethodsForEmail(googleUser.email);
      if (signInMethods.isEmpty) {
        print("Account does not exist. Please sign up first.");
        return null;
      }

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      print("User signed in with Google: ${userCredential.user?.displayName}");
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("Error occurred during Google Sign-In: ${e.message}");
      return null;
    }
  }

  Future<User?> signUpWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await GoogleSignIn().signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        final UserCredential authResult =
            await _auth.signInWithCredential(credential);
        return authResult.user;
      }
    } catch (error) {
      print(error.toString());
      return null;
    }
    return null;
  }

  // Add a sign out method for convenience
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    print("User signed out.");
  }
}
