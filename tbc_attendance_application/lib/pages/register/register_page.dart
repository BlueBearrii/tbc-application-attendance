import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  CollectionReference identify =
      FirebaseFirestore.instance.collection('identify_employee');
  CollectionReference user =
      FirebaseFirestore.instance.collection('users_account');
  CollectionReference approve =
      FirebaseFirestore.instance.collection('approve');
  CollectionReference checkInSwitch =
      FirebaseFirestore.instance.collection('check_in_switch');

  FirebaseStorage storage = FirebaseStorage.instance;

  var identifyPageRender = false;
  var isLoading = false;
  var isSubmit = false;

  var id;
  var email;
  var password;
  var imagePath;
  var confirmPassword;
  var imageFile;
  var name;
  var manager;

  // validator
  var idErrors;
  var emailErrors;
  var passwordToggle = true;
  var confirmPasswordToggle = true;
  var idHasAccount = false;

  final _formKey = GlobalKey<FormState>();

  Future camera(ImageSource imageSource) async {
    try {
      var selfieImageFile = await ImagePicker.pickImage(source: imageSource);
      setState(() {
        imageFile = selfieImageFile;
      });
    } catch (errors) {}
  }

  Future idValidator() async {
    var isExists = false;
    var isisExistsAccount = false;

    await user
        .where("id", isEqualTo: id)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((element) {
        print(element.data());
        if (element.data().isNotEmpty) {
          isisExistsAccount = true;
        }
      });
    });

    await identify.get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((element) async {
        if (id == element.data()['id']) {
          isExists = true;
        }
      });
    });

    setState(() {
      idErrors = isExists;
      idHasAccount = isisExistsAccount;
    });
    print(idErrors);
  }

  Future emailValidator() async {
    var errors = {"invalid": false, "isExists": false};

    EmailValidator.validate(email)
        ? errors["invalid"] = true
        : errors["invalid"] = false;
    await user.get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((element) {
        if (element.data()['email'] == email) {
          errors["isExists"] = true;
        }
      });
    });

    setState(() {
      emailErrors = errors;
    });
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
        name = element.data()['name'];
        manager = element.data()['manager'];
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

  Future registerAccount() async {
    var returnStatus = false;

    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((value) async {
      print(value);
      await user.add({
        "email": email,
        "id": id,
        "name": name,
        "pic": imagePath,
        "uid": value.user.uid,
        "manager": manager
      }).then((value) async {
        await approve
            .doc(id)
            .set({"id": id, "approveState": false}).then((value) async {
          await checkInSwitch.add({
            "id": id,
            "checkInSwitch": false,
            "checkInState": false
          }).then((value) {
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/app', (Route<dynamic> route) => false);
            returnStatus = true;
          }).catchError((onError) {
            print(onError);
            returnStatus = false;
          });
        }).catchError((onError) {
          print(onError);
          returnStatus = false;
        });
      }).catchError((onError) {
        print(onError);
        returnStatus = false;
      });
    }).catchError((onError) {
      print(onError);
    });

    return returnStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: true,
        appBar: AppBar(
          title: Text("Register"),
        ),
        body: SingleChildScrollView(
          child: SafeArea(
              child: Container(
            padding: EdgeInsets.symmetric(horizontal: 36),
            child: Column(
              children: [
                pageNumber(),
                titlePage(),
                identifyPageRender ? identifyPage() : informationPage()
              ],
            ),
          )),
        ));
  }

  Widget pageNumber() {
    return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                "1",
                style: TextStyle(color: Colors.white),
              ),
            ),
            Container(
              width: 100,
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                color: identifyPageRender
                    ? Theme.of(context).primaryColor
                    : Color.fromRGBO(139, 139, 139, 1),
                height: 50,
              ),
            ),
            CircleAvatar(
              backgroundColor: identifyPageRender
                  ? Theme.of(context).primaryColor
                  : Colors.grey[200],
              child: Text(
                "2",
                style: TextStyle(
                    color: identifyPageRender ? Colors.white : Colors.grey),
              ),
            )
          ],
        ));
  }

  Widget titlePage() {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 20),
      width: double.infinity,
      child: Row(
        children: [
          Text(
            identifyPageRender ? "Step 2" : "Step 1",
          ),
          Expanded(child: Container()),
          Text(identifyPageRender
              ? "Please identify with image"
              : "Information"),
        ],
      ),
    );
  }

  Widget informationPage() {
    return Container(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 10.0),
              child: TextFormField(
                initialValue: id,
                validator: (value) {
                  if (id != null) {
                    if (id == "") {
                      return "Must not be empty";
                    } else {
                      if (idErrors == false) {
                        return "Invalid employee id";
                      }
                      if (idHasAccount == true) {
                        return "already have account";
                      }
                    }
                  }

                  return null;
                },
                onChanged: (value) async {
                  setState(() {
                    id = value;
                  });
                  await idValidator().then((value) {
                    _formKey.currentState.validate();
                  });
                },
                decoration: InputDecoration(
                  labelText: "Employee id",
                  prefixIcon: Icon(
                    Icons.people,
                  ),
                  suffixIcon: Icon(Icons.check_circle_outline,
                      color: id != null &&
                              idErrors == true &&
                              idHasAccount == false
                          ? Colors.green
                          : Colors.grey),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: id != null && idErrors == true
                              ? Colors.green
                              : Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: id != null
                              ? idErrors == true
                                  ? Colors.green
                                  : Colors.red
                              : Theme.of(context).primaryColor),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10.0),
              child: TextFormField(
                initialValue: email,
                validator: (value) {
                  if (email != null) {
                    if (email == "") {
                      return "Please enter your email address";
                    } else {
                      if (emailErrors['isExists'] == true) {
                        return "Email already in use";
                      } else {
                        if (emailErrors['invalid'] == false) {
                          return "Invalid email";
                        }
                      }
                    }
                  }
                  return null;
                },
                onChanged: (value) async {
                  setState(() {
                    email = value;
                  });
                  await emailValidator().then((value) {
                    _formKey.currentState.validate();
                  });
                },
                decoration: InputDecoration(
                  labelText: "Email address",
                  prefixIcon: Icon(Icons.email),
                  suffixIcon: Icon(
                    Icons.check_circle_outline,
                    color: email != null &&
                            emailErrors != null &&
                            emailErrors['isExists'] == false &&
                            emailErrors['invalid']
                        ? Colors.green
                        : Colors.grey,
                  ),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: email != null &&
                                emailErrors != null &&
                                emailErrors['isExists'] == false &&
                                emailErrors['invalid']
                            ? Colors.green
                            : Colors.grey,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: email != null &&
                                emailErrors != null &&
                                emailErrors['isExists'] == false &&
                                emailErrors['invalid']
                            ? Colors.green
                            : Theme.of(context).primaryColor,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10.0),
              child: TextFormField(
                initialValue: password,
                validator: (value) {
                  if (password != null) {
                    if (password == "") {
                      return "Please enter password";
                    } else {
                      if (password.length < 7) {
                        return "Password should be more than 6 character";
                      }
                    }
                  }

                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    password = value;
                  });
                  _formKey.currentState.validate();
                },
                obscureText: passwordToggle,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          passwordToggle = !passwordToggle;
                        });
                      },
                      child: Icon(
                        Icons.remove_red_eye_outlined,
                        color: passwordToggle
                            ? Colors.grey
                            : Theme.of(context).primaryColor,
                      )),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: password != null
                              ? password.length > 6
                                  ? Colors.green
                                  : Colors.grey
                              : Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: password != null
                              ? password.length > 6
                                  ? Colors.green
                                  : Colors.grey
                              : Theme.of(context).primaryColor),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10.0),
              child: TextFormField(
                initialValue: confirmPassword,
                validator: (value) {
                  if (confirmPassword != null) {
                    if (confirmPassword == "") {
                      return "Please enter confirm passwordpassword";
                    } else {
                      if (confirmPassword.length < 6) {
                        return "Confirm password should be more than 6 character";
                      } else {
                        if (confirmPassword != password) {
                          return "Password not match";
                        }
                      }
                    }
                  }

                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    confirmPassword = value;
                  });
                  _formKey.currentState.validate();
                },
                obscureText: confirmPasswordToggle,
                decoration: InputDecoration(
                  labelText: "Confirm password",
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          confirmPasswordToggle = !confirmPasswordToggle;
                        });
                      },
                      child: Icon(
                        Icons.remove_red_eye_outlined,
                        color: confirmPasswordToggle
                            ? Colors.grey
                            : Theme.of(context).primaryColor,
                      )),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: confirmPassword != null
                              ? confirmPassword == password
                                  ? Colors.green
                                  : Colors.grey
                              : Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: confirmPassword != null
                              ? confirmPassword == password
                                  ? Colors.green
                                  : Colors.grey
                              : Theme.of(context).primaryColor),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 50.0),
              width: double.infinity,
              height: 50,
              child: RaisedButton(
                color: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                onPressed: () {
                  if (id != null &&
                      email != null &&
                      password != null &&
                      confirmPassword != null) {
                    if (_formKey.currentState.validate()) {
                      setState(() {
                        identifyPageRender = !identifyPageRender;
                      });
                    }
                  }
                },
                child: Text(
                  "Next",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget identifyPage() {
    return Container(
        width: double.infinity,
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width - 62,
              height: MediaQuery.of(context).size.width - 62,
              decoration: BoxDecoration(border: Border.all(width: 0.25)),
              child: Center(
                child: GestureDetector(
                    onTap: () {
                      camera(ImageSource.camera).then((value) {
                        setState(() {
                          isLoading = true;
                        });
                      });
                    },
                    child: imageFile != null
                        ? Image.file(imageFile)
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt),
                              Text("Tab here")
                            ],
                          )),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 15),
              child: isLoading
                  ? FutureBuilder(
                      future: imageProcess(),
                      builder: (BuildContext context,
                          AsyncSnapshot<dynamic> snapshot) {
                        print(snapshot.data);
                        switch (snapshot.connectionState) {
                          case ConnectionState.none:
                            return Center(
                              child: Text("none"),
                            );
                          case ConnectionState.waiting:
                            return LinearProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(
                                    Theme.of(context).primaryColor));
                          case ConnectionState.active:
                            return LinearProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(
                                    Theme.of(context).primaryColor));
                          case ConnectionState.done:
                            if (snapshot.data['message'] == "Match!") {
                              return Container(
                                child: Row(
                                  children: [
                                    TextButton(
                                        onPressed: () {
                                          camera(ImageSource.camera);
                                        },
                                        child: Text("Retake",
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor))),
                                    Expanded(child: Container()),
                                    TextButton(
                                        onPressed: () {
                                          setState(() {
                                            isSubmit = true;
                                          });
                                          registerAccount();
                                        },
                                        child: Text(
                                          "Register",
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        ))
                                  ],
                                ),
                              );
                            }
                            if (snapshot.data['status'] == "failed" ||
                                snapshot.data['message'] == "Not Match!") {
                              return Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Something wrong,"),
                                    TextButton(
                                        onPressed: () {
                                          camera(ImageSource.camera);
                                        },
                                        child: Text("try again",
                                            style: TextStyle(
                                                decoration:
                                                    TextDecoration.underline,
                                                color: Colors.red))),
                                  ],
                                ),
                              );
                            }
                        }
                        return LinearProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(
                              Theme.of(context).primaryColor),
                        );
                      },
                    )
                  : Container(),
            ),
            isSubmit
                ? FutureBuilder(
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.data == false) {
                          return Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Register error,"),
                                TextButton(
                                    onPressed: () {},
                                    child: Text("try again",
                                        style: TextStyle(
                                            decoration:
                                                TextDecoration.underline,
                                            color: Colors.red))),
                              ],
                            ),
                          );
                        }
                      }
                      return Container();
                    },
                  )
                : Container()
          ],
        ));
  }
}
