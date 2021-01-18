import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class RegisterNewAccount {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  Future<bool> identifyEmployeeId(String empId) async {
    var status = false;
    await firestore
        .collection("identify_employee")
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                if (doc["id"] == empId) return status = true;
              })
            });
    return status;
  }

  Future<bool> identifyImage(File img, empId) async {
    bool status = false;
    String picName;
    await firestore
        .collection("identify_employee")
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                print(doc.data()["pic"]);
                if (doc["id"] == empId) return picName = doc.data()["pic"];
              })
            });

    String downloadURL = await firebase_storage.FirebaseStorage.instance
        .ref(picName)
        .getDownloadURL();

    //final documentDirectory = await getApplicationDocumentsDirectory();
    //final file = File(join(documentDirectory.path, 'imagetest.png'));

    var rng = new Random();
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File file = new File('$tempPath' + (rng.nextInt(100)).toString() + '.png');
    http.Response response = await http.get(downloadURL);
    await file.writeAsBytes(response.bodyBytes);
    print(file);

    Response responsed;
    Dio dio = new Dio();
    FormData formData = new FormData.fromMap({
      "source": await MultipartFile.fromFile(
        img.path,
        filename: file.toString(),
      ),
      "target":
          await MultipartFile.fromFile(file.path, filename: file.toString()),
    });
    responsed = await dio.post(
        "http://faceapi.vistecbooking.cybertoryth.com/compare",
        data: formData);

    //print(responsed.data["message"]);

    if (responsed.data["message"] == "Match!") status = true;

    return status;
  }

  Future<bool> registerEmployee(user, File img) async {
    bool returnStatus = false;
    if (await identifyImage(img, user["employeeId"])) {
      await auth
          .createUserWithEmailAndPassword(
              email: user["email"], password: user["password"])
          .then((value) {
        print(value);
        returnStatus = true;
      }).catchError((onError) {
        print(onError);
        returnStatus = false;
      });
    }

    return returnStatus;
  }
}
