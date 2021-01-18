import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tbc_attendance_application/pages/app/app_page.dart';
import 'package:tbc_attendance_application/pages/login/login_page.dart';
import 'package:tbc_attendance_application/pages/register/register_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp()
      .then((value) => print("Firebase initialize success"));

  User user = FirebaseAuth.instance.currentUser;
  print(user);
  runApp(MaterialApp(
      //initialRoute: '/app',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/app': (context) => Application(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
      }, home: user != null ? Application() : LoginPage()));
}
