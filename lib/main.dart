import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project2/Student/student_timetable.dart';
import 'package:project2/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAsFySC5ZZ575m4Njwjk-rISK9VlAQbu4w",
      appId: "1:101121275449:android:d3bd31b16c5ac93b883fe8",
      messagingSenderId: "101121275449",
      projectId: "project2-d1126",
      storageBucket: "gs://project2-d1126.appspot.com"

    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Main Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasData && snapshot.data != null) {
          // User is authenticated
          return TimetablePage(studentId: '',); // Navigate to your timetable page
        } else {
          // User is not authenticated, navigate to login/register page
          return HomePage(); // Implement your login/register screen
        }
      },
    );
  }
}