import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:http/http.dart' as http;

import 'emotion.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CollectionReference identify =
      FirebaseFirestore.instance.collection('identify_employee');

  FirebaseStorage storage = FirebaseStorage.instance;
  var id;
  var imagePath;
  var name;
  var imageFile;

  var docId;

  static double kxBuildingLatitude = 13.720363;
  static double kxBuildingLongtitude = 100.498404;

  var isButtonLoading = false;

  Future loadState() async {
    var user = FirebaseAuth.instance.currentUser;
    print("USER : $user");

    await FirebaseFirestore.instance
        .collection("users_account")
        .where("email", isEqualTo: user.email)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((element) {
        id = element.data()["id"];
        imagePath = element.data()["pic"];
        name = element.data()["name"];
      });
    }).then((value) {
      FirebaseFirestore.instance
          .collection("check_in_switch")
          .where("id", isEqualTo: id)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((element) {
          setState(() {
            docId = element.id;
          });
        });
      });
    });
  }

  String getSystemTime() {
    var now = new DateTime.now();
    return new DateFormat("jm").format(now);
  }

  Future setStateCheckIn(var state, var chengeState) async {
    var documentId;
    await FirebaseFirestore.instance
        .collection("check_in_switch")
        .where("id", isEqualTo: id)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((element) {
        print(element.data());
        documentId = element.id;
      });
    }).then((value) async {
      await FirebaseFirestore.instance
          .collection("check_in_switch")
          .doc(documentId)
          .update({
        "checkInSwitch": !state,
        "checkInState": chengeState == "In" ? false : true,
      });
    }).then((value) {
      setState(() {
        isButtonLoading = false;
      });
    });
  }

  Future camera(ImageSource imageSource) async {
    try {
      var selfieImageFile = await ImagePicker.pickImage(source: imageSource);
      setState(() {
        imageFile = selfieImageFile;
      });
      return true;
    } catch (errors) {
      return false;
    }
  }

  Future imageProcess() async {
    var apiCompairURL = "https://faceapi-vistecbooking.cybertoryth.com/compare";

    var loadURL;
    var responseMessage;
    File file;
    await identify
        .where("id", isEqualTo: id)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((element) {
        print(element.data());
        imagePath = element.data()['pic'];
      });
    }).then((value) async {
      loadURL = await storage.ref(imagePath).getDownloadURL();
      print(loadURL);
    }).then((value) async {
      var rng = new Random();
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      file = new File('$tempPath' + (rng.nextInt(100)).toString() + '.png');
      http.Response response = await http.get(loadURL);
      await file.writeAsBytes(response.bodyBytes);
      print(file);
    }).then((value) async {
      Response responsed;
      Dio dio = new Dio();
      FormData formData = new FormData.fromMap({
        "source": await MultipartFile.fromFile(
          imageFile.path,
          filename: file.toString(),
        ),
        "target":
            await MultipartFile.fromFile(file.path, filename: file.toString()),
      });
      responsed = await dio.post(apiCompairURL, data: formData);
      print(responsed.data);

      responseMessage = responsed.data;
    });
    return responseMessage;
  }

  checkLateTime() {
    var day = DateTime.now().day;
    var month = DateTime.now().month;
    var year = DateTime.now().year;
    var hour = DateTime.now().hour;
    var min = DateTime.now().minute;

    var status;

    print(DateTime(year, month, day, hour, min)
        .compareTo(DateTime(year, month, day, 10, 30)));

    if (DateTime(year, month, day, hour, min)
            .compareTo(DateTime(year, month, day, 10, 30)) ==
        1) {
      status = true;
    } else {
      status = false;
    }

    return status;
  }

  Future setCheckIn(var state) async {
    var approve;
    var ref = "check_in/$id/${DateTime.now().toIso8601String()}";

    await FirebaseFirestore.instance
        .collection('approve')
        .where("id", isEqualTo: id)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((element) {
        approve = element.data()['approveState'];
      });
    }).then((value) async {
      await FirebaseStorage.instance
          .ref(ref)
          .putFile(imageFile)
          .then((value) async {
        await FirebaseFirestore.instance.collection('check_in_log').add({
          "id": id,
          "day": DateTime.now().day,
          "month": DateTime.now().month,
          "year": DateTime.now().year,
          "late": approve == true ? false : checkLateTime(),
          'ref': ref,
          "timeStamp": Timestamp.now()
        }).then((value) {
          print(value);
          setStateCheckIn(state, "In");
        });
      });
    });
  }

  Future setCheckOut(var state) async {
    var day = DateTime.now().day;
    var month = DateTime.now().month;
    var year = DateTime.now().year;
    var ref = "check_out/$id/${DateTime.now().toIso8601String()}";

    var getCheckIn;
    var documentId;

    await FirebaseFirestore.instance
        .collection("check_in_log")
        .where("id", isEqualTo: id)
        .where("day", isEqualTo: day)
        .where("month", isEqualTo: month)
        .where("year", isEqualTo: year)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((element) {
        print(element.data());
        getCheckIn = element.data();
      });
    }).then((value) async {
      await FirebaseStorage.instance
          .ref(ref)
          .putFile(imageFile)
          .then((value) async {
        await FirebaseFirestore.instance.collection('check_out_log').add({
          "id": id,
          "day": getCheckIn["day"],
          "month": getCheckIn["month"],
          "year": getCheckIn["year"],
          "late": getCheckIn['late'],
          'checkInRef': getCheckIn['ref'],
          'checkOutRef': ref,
          "checkIntimeStamp": getCheckIn['timeStamp'],
          "checkOutTimeStamp": Timestamp.now(),
          'emoticon': null,
        }).then((value) {
          print(value);
          documentId = value.id;
          Navigator.of(context).push(PageRouteBuilder(
              opaque: false,
              pageBuilder: (BuildContext context, _, __) =>
                  EmotionPage(documentId: documentId)));
        }).then((value) {
          setStateCheckIn(state, "Out");
        });
      });
    });
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Response'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Something wrong, please try again'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: Container(
          child: SingleChildScrollView(
            child: Stack(children: [
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    )),
              ),
              Column(
                children: [
                  profile(),
                  cardCheckIn(),
                  announcement(),
                ],
              ),
            ]),
          ),
        ));
  }

  Widget profile() {
    return imagePath == null
        ? Container(
            padding: EdgeInsets.symmetric(horizontal: 36),
            margin: EdgeInsets.only(top: 20),
            child: Container(
              width: double.infinity,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: MediaQuery.of(context).size.width * 0.08,
                    child: CircleAvatar(
                      radius: MediaQuery.of(context).size.width * 0.065,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Loading ...",
                          style: TextStyle(color: Colors.white),
                        ),
                        Container()
                      ],
                    ),
                  )
                ],
              ),
            ))
        : Container(
            padding: EdgeInsets.symmetric(horizontal: 36),
            margin: EdgeInsets.only(top: 20),
            child: Container(
              width: double.infinity,
              child: FutureBuilder(
                future:
                    FirebaseStorage.instance.ref(imagePath).getDownloadURL(),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  print(snapshot.data);
                  if (snapshot.data != null) {
                    return Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: MediaQuery.of(context).size.width * 0.08,
                          child: CircleAvatar(
                            radius: MediaQuery.of(context).size.width * 0.07,
                            backgroundColor: Colors.white,
                            backgroundImage: NetworkImage(snapshot.data),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                id,
                                style: TextStyle(color: Colors.white),
                              )
                            ],
                          ),
                        )
                      ],
                    );
                  }
                  return Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: MediaQuery.of(context).size.width * 0.08,
                        child: CircleAvatar(
                          radius: MediaQuery.of(context).size.width * 0.065,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Loading ...",
                              style: TextStyle(color: Colors.white),
                            ),
                            Container()
                          ],
                        ),
                      )
                    ],
                  );
                  ;
                },
              ),
            ),
          );
  }

  Widget cardCheckIn() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 36),
      width: double.infinity,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.38,
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 1,
            offset: Offset(0, 1),
          )
        ], borderRadius: BorderRadius.circular(10), color: Colors.white),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [imageSwitchOnDayTime(), clock(), buttonSignIn()],
          )),
        ),
      ),
    );
  }

  Widget realtimeLocation(var state) {
    return Container(
      child: StreamBuilder(
        stream: Geolocator.getPositionStream(
            desiredAccuracy: LocationAccuracy.high,
            intervalDuration: Duration(seconds: 10)),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          //print(snapshot.data);
          if (snapshot.hasData) {
            var position = snapshot.data;
            var distance = Geolocator.distanceBetween(position.latitude,
                position.longitude, kxBuildingLatitude, kxBuildingLongtitude);
            print(distance);

            return isButtonLoading == true
                ? Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Center(child: CircularProgressIndicator()))
                : FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection("check_in_switch")
                        .where("id", isEqualTo: id)
                        .get()
                        .then((value) {
                      var data;
                      value.docs.forEach((element) {
                        data = element.data()['checkInState'];
                      });
                      return data;
                    }),
                    builder: (context, snapshot) {
                      print(snapshot.data);
                      return RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: state == false
                            ? Theme.of(context).primaryColor
                            : Colors.red,
                        onPressed: distance > 60 || snapshot.data == true
                            ? null
                            : () {
                                setState(() {
                                  isButtonLoading = true;
                                });
                                print(state);
                                camera(ImageSource.camera).then((value) async {
                                  print("Camera : $value");
                                  if (imageFile != null) {
                                    await imageProcess().then((value) {
                                      print(value['message']);
                                      if (value['message'] == "Match!") {
                                        state == true
                                            ? setCheckOut(state)
                                            : setCheckIn(state);
                                      } else {
                                        _showMyDialog();
                                        setState(() {
                                          isButtonLoading = false;
                                        });
                                      }
                                    });
                                  } else {
                                    setState(() {
                                      isButtonLoading = false;
                                    });
                                  }
                                });
                              },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              state == false ? "Check In" : "Check Out",
                              style: TextStyle(color: Colors.white),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 10),
                              child: Icon(
                                state == false ? Icons.login : Icons.logout,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    });
          }
          return Container();
        },
      ),
    );
  }

  Widget buttonSignIn() {
    return docId == null
        ? Container(
            margin: EdgeInsets.symmetric(vertical: 15),
            width: double.infinity,
            height: 50,
            child: Center(child: CircularProgressIndicator()))
        : Container(
            margin: EdgeInsets.symmetric(vertical: 15),
            width: double.infinity,
            height: 50,
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("check_in_switch")
                  .doc(docId)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.connectionState == ConnectionState.active) {
                  return realtimeLocation(snapshot.data['checkInSwitch']);
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          );
  }

  Widget imageSwitchOnDayTime() {
    var now = new DateTime.now();
    if (new DateFormat("a").format(now) == "AM") {
      return Column(
        children: [
          Image.asset(
            "assets/dawn.png",
            width: MediaQuery.of(context).size.width * 0.2,
          ),
          Text(
            "Good morning",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
                color: Color.fromRGBO(253, 208, 32, 1)),
          )
        ],
      );
    } else {
      return Column(
        children: [
          Image.asset(
            "assets/sunset.png",
            width: MediaQuery.of(context).size.width * 0.2,
          ),
          Text(
            "Good afternoon",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
                color: Colors.orange),
          ),
        ],
      );
    }
  }

  Widget clock() {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child:
              TimerBuilder.periodic(Duration(seconds: 1), builder: (context) {
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
            style:
                TextStyle(fontSize: 18, color: Color.fromRGBO(61, 61, 61, 1)),
          ),
        ),
      ],
    );
  }

  Widget announcement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Text("Announcement"),
        ),
        Container(
          height: MediaQuery.of(context).size.width * 0.6,
          width: double.infinity,
          child: FutureBuilder(
            initialData: [],
            future: FirebaseFirestore.instance
                .collection('announcement')
                .get()
                .then((QuerySnapshot querySnapshot) {
              var arr = [];
              querySnapshot.docs.forEach((element) {
                arr.add(element.data());
              });
              return arr;
            }),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              print(snapshot.data.length);
              if (snapshot.data != null) {
                return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        height: MediaQuery.of(context).size.width * 0.6,
                        width: MediaQuery.of(context).size.width * 0.8,
                        padding: EdgeInsets.only(left: 36, top: 10, bottom: 10),
                        child: Container(
                          padding:
                              EdgeInsets.only(left: 10, right: 10, top: 10),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 2,
                                  blurRadius: 1,
                                  offset: Offset(0, 1),
                                )
                              ]),
                          child: Text(snapshot.data[index]['message']),
                        ),
                      );
                    });
              }
              return CircularProgressIndicator();
            },
          ),
        ),
      ],
    );
  }
}
