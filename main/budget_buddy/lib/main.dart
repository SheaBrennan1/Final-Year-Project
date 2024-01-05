import 'package:budget_buddy/features/app/splash_screen/splash_screen.dart';
import 'package:budget_buddy/features/user_auth/presentation/pages/login_page.dart';
import 'package:budget_buddy/features/user_auth/presentation/pages/sign_up_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:budget_buddy/home.dart';
import 'package:budget_buddy/statistics.dart';
import 'package:budget_buddy/widgets/bottomnavigationbar.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'data/model/add_date.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
    apiKey: "AIzaSyCHnqK-G12Gv7EkOQnbq3TtMPWtsC04eSA",
    appId: "1:162550313227:android:d91dd69c9c8e3505aef20e",
    messagingSenderId: "162550313227",
    projectId: "budget-buddy-a49f1",
    databaseURL:
        "https://budget-buddy-a49f1-default-rtdb.europe-west1.firebasedatabase.app/",
  ));
  runApp(MyApp());
  // if (kIsWeb) {
  //   await Firebase.initializeApp(
  //       options: FirebaseOptions(
  //           apiKey: "AIzaSyDa31InZ16DT1xKZcuJAfK3EBhpnS39oQQ",
  //           appId: "1:162550313227:web:856438611f2e54f0aef20e",
  //           messagingSenderId: "162550313227",
  //           projectId: "budget-buddy-a49f1"));
  // } else {

  // }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => SplashScreen(
              // Here, you can decide whether to show the LoginPage or HomePage based on user authentication
              child: LoginPage(),
            ),
        '/login': (context) => LoginPage(),
        '/signUp': (context) => SignUpPage(),
        '/home': (context) => Bottom(),
      },
      //home: Bottom(),
    );
  }
}
