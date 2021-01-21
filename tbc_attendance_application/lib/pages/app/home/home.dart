import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tbc_attendance_application/pages/app/home/emotion.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
/* -------------------------------------------------------------------------- */
/*                             Initialize firebase                            */
/* -------------------------------------------------------------------------- */
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

/* -------------------------------------------------------------------------- */
/*                                  Variable                                  */
/* -------------------------------------------------------------------------- */
  File selfieImage;

  double kxLatitude = 13.720363;
  double kxLongtitude = 100.498404;

  bool allowButton = false;
  bool checkIn = false;
  bool isLoading = false;
  bool approveState = false;

  String name;
  String employeeId;
  String pic;
  String picURL;

/* -------------------------------------------------------------------------- */
/*                                  Function                                  */
/* -------------------------------------------------------------------------- */
  String getSystemTime() {
    var now = new DateTime.now();
    return new DateFormat("jm").format(now);
  }

  bool switchImage() {
    var now = new DateTime.now();

    if (new DateFormat("a").format(now) == "AM") {
      return true;
    } else {
      return false;
    }
  }

  Future _isCameraOnPress(ImageSource imageSource) async {
    try {
      var img = await ImagePicker.pickImage(source: imageSource);
      setState(() {
        selfieImage = img;
      });
    } catch (errors) {}
  }

  Stream<dynamic> getCurrentPosition() {
    var _getDistance;

    void onData() {
      print("Distance : $_getDistance");
      if (_getDistance <= 50) {
        setState(() {
          allowButton = true;
        });
      } else {
        setState(() {
          allowButton = false;
        });
      }
    }

    StreamSubscription<Position> positionStream = Geolocator.getPositionStream(
            desiredAccuracy: LocationAccuracy.high,
            intervalDuration: Duration(seconds: 10))
        .listen((Position position) {
      _getDistance = Geolocator.distanceBetween(
          position.latitude, position.longitude, kxLatitude, kxLongtitude);
      onData();
    });
  }

  checkInState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    employeeId = prefs.getString("employeeId");
    name = prefs.getString("name");
    pic = prefs.getString("pic");

    print("Function check_all_state is running");
    await firestore
        .collection("check_in_state")
        .doc(employeeId)
        .get()
        .then((value) {
      setState(() {
        checkIn = value.data()["checkIn"];
      });
    }).then((value) async {
      await firestore
          .collection("approve_state")
          .doc(employeeId)
          .get()
          .then((value) {
        setState(() {
          approveState = value.data()["approveState"];
        });
      }).then((value) async {
        String getImageUrl = await firebase_storage.FirebaseStorage.instance
            .ref(pic)
            .getDownloadURL();

        print(getImageUrl);
        setState(() {
          picURL = getImageUrl;
        });
      });
    });
  }

  onCheckInAndOut() async {
    if (checkIn != true) {
      print("Check IN");
      await checkInFunction();
    } else {
      print("Check Out");
      await checkOutFunction();
      await getEmotion();
    }
  }

  checkInFunction() async {
    print("Function check in is running");
    var now = new DateTime.now();
    await firestore.collection('check_in_logs').add({
      "employee_id": "A000",
      "date": DateFormat.yMMMd().format(now),
      "time": DateFormat.jm().format(now),
      "pic": null,
      "approve": approveState,
      "status": "On time"
    }).then((value) {
      upLoadFile();
    });
  }

  checkOutFunction() async {
    print("Function check out is running");
    var now = new DateTime.now();
    await firestore.collection('check_out_logs').add({
      "employee_id": "A000",
      "date": DateFormat.yMMMd().format(now),
      "time": DateFormat.jm().format(now),
      "pic": null,
      "emotion": null
    }).then((value) {
      upLoadFile();
    });
  }

  getEmotion() {
    Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) => EmotionPage()));
  }

  upLoadFile() async {
    print("Function upload_file is running");
    await storage
        .ref(checkIn ? "/check_out_image/" : "/check_in_image/")
        .child(
            "/$employeeId/${DateFormat.yMMMd().format(new DateTime.now())}.png")
        .putFile(selfieImage)
        .then((response) => setCheckInState(employeeId))
        .catchError((onError) => print(onError));
  }

  setCheckInState(String employeeId) async {
    print("Function set_state is running");
    await firestore
        .collection("check_in_state")
        .doc(employeeId)
        .set({"checkIn": !checkIn}).then((value) {
      setState(() {
        checkIn = !checkIn;
        isLoading = false;
      });
    });
  }

  _isLoadingFunction() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

/* -------------------------------------------------------------------------- */

  @override
  void initState() {
    checkInState();
    super.initState();
  }

  @override
  void dispose() {
    getCurrentPosition();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          body: SingleChildScrollView(
            child: Stack(
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10)),
                    color: Theme.of(context).primaryColor,
                  ),
                ),

                /* -------------------------------------------------------------------------- */
                /*                                   PROFILE                                  */
                /* -------------------------------------------------------------------------- */

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 36),
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 15),
                          child: Row(
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 15),
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 35,
                                  child: CircleAvatar(
                                    backgroundImage: picURL != null
                                        ? NetworkImage(picURL)
                                        : null,
                                    backgroundColor: Colors.white,
                                    radius: 30,
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name != null ? name : "Username",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    employeeId != null
                                        ? "ID : $employeeId"
                                        : "Employee Id",
                                    style: TextStyle(color: Colors.white),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),

                      /* -------------------------------------------------------------------------- */
                      /*                                CHECKIN CARD                                */
                      /* -------------------------------------------------------------------------- */

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 36),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 25),
                          width: double.infinity,
                          height: 300,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                spreadRadius: 1.5,
                                blurRadius: 6,
                                offset:
                                    Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 5),
                                child: Image.asset(
                                  switchImage()
                                      ? "assets/dawn.png"
                                      : "assets/sunset.png",
                                  width: 80,
                                  height: 80,
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.symmetric(vertical: 5),
                                  child: Text(
                                    switchImage()
                                        ? "Good morning"
                                        : "Good evening",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25,
                                        color: switchImage()
                                            ? Color.fromRGBO(253, 208, 32, 1)
                                            : Colors.orange),
                                  )),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 5),
                                child: TimerBuilder.periodic(
                                    Duration(seconds: 1), builder: (context) {
                                  return Text(
                                    "${getSystemTime()}",
                                    style: TextStyle(
                                        color: Color.fromRGBO(61, 61, 61, 1),
                                        fontSize: 40,
                                        fontWeight: FontWeight.w700),
                                  );
                                }),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  "${DateFormat.E().format(new DateTime.now()) + " " + DateFormat.d().format(new DateTime.now()) + " " + DateFormat.LLL().format(new DateTime.now()) + " " + DateFormat.y().format(new DateTime.now())}",
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Color.fromRGBO(61, 61, 61, 1)),
                                ),
                              ),
                              StreamBuilder<Object>(
                                  stream: getCurrentPosition(),
                                  builder: (context, snapshot) {
                                    return Container(
                                        width: double.infinity,
                                        height: 50,
                                        child: isLoading
                                            ? _isLoadingFunction()
                                            : RaisedButton(
                                                onPressed: allowButton
                                                    ? () {
                                                        setState(() {
                                                          isLoading = true;
                                                        });
                                                        _isCameraOnPress(
                                                                ImageSource
                                                                    .camera)
                                                            .then((value) {
                                                          onCheckInAndOut();
                                                        });
                                                      }
                                                    : null,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          right: 5),
                                                      child: Text(
                                                          checkIn
                                                              ? "CHECK OUT"
                                                              : "CHECK IN",
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white)),
                                                    ),
                                                    Icon(
                                                      Icons.login,
                                                      color: Colors.white,
                                                    )
                                                  ],
                                                ),
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ));
                                  })
                            ],
                          ),
                        ),
                      ),

                      /* ----------------------------------- END ---------------------------------- */

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 36),
                        child: Container(
                          margin: EdgeInsets.only(top: 30, bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                  margin: EdgeInsets.only(right: 10),
                                  child: Icon(
                                    Icons.info,
                                    color: Theme.of(context).primaryColor,
                                  )),
                              Text("Announcement"),
                            ],
                          ),
                        ),
                      ),

                      /* -------------------------------------------------------------------------- */
                      /*                                NOTIFICATION                                */
                      /* -------------------------------------------------------------------------- */

                      Container(
                        height: 160,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            Container(
                              margin: EdgeInsets.only(right: 36),
                            ),
                            Container(
                              margin: EdgeInsets.only(right: 10),
                              width: 300,
                              height: 150,
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
                            ),
                            Container(
                              margin: EdgeInsets.only(right: 10),
                              width: 300,
                              height: 150,
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
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
