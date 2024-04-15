import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:budget_buddy/home.dart';
import 'package:budget_buddy/features/user_auth/presentation/pages/sign_up_page.dart';
import 'package:budget_buddy/features/user_auth/presentation/pages/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Add this import for SVG support
import 'package:google_sign_in/google_sign_in.dart'; // Add this import for Google Sign-In

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuthService authService = FirebaseAuthService();

  bool isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    ).hasMatch(email);
  }

  bool isValidPassword(String password) {
    return password.length >=
        6; // Simple rule, can be expanded based on requirements
  }

  String sanitizeInput(String input) {
    return input.replaceAll(RegExp(r'[^\w\s]+'),
        ''); // Removes non-alphanumeric characters except spaces
  }

  Future<void> signIn() async {
    if (!isValidEmail(emailController.text) ||
        !isValidPassword(passwordController.text)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Invalid Input'),
          content: Text('Please enter a valid email and password.'),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      return;
    }

    try {
      final user = await authService.signInWithEmailAndPassword(
        emailController.text,
        passwordController.text,
      );

      if (user != null) {
        // Fetch the FCM token
        String? fcmToken = await FirebaseMessaging.instance.getToken();
        print("FCM Token: $fcmToken"); // For debugging purposes

        // Update Firestore with the FCM token
        if (fcmToken != null) {
          await FirebaseFirestore.instance
              .collection('userSettings')
              .doc(user.uid)
              .set({
            'fcmToken': sanitizeInput(fcmToken),
          }, SetOptions(merge: true));
        } else {
          print("FCM Token is null");
        }

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Home()));
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Login Failed'),
            content: Text('User object returned is null.'),
            actions: <Widget>[
              TextButton(
                child: Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print("Login Error: $e"); // Print the error to the console for debugging
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Login Error'),
          content: Text(e.toString()), // Provide specific error message
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.blue],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                    height: MediaQuery.of(context).size.height *
                        0.1), // Adjusted the top spacing
                Image.asset(
                  'images/splash_screen.png', // Assuming your logo is named 'logo.png' in the assets
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.height * 0.2,
                  fit: BoxFit.contain,
                ),
                Text(
                  'Budget Buddy', // Title text
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                    height:
                        32.0), // Added some space between the title and the form
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white, // Set the fill color to white
                    hintText: 'Email',
                    hintStyle: TextStyle(
                        color: Colors.black54), // Hint text style if needed
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(
                      color: Colors.black), // Set the input text color to black
                ),
                SizedBox(height: 12.0),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white, // Set the fill color to white
                    hintText: 'Password',
                    hintStyle: TextStyle(
                        color: Colors.black54), // Hint text style if needed
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(
                      color: Colors.black), // Set the input text color to black
                ),
                SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: signIn,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue.shade900, // Text color
                  ),
                  child: Text('Login', style: TextStyle(fontSize: 16.0)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: OutlinedButton.icon(
                    icon: Image.asset(
                      'images/google_logo.svg', // Make sure the path and file extension are correct
                      width: 30,
                      height: 30,
                    ),
                    label: Text(
                      'Sign in with Google',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 16.0,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(
                          color: Colors.black,
                          width: 2.0), // Black border added here
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onPressed: () async {
                      final GoogleSignIn googleSignIn = GoogleSignIn();
                      final FirebaseAuth auth = FirebaseAuth.instance;

                      try {
                        final GoogleSignInAccount? googleSignInAccount =
                            await googleSignIn.signIn();
                        if (googleSignInAccount != null) {
                          final GoogleSignInAuthentication
                              googleSignInAuthentication =
                              await googleSignInAccount.authentication;
                          final AuthCredential credential =
                              GoogleAuthProvider.credential(
                            accessToken: googleSignInAuthentication.accessToken,
                            idToken: googleSignInAuthentication.idToken,
                          );
                          final UserCredential authResult =
                              await auth.signInWithCredential(credential);
                          final User? user = authResult.user;

                          // Store the user's UID and username in Firestore
                          await FirebaseFirestore.instance
                              .collection('userSettings')
                              .doc(user?.uid)
                              .set({
                            'username': user?.displayName,
                            // You can add more user-related settings here
                          });

                          if (user != null) {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Home()));
                          } else {
                            // Handle null user scenario
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Login Failed'),
                                content: Text('Google Sign-In failed.'),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('Ok'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ],
                              ),
                            );
                          }
                        }
                      } catch (error) {
                        print(error);
                        // Handle error (e.g., user cancelled the sign-in process)
                      }
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black
                        .withOpacity(0.4), // Semi-transparent black container
                    borderRadius:
                        BorderRadius.circular(20), // Adds rounded corners
                  ),
                  padding: const EdgeInsets.all(12.0),
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 50), // Adjust margins as needed
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: TextStyle(color: Colors.white),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpPage()),
                          );
                        },
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Colors.blueAccent[200],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
