import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tbc_attendance_application/pages/app/home/emotion.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  // Instance value
  static double kxBuildingLatitude = 13.720363;
  static double kxBuildingLongtitude = 100.498404;

  // Initialze state value
  var pictureProfile;
  var checkIn;
  var approveState;
  var employeeId;
  var username;
  var announcement;
  var onTimeStatus;
  var refDocumentId;

  // Image path url
  var imagePath;

  // Active check in button
  var enableCheckInButton = false;
  var distance;
  var isLoading = false;

  // CheckIN&OUT value
  var selfieFile;

  Future logsTest() async {
    print("Picture url : $pictureProfile");
    print("Approve state : $approveState");
    print("Check in state : $checkIn");
    print("Enable check in button state : $enableCheckInButton");
    print("Employee Id : $employeeId");
    print("Username : $username");
    print("Announcement : $announcement");
  }

  Future<bool> prepareState() async {
    if (pictureProfile != null &&
        checkIn != null &&
        approveState != null &&
        employeeId != null &&
        username != null) {
      return true;
    } else {
      return false;
    }
  }

  Future initializeValueFromDatabase() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    imagePath = prefs.getString("pic");
    employeeId = prefs.getString("employeeId");
    username = prefs.getString("name");

    await storage.ref(imagePath).getDownloadURL().then((imagePath) {
      if (mounted) {
        setState(() {
          pictureProfile = imagePath;
        });
      }
    });
    await firestore
        .collection('approve_state')
        .doc(employeeId)
        .get()
        .then((_approveState) {
      if (mounted) {
        setState(() {
          approveState = _approveState.data()["approveState"];
        });
      }
    });
    await firestore
        .collection('check_in_state')
        .doc(employeeId)
        .get()
        .then((_checkIn) {
      if (mounted) {
        setState(() {
          checkIn = _checkIn.data()["checkIn"];
        });
      }
    });
    await firestore
        .collection('announcement')
        .get()
        .then((QuerySnapshot querySnapshot) {
      var messageBox = [];
      querySnapshot.docs.forEach((doc) {
        messageBox.add(doc["message"]);
      });
      if (mounted) {
        setState(() {
          announcement = messageBox;
        });
      }
    });
  }

  void onSetDistance() {
    print("Distance : $distance");
    if (distance <= 60) {
      setState(() {
        enableCheckInButton = true;
      });
    } else {
      setState(() {
        enableCheckInButton = false;
      });
    }
  }

  Stream<dynamic> positionStreamTrack() {
    var _getDistance;
    void onData() {
      print("Distance : $_getDistance");
      if (mounted) {
        if (_getDistance <= 50) {
          setState(() {
            enableCheckInButton = true;
          });
        } else {
          setState(() {
            enableCheckInButton = false;
          });
        }
      }
    }

    StreamSubscription<Position> positionStream = Geolocator.getPositionStream(
            desiredAccuracy: LocationAccuracy.high,
            intervalDuration: Duration(seconds: 10))
        .listen((Position position) {
      _getDistance = Geolocator.distanceBetween(position.latitude,
          position.longitude, kxBuildingLatitude, kxBuildingLongtitude);

      onData();
    });
  }

  String getSystemTime() {
    var now = new DateTime.now();
    return new DateFormat("jm").format(now);
  }

  bool imageSwitchOnDayTime() {
    var now = new DateTime.now();
    if (new DateFormat("a").format(now) == "AM") {
      return true;
    } else {
      return false;
    }
  }

  Future camara(ImageSource imageSource) async {
    try {
      var getFileSelfieImage = await ImagePicker.pickImage(source: imageSource);
      setState(() {
        selfieFile = getFileSelfieImage;
      });
    } catch (errors) {}
  }

  Future imageIdentify() async {
    var status = false;

    Response responsed;
    Dio dio = new Dio();
    var imageIdentifyUrlPath =
        await FirebaseStorage.instance.ref(imagePath).getDownloadURL();

    // generate random number.
    var rng = new Random();
    // get temporary directory of device.
    Directory tempDir = await getTemporaryDirectory();
    // get temporary path from temporary directory.
    String tempPath = tempDir.path;
    // create a new file in temporary path with random file name.
    File file = new File('$tempPath' + (rng.nextInt(100)).toString() + '.png');
    // call http.get method and pass imageUrl into it to get response.
    http.Response response = await http.get(imageIdentifyUrlPath);
    // write bodyBytes received in response to file.
    await file.writeAsBytes(response.bodyBytes);
    // now return the file which is created with random name in
    // temporary directory and image bytes from response is written to // that file.
    print(file);
    print(selfieFile);

    var api = "https://faceapi-vistecbooking.cybertoryth.com/compare";

    FormData formData = new FormData.fromMap({
      "source": await MultipartFile.fromFile(
        selfieFile.path,
        filename: "Input.png",
      ),
      "target": await MultipartFile.fromFile(file.path, filename: "Target.png"),
    });

    responsed = await dio.post(api, data: formData);
    print(responsed.data);

    if (responsed.data["message"] == "Match!") status = true;

    return status;
  }

  uploadSelfieImageFile() async {
    print("Function upload selfie image file is running");
    var imagePath =
        "/$employeeId/${DateFormat.yMMMd().format(new DateTime.now())}.png";
    await storage
        .ref(checkIn ? "/check_out_image/" : "/check_in_image/")
        .child(imagePath)
        .putFile(selfieFile);
  }

  setCheckInState(bool checkInState) async {
    await firestore
        .collection('check_in_state')
        .doc(employeeId)
        .set({"checkIn": checkInState});
  }

  userCheckIn() async {
    print("Function user check in is running");
    var checkInImagePath =
        "/check_in_image/$employeeId/${DateFormat.yMMMd().format(new DateTime.now())}.png";
    var now = new DateTime.now();
    var checkInData = {
      "employee_id": employeeId,
      "dateTime": DateTime.now(),
      'year': DateFormat.y().format(now),
      "month": DateFormat.LLLL().format(now),
      'week': calculateWeekOfMonth(),
      'day': DateTime.now().weekday,
      "time": DateFormat.jm().format(now),
      "pic": checkInImagePath,
      "approve": approveState,
      "late": onTimeStatus
    };

    await firestore.collection('check_in_log').add(checkInData).then((value) {
      setCheckInState(true);
    });
  }

  userCheckOut() async {
    print("Function user check out is running");
    var checkOutImagePath =
        "/check_out_image/$employeeId/${DateFormat.yMMMd().format(new DateTime.now())}.png";
    var now = new DateTime.now();
    var checkOutData = {
      "employee_id": employeeId,
      "dateTime": DateTime.now(),
      'year': DateFormat.y().format(now),
      "month": DateFormat.LLLL().format(now),
      'week': calculateWeekOfMonth(),
      'day': DateTime.now().weekday,
      "time": DateFormat.jm().format(now),
      "pic": checkOutImagePath,
      "emotion": null,
    };

    await firestore.collection('check_out_log').add(checkOutData).then((value) {
      setState(() {
        refDocumentId = value.id;
      });
      setCheckInState(false);
    });
  }

  timer(timeStatus) {
    var now = new DateTime.now();
    var hour = int.parse(DateFormat('h').format(now));
    var min = int.parse(DateFormat('m').format(now));

    if (timeStatus == "checkIn") {
      if (imageSwitchOnDayTime()) {
        if (hour >= 10) {
          if (min > 30) {
            setState(() {
              onTimeStatus = "Late";
            });
          } else {
            setState(() {
              onTimeStatus = "On time";
            });
          }
        } else {
          setState(() {
            onTimeStatus = "On time";
          });
        }
      } else {
        setState(() {
          onTimeStatus = "Late";
        });
      }
    } else {
      if (imageSwitchOnDayTime() == false) {
        if (hour <= 6) {
          if (min < 30) {
            setState(() {
              onTimeStatus = "ahead of time";
            });
          } else {
            setState(() {
              onTimeStatus = "On time";
            });
          }
        } else {
          setState(() {
            onTimeStatus = "On time";
          });
        }
      } else {
        setState(() {
          onTimeStatus = "ahead of time";
        });
      }
    }
  }

  onCheckInButtonOnPress() async {
    print("Check in button pressed");
    if (checkIn) {
      timer("checkOut");
      camara(ImageSource.camera).then((value) async {
        if (await imageIdentify()) {
          print("True");
          await userCheckOut().then((value) async {
            await uploadSelfieImageFile().then((value) {
              getEmotion();
              setState(() {
                isLoading = false;
              });
            });
          });
        } else {
          print("False");
        }
      });
    } else {
      timer("checkIn");
      camara(ImageSource.camera).then((value) async {
        if (await imageIdentify()) {
          print("True");
          await userCheckIn().then((value) async {
            await uploadSelfieImageFile().then((value) {
              setState(() {
                isLoading = false;
              });
            });
          });
        } else {}
      });
    }
  }

  Future<int> calculateWeekOfMonth() async {
    var now = new DateTime.now();
    var day = DateFormat.d().format(now);
    var dayOfWeek = now.weekday;
    var countDayOfWeek = dayOfWeek + 1;

    for (int i = int.parse(day); i >= 1; i--) {
      countDayOfWeek = countDayOfWeek - 1;
      if (countDayOfWeek == 0) countDayOfWeek = 7;
    }
    var findWeekCount = 1;
    for (int i = 1; i <= int.parse(day); i++) {
      countDayOfWeek = countDayOfWeek + 1;
      if (countDayOfWeek == 8) {
        findWeekCount++;
        countDayOfWeek = 1;
      }
    }

    print(findWeekCount);

    return findWeekCount.toInt();
  }

  getEmotion() {
    Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) =>
            EmotionPage(documentId: refDocumentId)));
  }

  _isLoadingFunction() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  void initState() {
    super.initState();
    initializeValueFromDatabase();
  }

  @override
  void dispose() {
    super.dispose();
    initializeValueFromDatabase();
    positionStreamTrack();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Stack(
        children: [customBackground(), app()],
      ),
    ));
  }

  Widget customBackground() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget app() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        children: [
          profile(),
          checkInButtonCard(),
          announcementTitle(),
          announcementCard()
        ],
      ),
    );
  }

  Widget profile() {
    return Padding(
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
                  backgroundImage: pictureProfile != null
                      ? NetworkImage(pictureProfile)
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
                  username != null ? username : "Username",
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  employeeId != null ? "ID : $employeeId" : "Employee Id",
                  style: TextStyle(color: Colors.white),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget checkInButtonCard() {
    return Padding(
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
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              child: Image.asset(
                imageSwitchOnDayTime()
                    ? "assets/dawn.png"
                    : "assets/sunset.png",
                width: 80,
                height: 80,
              ),
            ),
            Container(
                margin: EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  imageSwitchOnDayTime() ? "Good morning" : "Good evening",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: imageSwitchOnDayTime()
                          ? Color.fromRGBO(253, 208, 32, 1)
                          : Colors.orange),
                )),
            Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              child: TimerBuilder.periodic(Duration(seconds: 1),
                  builder: (context) {
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
                    fontSize: 18, color: Color.fromRGBO(61, 61, 61, 1)),
              ),
            ),
            isLoading ? _isLoadingFunction() : createCheckInButton()
          ],
        ),
      ),
    );
  }

  Widget createCheckInButton() {
    return StreamBuilder(
        stream: positionStreamTrack(),
        builder: (context, snapshot) {
          return Container(
              width: double.infinity,
              height: 50,
              child: checkIn != null
                  ? RaisedButton(
                      onPressed: enableCheckInButton
                          ? () {
                              setState(() {
                                isLoading = true;
                              });
                              onCheckInButtonOnPress();
                            }
                          : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            checkIn ? "CHECK OUT" : "CHECK IN",
                          ),
                          Icon(Icons.login)
                        ],
                      ),
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    )
                  : _isLoadingFunction());
        });
  }

  Widget announcementTitle() {
    return Padding(
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
    );
  }

  Widget announcementCard() {
    return Container(
        height: 150,
        margin: EdgeInsets.only(bottom: 10),
        child: announcement != null
            ? ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: announcement.length,
                itemBuilder: (BuildContext context, int index) => Card(
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    child: SingleChildScrollView(
                      child: Container(
                        width: 300,
                        constraints: BoxConstraints(minHeight: 150),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          child: Text("${announcement[index]}"),
                        ),
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
                      ),
                    )),
              )
            : _isLoadingFunction());
  }
}
