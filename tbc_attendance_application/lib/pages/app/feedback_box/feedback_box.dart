import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedbackBox extends StatefulWidget {
  @override
  _FeedbackBoxState createState() => _FeedbackBoxState();
}

class _FeedbackBoxState extends State<FeedbackBox> {
  var feedback = [];
  var username;
  Future _loadFeedbackMessage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString("name");

    await FirebaseFirestore.instance
        .collection('feedback')
        .orderBy("timestamp")
        .get()
        .then((QuerySnapshot querySnapshot) {
      var data = [];
      querySnapshot.docs.forEach((doc) {
        if (doc.data()["name"] == username) {
          data.add(doc.data()['message']);
        }
      });
      setState(() {
        feedback = data;
      });

      print(feedback);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _loadFeedbackMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          elevation: 0,
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: feedback.length,
              itemBuilder: (BuildContext context, int index) => Container(
                    constraints: BoxConstraints(minHeight: 70),
                    margin: EdgeInsets.only(top: 10),
                    width: double.infinity,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            width: 50,
                            child: CircleAvatar(
                              child: Center(
                                child: Icon(Icons.person),
                              ),
                            )),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(child: Text("TBC bot messanger"))
                              ],
                            ),
                            Row(children: [
                              Container(
                                  padding: EdgeInsets.all(10),
                                  margin: EdgeInsets.symmetric(vertical: 5),
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width * 0.7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        spreadRadius: 1.5,
                                        blurRadius: 6,
                                        offset: Offset(
                                            0, 3), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: Text(feedback[index]))
                            ]),
                          ],
                        ),
                      ],
                    ),
                  )),
        ));
  }
}
