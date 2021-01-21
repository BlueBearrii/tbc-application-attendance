import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tbc_attendance_application/pages/app/app_page.dart';
import 'package:tbc_attendance_application/pages/app/home/emotion.dart';
import 'package:tbc_attendance_application/pages/login/login_page.dart';
import 'package:tbc_attendance_application/pages/register/register_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await Firebase.initializeApp()
      .then((value) => print("Firebase initialize success"))
      .then((value) async {
    await FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                if (doc["email"] == FirebaseAuth.instance.currentUser.email) {
                  prefs.setString("employeeId", doc.data()['employeeId']);
                  prefs.setString("name", doc.data()['name']);
                  prefs.setString("pic", doc.data()['pic']);
                  prefs.setBool("manager", doc.data()['manager']);
                  prefs.setString(
                      "email", FirebaseAuth.instance.currentUser.email);
                  prefs.setString("uid", FirebaseAuth.instance.currentUser.uid);
                }
              })
            });
  });

  User user = FirebaseAuth.instance.currentUser;
  print(user);
  print(prefs.get("email"));

  runApp(MaterialApp(
      theme: ThemeData(
          primaryColor: Color.fromRGBO(52, 54, 158, 1),
          backgroundColor: Color.fromRGBO(248, 248, 255, 1)),
      //initialRoute: '/app',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/app': (context) => Application(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/emotion': (context) => EmotionPage()
      },
      home: user != null ? Application() : LoginPage()));
}
