import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tbc_attendance_application/pages/app/app_page.dart';
import 'package:tbc_attendance_application/pages/app/feedback/term_condition.dart';
import 'package:tbc_attendance_application/pages/app/feedback_box/feedback_box.dart';
import 'package:tbc_attendance_application/pages/app/home/emotion.dart';
import 'package:tbc_attendance_application/pages/app/home/errorsStatus.dart';
import 'package:tbc_attendance_application/pages/app/manager/manager_approve.dart';
import 'package:tbc_attendance_application/pages/app/manager/manager_management.dart';
import 'package:tbc_attendance_application/pages/login/login_page.dart';
import 'package:tbc_attendance_application/pages/register/register_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp()
      .then((value) => print("Firebase initialize success"));

  Stream currentUser() async* {
    var user = FirebaseAuth.instance.currentUser;
    yield user;
  }
  //print(user);
  //

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
        '/emotion': (context) => EmotionPage(
              documentId: null,
            ),
        '/error_status': (contex) => ErrorStatus(),
        '/term_condition': (context) => TermAndCondition(),
        '/feedback_box': (context) => FeedbackBox(),
        '/manager_approve': (context) => ManagerApprove(),
        '/manager_management': (context) => ManagerManagement()
      },
      home: StreamBuilder(
        stream: currentUser(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              // TODO: Handle this case.
              break;
            case ConnectionState.waiting:
              return Center(
                child:
                    Scaffold(body: Center(child: CircularProgressIndicator())),
              );
              break;
            case ConnectionState.active:
              // TODO: Handle this case.
              break;
            case ConnectionState.done:
              if (snapshot.data == null) {
                return LoginPage();
              } else {
                return Application();
              }
          }
          return Center(
            child: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        },
      )));
}
