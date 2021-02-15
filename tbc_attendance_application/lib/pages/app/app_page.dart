import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tbc_attendance_application/pages/app/feedback/feedback.dart';
import 'package:tbc_attendance_application/pages/app/history/history.dart';
import 'package:tbc_attendance_application/pages/app/home/home.dart';

class Application extends StatefulWidget {
  const Application({Key key}) : super(key: key);

  @override
  _ApplicationState createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
/* -------------------------------------------------------------------------- */
/*                                  Variable                                  */
/* -------------------------------------------------------------------------- */
  int _selectedIndex = 0;
  var isManager = false;

/* -------------------------------------------------------------------------- */
/*                                  Function                                  */
/* -------------------------------------------------------------------------- */
  onChangePage() {
    switch (_selectedIndex) {
      case 0:
        return HomePage();
      case 1:
        return HistoryPage();
      case 2:
        return FeedbackPage();
        break;
      default:
    }
  }

  setId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var email = FirebaseAuth.instance.currentUser.email;
    await FirebaseFirestore.instance
        .collection('users_account')
        .where("email", isEqualTo: email)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((element) {
        print(element.data());
        prefs.setString("id", element.data()["id"]);
        prefs.setString("name", element.data()["name"]);
        setState(() {
          isManager = element.data()["manager"];
        });
      });
    });

    print("setId : ${prefs.get("id")}");
  }

  @override
  void initState() {
    super.initState();
    setId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.mail),
            onPressed: () {
              Navigator.of(context).pushNamed("/feedback_box");
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (value) {
          if (value == 2) {
            Navigator.of(context).pushNamed("/term_condition");
          }
          if (value != _selectedIndex) {
            setState(() {
              _selectedIndex = value;
            });
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.feedback), label: "Feedback")
        ],
      ),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Container(),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
            ),
            ListTile(
              title: Row(
                children: [
                  Container(
                      margin: EdgeInsets.only(right: 10),
                      child: Icon(
                        Icons.verified_user,
                        color: isManager == false ? Colors.grey : Colors.black,
                      )),
                  Text(
                    'Manager',
                    style: TextStyle(
                      color: isManager == false ? Colors.grey : Colors.black,
                    ),
                  )
                ],
              ),
              onTap: isManager == false
                  ? null
                  : () {
                      Navigator.of(context).pushNamed("/manager_approve");
                    },
            ),
            ListTile(
              title: Row(
                children: [
                  Container(
                      margin: EdgeInsets.only(right: 10),
                      child: Icon(Icons.settings)),
                  Text('Setting'),
                ],
              ),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
            ListTile(
              title: Row(
                children: [
                  Container(
                      margin: EdgeInsets.only(right: 10),
                      child: Icon(Icons.logout)),
                  Text('Logout'),
                ],
              ),
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove("id").then((value) async {
                  print(value);
                  await prefs.remove("id");
                }).then((value) async {
                  print(value);
                  await FirebaseAuth.instance.signOut();
                }).then((value) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login', (Route<dynamic> route) => false);
                });
              },
            ),
          ],
        ),
      ),
      body: onChangePage(),
    );
  }
}
