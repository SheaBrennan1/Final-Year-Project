import 'package:budget_buddy/budget_screen.dart';
import 'package:budget_buddy/features/app/splash_screen/splash_screen.dart';
import 'package:budget_buddy/features/user_auth/presentation/pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Create a global instance of the FlutterLocalNotificationsPlugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyCHnqK-G12Gv7EkOQnbq3TtMPWtsC04eSA",
      appId: "1:162550313227:android:d91dd69c9c8e3505aef20e",
      messagingSenderId: "162550313227",
      projectId: "budget-buddy-a49f1",
      databaseURL:
          "https://budget-buddy-a49f1-default-rtdb.europe-west1.firebasedatabase.app/",
      storageBucket: "budget-buddy-a49f1.appspot.com",
    ),
  );

  // Notification plugin initialization
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    requestPermission();
    listenForNotification();
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      // Get the token each time the application launches
      getToken();
    }
  }

  void getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print("FCM Token: $token");
    // Consider sending the token to your server for user device tracking
  }

  void listenForNotification() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data['budgetName']}');
      print('Message data: ${message.data['type']}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        // Extract budget name from message data
        String? budgetName = message.data['budgetName'];
        String type = message.data['type'];
        // Ensure to call _showNotification with both parameters
        _showNotification(message.notification!, budgetName, type);
      }
    });
  }

  Future<void> _showNotification(
      RemoteNotification notification, String? budgetName, String type) async {
    // Notification details remain the same
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'new_messages_channel', // Channel ID
      'New Messages', // Channel Name
      channelDescription:
          'Notifications for new messages received in the app.', // Channel Description
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    if (type == "BUDGET_OVERUSE") {
      // Update notification body to include the budget name dynamically
      await flutterLocalNotificationsPlugin.show(
        0,
        notification.title,
        "A budget plan has been overspent!", // Use the budgetName here
        platformChannelSpecifics,
        payload: "navigate_to_budget_overuse",
      );
    } else if (type == "YEARLY_GOAL_ACHIEVED") {
      await flutterLocalNotificationsPlugin.show(
        0,
        notification.title,
        notification.body, // Use the budgetName here
        platformChannelSpecifics,
        payload:
            "Congratulations! You've reached your savings goal. Great job on your financial discipline.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => SplashScreen(child: LoginPage()),
        '/budget_screen': (context) => BudgetScreen(),
      },
      theme: ThemeData(
        // Define the default brightness and colors.
        primarySwatch: Colors.teal,
        hintColor: Colors.amber,

        // Define the default font family.
        fontFamily: 'Georgia',

        // Define the default `TextTheme`. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        textTheme: TextTheme(
          headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        ),
      ),
      //home: Bottom(),
    );
  }
}
