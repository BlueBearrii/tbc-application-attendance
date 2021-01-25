import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmotionPage extends StatelessWidget {
  final String documentId;
  const EmotionPage({Key key, @required this.documentId}) : super(key: key);

  setEmotion(number) async {
    print(documentId);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var employeeId = prefs.getString("employeeId");
    FirebaseFirestore.instance
        .collection('check_out_log')
        .doc(documentId)
        .update({"emotion": number});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black.withOpacity(0.85),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.symmetric(horizontal: 36),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    margin: EdgeInsets.only(bottom: 15),
                    child: Text(
                      "How are you feeling today",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    )),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                        onTap: () {
                          setEmotion(1).then((value) {
                            Navigator.pop(context);
                          });
                        },
                        child: Image.asset("assets/angry.png")),
                    GestureDetector(
                        onTap: () {
                          setEmotion(2).then((value) {
                            Navigator.pop(context);
                          });
                        },
                        child: Image.asset("assets/frown.png")),
                    GestureDetector(
                        onTap: () {
                          setEmotion(3).then((value) {
                            Navigator.pop(context);
                          });
                        },
                        child: Image.asset("assets/confusing.png")),
                    GestureDetector(
                        onTap: () {
                          setEmotion(4).then((value) {
                            Navigator.pop(context);
                          });
                        },
                        child: Image.asset("assets/grinning.png")),
                    GestureDetector(
                        onTap: () {
                          setEmotion(5).then((value) {
                            Navigator.pop(context);
                          });
                        },
                        child: Image.asset("assets/blow-kiss.png")),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
