// import 'dart:io';
// import 'dart:math';
// import 'dart:ui';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:dio/dio.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
// import 'package:http/http.dart' as http;

// class RegisterPage extends StatefulWidget {
//   RegisterPage({Key key}) : super(key: key);

//   @override
//   _RegisterPageState createState() => _RegisterPageState();
// }

// class _RegisterPageState extends State<RegisterPage> {
// /* -------------------------------------------------------------------------- */
// /*                             Initialize firebase                            */
// /* -------------------------------------------------------------------------- */
//   FirebaseFirestore firestore = FirebaseFirestore.instance;
//   FirebaseAuth auth = FirebaseAuth.instance;
//   firebase_storage.FirebaseStorage storage =
//       firebase_storage.FirebaseStorage.instance;

// /* -------------------------------------------------------------------------- */
// /*                                  Variable                                  */
// /* -------------------------------------------------------------------------- */
//   final _formKey = GlobalKey<FormState>();
//   // User information
//   String _employeeId;
//   String _email;
//   String _password;
//   String _confirmPassword;
//   File imageFile;

//   bool manager = false;
//   String pic;
//   String username;

//   // Show password&confirm toggle
//   bool _passwordHide = true;
//   bool _confirmPasswordHide = true;

//   // Custom form validator
//   bool _employeeIdValidator = false;
//   bool _emailValidator = false;
//   bool _passwordValidator = false;
//   bool _confirmPasswordValidator = false;

//   bool loading = false;
//   bool registerState = false;
//   bool errorStatus = false;

//   // Key switch page
//   // 1 : information page
//   // 2 : verify page
//   int _onPage = 1;

// /* -------------------------------------------------------------------------- */
// /*                                  Functions                                 */
// /* -------------------------------------------------------------------------- */

//   bool onSubmitCheckError() {
//     if (_emailValidator == false ||
//         _emailValidator == false ||
//         _passwordValidator == false ||
//         _confirmPasswordValidator == false)
//       return false;
//     else
//       return true;
//   }

//   // Function use default camera
//   Future _isCameraOnPress(ImageSource imageSource) async {
//     try {
//       var obj = await ImagePicker.pickImage(source: imageSource);
//       setState(() {
//         imageFile = obj;
//       });
//     } catch (errors) {}
//   }

//   Future<bool> identifyEmployeeId(String empId) async {
//     await firestore
//         .collection("identify_employee")
//         .get()
//         .then((QuerySnapshot querySnapshot) => {
//               querySnapshot.docs.forEach((doc) {
//                 if (doc["id"] == empId)
//                   setState(() {
//                     _employeeIdValidator = true;
//                   });
//               })
//             });
//   }

//   Future<bool> identifyImage() async {
//     var status = false;
//     String picName;
//     await firestore
//         .collection("identify_employee")
//         .get()
//         .then((QuerySnapshot querySnapshot) => {
//               querySnapshot.docs.forEach((doc) {
//                 print(doc.data()["pic"]);
//                 if (doc["id"] == _employeeId)
//                   return picName = doc.data()["pic"];
//               })
//             });

//     String downloadURL = await firebase_storage.FirebaseStorage.instance
//         .ref(picName)
//         .getDownloadURL()
//         .catchError(() {
//       return status = false;
//     });

//     //final documentDirectory = await getApplicationDocumentsDirectory();
//     //final file = File(join(documentDirectory.path, 'imagetest.png'));

//     var rng = new Random();
//     Directory tempDir = await getTemporaryDirectory();
//     String tempPath = tempDir.path;
//     File file = new File('$tempPath' + (rng.nextInt(100)).toString() + '.png');
//     http.Response response = await http.get(downloadURL);
//     await file.writeAsBytes(response.bodyBytes);
//     print(file);

//     Response responsed;
//     Dio dio = new Dio();
//     FormData formData = new FormData.fromMap({
//       "source": await MultipartFile.fromFile(
//         imageFile.path,
//         filename: file.toString(),
//       ),
//       "target":
//           await MultipartFile.fromFile(file.path, filename: file.toString()),
//     });
//     responsed = await dio.post(
//         "https://faceapi-vistecbooking.cybertoryth.com/compare",
//         data: formData);

//     print(responsed.data);

//     if (responsed.data["message"] == "Match!")
//       status = true;
//     else
//       status = false;

//     return status;
//   }

//   Future registerEmployee() async {
//     if (await identifyImage()) {
//       await firestore
//           .collection("identify_employee")
//           .get()
//           .then((QuerySnapshot querySnapshot) => {
//                 querySnapshot.docs.forEach((doc) {
//                   if (doc["id"] == _employeeId) {
//                     username = doc.data()["name"];
//                     pic = doc.data()["pic"];
//                     manager = doc.data()["manager"];
//                   }
//                 })
//               })
//           .then((value) async {
//         await auth
//             .createUserWithEmailAndPassword(email: _email, password: _password)
//             .then((value) {
//           firestore.collection('users').add({
//             "employeeId": _employeeId,
//             "email": _email,
//             "name": username,
//             "manager": manager,
//             "pic": pic,
//           }).then((value) {
//             firestore
//                 .collection('check_in_state')
//                 .doc(_employeeId)
//                 .set({"checkIn": false}).then((value) {
//               firestore
//                   .collection('approve_state')
//                   .doc(_employeeId)
//                   .set({"approveState": false}).then((value) {
//                 firestore
//                     .collection('feedback')
//                     .doc(_employeeId)
//                     .set({"messageBox": {}}).then((value) {
//                   setState(() {
//                     loading = false;
//                     registerState = true;
//                     errorStatus = false;
//                   });
//                 }).catchError((onError) {
//                   loading = false;
//                   registerState = false;
//                   errorStatus = true;
//                 });
//               }).catchError((onError) {
//                 loading = false;
//                 registerState = false;
//                 errorStatus = true;
//               });
//             }).catchError((onError) {
//               loading = false;
//               registerState = false;
//               errorStatus = true;
//             });
//           }).catchError((onError) {
//             loading = false;
//             registerState = false;
//             errorStatus = true;
//           });
//         }).catchError((onError) {
//           loading = false;
//           registerState = false;
//           errorStatus = true;
//         });
//       });
//     }
//   }

// /* -------------------------------------------------------------------------- */
// /* -------------------------------------------------------------------------- */

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       resizeToAvoidBottomPadding: true,

// /* -------------------------------------------------------------------------- */
// /*                               APP BAR CUSTOM                               */
// /* -------------------------------------------------------------------------- */

//       appBar: AppBar(
//         elevation: 0,
//         centerTitle: false,
//         title: Text(
//           "REGISTER",
//           style: TextStyle(
//               fontFamily: "Roboto",
//               fontWeight: FontWeight.bold,
//               color: Color.fromRGBO(48, 49, 145, 1)),
//         ),
//         leading: GestureDetector(
//           onTap: () {
//             Navigator.pop(context);
//           },
//           child: Icon(
//             Icons.arrow_back,
//             color: Color.fromRGBO(48, 49, 145, 1),
//           ),
//         ),
//         backgroundColor: Colors.white,
//       ),

// /* -------------------------------------------------------------------------- */
// /*                                    BODY                                    */
// /* -------------------------------------------------------------------------- */

//       body: SingleChildScrollView(
//         child: Container(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 36.0),
//             child: Column(
//               children: [
// /* -------------------------------------------------------------------------- */
// /*                               SHOW STEP TITLE                              */
// /* -------------------------------------------------------------------------- */

//                 Container(
//                   width: double.infinity,
//                   margin: EdgeInsets.symmetric(vertical: 10.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Expanded(
//                         child: GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               _onPage = 1;
//                             });
//                           },
//                           child: Container(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 CircleAvatar(
//                                   radius: 20,
//                                   backgroundColor:
//                                       Color.fromRGBO(48, 49, 145, 1),
//                                   child: Center(
//                                       child: Text(
//                                     "1",
//                                     style: TextStyle(color: Colors.white),
//                                   )),
//                                 ),
//                                 Text(
//                                   "Information",
//                                   style: TextStyle(
//                                     color: Color.fromRGBO(48, 49, 145, 1),
//                                   ),
//                                 )
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         child: Divider(
//                           color: _onPage == 2
//                               ? Color.fromRGBO(48, 49, 145, 1)
//                               : Color.fromRGBO(139, 139, 139, 1),
//                           height: 30,
//                         ),
//                       ),
//                       Expanded(
//                         child: GestureDetector(
//                           child: Container(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 CircleAvatar(
//                                   radius: 20,
//                                   backgroundColor: _onPage == 2
//                                       ? Color.fromRGBO(48, 49, 145, 1)
//                                       : Color.fromRGBO(139, 139, 139, 1),
//                                   child: Center(
//                                       child: Text(
//                                     "2",
//                                     style: TextStyle(color: Colors.white),
//                                   )),
//                                 ),
//                                 Text(
//                                   "Verify",
//                                   style: TextStyle(
//                                     color: _onPage == 2
//                                         ? Color.fromRGBO(48, 49, 145, 1)
//                                         : Color.fromRGBO(139, 139, 139, 1),
//                                   ),
//                                 )
//                               ],
//                             ),
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),

// /* -------------------------------------------------------------------------- */
// /*                         FORM INPUT USER INFORMATION                        */
// /* -------------------------------------------------------------------------- */

//                 Container(
//                   margin: EdgeInsets.only(top: 20.0),
//                   child: _onPage == 1
//                       ? Theme(
//                           data: Theme.of(context).copyWith(
//                               primaryColor: Color.fromRGBO(48, 49, 145, 1)),
//                           child: Form(
//                               key: _formKey,
//                               child: Column(
//                                 children: [
//                                   Column(children: [
//                                     /* -------------------------------------------------------------------------- */
//                                     /*                              Employee Id input                             */
//                                     /* -------------------------------------------------------------------------- */
//                                     Container(
//                                         margin: EdgeInsets.symmetric(
//                                             vertical: 10.0),
//                                         alignment: Alignment.centerLeft,
//                                         child: Text("Employee id")),
//                                     TextFormField(
//                                       validator: (value) {
//                                         if (value.isEmpty) {
//                                           return 'Please enter some text';
//                                         }
//                                         if (_employeeIdValidator != true) {
//                                           return 'Incorrect employee id';
//                                         }
//                                         return null;
//                                       },
//                                       initialValue: _employeeId,
//                                       onChanged: (value) async {
//                                         setState(() {
//                                           _employeeId = value;
//                                         });
//                                         await identifyEmployeeId(value);

//                                         _formKey.currentState.validate();
//                                       },
//                                       keyboardType: TextInputType.text,
//                                       decoration: InputDecoration(
//                                           prefixIcon: Icon(Icons.people_alt),
//                                           suffix: _employeeIdValidator
//                                               ? Icon(
//                                                   Icons.check_circle,
//                                                   size: 15,
//                                                   color: Colors.green,
//                                                 )
//                                               : null,
//                                           enabledBorder: OutlineInputBorder(
//                                               borderRadius:
//                                                   const BorderRadius.all(
//                                                 Radius.circular(10.0),
//                                               ),
//                                               borderSide: BorderSide(
//                                                   color: Color.fromRGBO(
//                                                       139, 139, 139, 1),
//                                                   width: 1.0)),
//                                           focusedBorder: OutlineInputBorder(
//                                               borderRadius:
//                                                   const BorderRadius.all(
//                                                 Radius.circular(10.0),
//                                               ),
//                                               borderSide: BorderSide(
//                                                   color: _employeeIdValidator
//                                                       ? Color.fromRGBO(
//                                                           48, 49, 145, 1)
//                                                       : Colors.red,
//                                                   width: 1.0)),
//                                           errorBorder: OutlineInputBorder(
//                                               borderRadius:
//                                                   const BorderRadius.all(
//                                                 Radius.circular(10.0),
//                                               ),
//                                               borderSide: BorderSide(
//                                                   color: Colors.red,
//                                                   width: 1.0)),
//                                           hintText: 'Enter your employee id'),
//                                     ),
//                                   ]),

//                                   /* -------------------------------------------------------------------------- */
//                                   /*                                 Email input                                */
//                                   /* -------------------------------------------------------------------------- */

//                                   Column(children: [
//                                     Container(
//                                         margin: EdgeInsets.symmetric(
//                                             vertical: 10.0),
//                                         alignment: Alignment.centerLeft,
//                                         child: Text("Email address")),
//                                     TextFormField(
//                                       validator: (value) {
//                                         if (value.isEmpty) {
//                                           return 'Please enter your email';
//                                         }
//                                         if (_emailValidator != true) {
//                                           return 'Invalid email';
//                                         }
//                                         return null;
//                                       },
//                                       initialValue: _email,
//                                       onChanged: (value) async {
//                                         //print(value);
//                                         setState(() {
//                                           _email = value;
//                                         });

//                                         if (RegExp(
//                                                 r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
//                                             .hasMatch(_email)) {
//                                           setState(() {
//                                             _emailValidator = true;
//                                           });
//                                         } else {
//                                           setState(() {
//                                             _emailValidator = false;
//                                           });
//                                         }

//                                         _formKey.currentState.validate();
//                                       },
//                                       keyboardType: TextInputType.emailAddress,
//                                       decoration: InputDecoration(
//                                           prefixIcon: Icon(Icons.email),
//                                           enabledBorder: OutlineInputBorder(
//                                               borderRadius:
//                                                   const BorderRadius.all(
//                                                 Radius.circular(10.0),
//                                               ),
//                                               borderSide: BorderSide(
//                                                   color: Color.fromRGBO(
//                                                       139, 139, 139, 1),
//                                                   width: 1.0)),
//                                           focusedBorder: OutlineInputBorder(
//                                               borderRadius:
//                                                   const BorderRadius.all(
//                                                 Radius.circular(10.0),
//                                               ),
//                                               borderSide: BorderSide(
//                                                   color: _emailValidator
//                                                       ? Color.fromRGBO(
//                                                           48, 49, 145, 1)
//                                                       : Colors.red,
//                                                   width: 1.0)),
//                                           errorBorder: OutlineInputBorder(
//                                               borderRadius:
//                                                   const BorderRadius.all(
//                                                 Radius.circular(10.0),
//                                               ),
//                                               borderSide: BorderSide(
//                                                   color: Colors.red,
//                                                   width: 1.0)),
//                                           hintText: 'Please Enter your email'),
//                                     ),
//                                   ]),

//                                   /* -------------------------------------------------------------------------- */
//                                   /*                               Password input                               */
//                                   /* -------------------------------------------------------------------------- */

//                                   Column(children: [
//                                     Container(
//                                         margin: EdgeInsets.symmetric(
//                                             vertical: 10.0),
//                                         alignment: Alignment.centerLeft,
//                                         child: Text("Password")),
//                                     TextFormField(
//                                       validator: (value) {
//                                         if (value.isEmpty) {
//                                           return 'Please enter password';
//                                         }
//                                         if (_passwordValidator != true) {
//                                           return 'Password should be minimum 6 character';
//                                         }
//                                         return null;
//                                       },
//                                       initialValue: _password,
//                                       onChanged: (value) {
//                                         setState(() {
//                                           _password = value;
//                                         });

//                                         if (_password.length >= 6) {
//                                           setState(() {
//                                             _passwordValidator = true;
//                                           });
//                                         } else {
//                                           setState(() {
//                                             _passwordValidator = false;
//                                           });
//                                         }
//                                         _formKey.currentState.validate();
//                                       },
//                                       obscureText: _passwordHide,
//                                       decoration: InputDecoration(
//                                           prefixIcon: Icon(Icons.lock),
//                                           suffixIcon: GestureDetector(
//                                             onTap: () {
//                                               setState(() {
//                                                 _passwordHide = !_passwordHide;
//                                               });
//                                             },
//                                             child: Icon(Icons.remove_red_eye),
//                                           ),
//                                           enabledBorder: OutlineInputBorder(
//                                               borderRadius:
//                                                   const BorderRadius.all(
//                                                 Radius.circular(10.0),
//                                               ),
//                                               borderSide: BorderSide(
//                                                   color: Color.fromRGBO(
//                                                       139, 139, 139, 1),
//                                                   width: 1.0)),
//                                           focusedBorder: OutlineInputBorder(
//                                               borderRadius:
//                                                   const BorderRadius.all(
//                                                 Radius.circular(10.0),
//                                               ),
//                                               borderSide: BorderSide(
//                                                   color: _passwordValidator
//                                                       ? Color.fromRGBO(
//                                                           48, 49, 145, 1)
//                                                       : Colors.red,
//                                                   width: 1.0)),
//                                           errorBorder: OutlineInputBorder(
//                                               borderRadius:
//                                                   const BorderRadius.all(
//                                                 Radius.circular(10.0),
//                                               ),
//                                               borderSide: BorderSide(
//                                                   color: Colors.red,
//                                                   width: 1.0)),
//                                           hintText: "Minimum of 6 characters"),
//                                     ),
//                                   ]),

//                                   /* -------------------------------------------------------------------------- */
//                                   /*                           Confirm password input                           */
//                                   /* -------------------------------------------------------------------------- */

//                                   Column(children: [
//                                     Container(
//                                         margin: EdgeInsets.symmetric(
//                                             vertical: 10.0),
//                                         alignment: Alignment.centerLeft,
//                                         child: Text("Confirm password")),
//                                     TextFormField(
//                                       validator: (value) {
//                                         if (value.isEmpty) {
//                                           return 'Please confirm password';
//                                         }
//                                         if (_confirmPasswordValidator != true) {
//                                           return 'Password not match';
//                                         }
//                                         return null;
//                                       },
//                                       initialValue: _confirmPassword,
//                                       onChanged: (value) {
//                                         setState(() {
//                                           _confirmPassword = value;
//                                         });

//                                         if (_confirmPassword == _password) {
//                                           setState(() {
//                                             _confirmPasswordValidator = true;
//                                           });
//                                         } else {
//                                           setState(() {
//                                             _confirmPasswordValidator = false;
//                                           });
//                                         }
//                                         _formKey.currentState.validate();
//                                       },
//                                       obscureText: _confirmPasswordHide,
//                                       decoration: InputDecoration(
//                                           prefixIcon: Icon(Icons.lock),
//                                           suffixIcon: GestureDetector(
//                                             onTap: () {
//                                               setState(() {
//                                                 _confirmPasswordHide =
//                                                     !_confirmPasswordHide;
//                                               });
//                                             },
//                                             child: Icon(Icons.remove_red_eye),
//                                           ),
//                                           enabledBorder: OutlineInputBorder(
//                                               borderRadius:
//                                                   const BorderRadius.all(
//                                                 Radius.circular(10.0),
//                                               ),
//                                               borderSide: BorderSide(
//                                                   color: Color.fromRGBO(
//                                                       139, 139, 139, 1),
//                                                   width: 1.0)),
//                                           focusedBorder: OutlineInputBorder(
//                                               borderRadius:
//                                                   const BorderRadius.all(
//                                                 Radius.circular(10.0),
//                                               ),
//                                               borderSide: BorderSide(
//                                                   color:
//                                                       _confirmPasswordValidator
//                                                           ? Color.fromRGBO(
//                                                               48, 49, 145, 1)
//                                                           : Colors.red,
//                                                   width: 1.0)),
//                                           errorBorder: OutlineInputBorder(
//                                               borderRadius:
//                                                   const BorderRadius.all(
//                                                 Radius.circular(10.0),
//                                               ),
//                                               borderSide: BorderSide(
//                                                   color: Colors.red,
//                                                   width: 1.0)),
//                                           hintText: 'Re-enter your password'),
//                                     ),

//                                     /* -------------------------------------------------------------------------- */
//                                     /*                                 Next button                                */
//                                     /* -------------------------------------------------------------------------- */

//                                     Container(
//                                       margin:
//                                           EdgeInsets.symmetric(vertical: 100),
//                                       child: SizedBox(
//                                         width: double.infinity,
//                                         height: 50,
//                                         child: RaisedButton(
//                                           color: Color.fromRGBO(48, 49, 145, 1),
//                                           shape: RoundedRectangleBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(10.0)),
//                                           onPressed: () {
//                                             //print(_employeeId);
//                                             _formKey.currentState.validate();
//                                             if (onSubmitCheckError())
//                                               setState(() {
//                                                 _onPage = 2;
//                                               });
//                                           },
//                                           child: Text(
//                                             "Next",
//                                             style: TextStyle(
//                                                 color: Colors.white,
//                                                 fontSize: 14.0),
//                                           ),
//                                         ),
//                                       ),
//                                     )
//                                   ]),
//                                 ],
//                               )),
//                         )
//                       :

// /* -------------------------------------------------------------------------- */
// /*                                Take a picture                              */
// /* -------------------------------------------------------------------------- */

//                       Container(
//                           child: Column(
//                             children: [
//                               Text("Please take a photo to identify"),
//                               Container(
//                                 width: double.infinity,
//                                 margin: EdgeInsets.symmetric(vertical: 20.0),
//                                 height: 300,
//                                 decoration: BoxDecoration(
//                                     borderRadius:
//                                         BorderRadius.all(Radius.circular(10)),
//                                     border: Border.all(width: 0.25)),
//                                 child: imageFile == null
//                                     ? GestureDetector(
//                                         onTap: () {
//                                           //print("Clicked");
//                                           _isCameraOnPress(ImageSource.camera);
//                                         },
//                                         child: Icon(
//                                           Icons.camera_alt,
//                                           size: 50,
//                                           color:
//                                               Color.fromRGBO(139, 139, 139, 1),
//                                         ))
//                                     : Image.file(imageFile),
//                               ),
//                               Row(
//                                 children: imageFile != null
//                                     ? loading
//                                         ? [
//                                             Expanded(
//                                               child: Center(
//                                                 child: Container(
//                                                   child:
//                                                       CircularProgressIndicator(),
//                                                 ),
//                                               ),
//                                             )
//                                           ]
//                                         : [
//                                             Container(
//                                               child: GestureDetector(
//                                                   onTap: () {
//                                                     //print("Clicked");
//                                                     _isCameraOnPress(
//                                                         ImageSource.camera);
//                                                   },
//                                                   child: Text("Retake")),
//                                             ),
//                                             Expanded(
//                                               child: Container(),
//                                             ),
//                                             Container(
//                                               child: GestureDetector(
//                                                   onTap: () {
//                                                     setState(() {
//                                                       loading = true;
//                                                     });
//                                                     registerEmployee();
//                                                   },
//                                                   child: Text("Use")),
//                                             )
//                                           ]
//                                     : [],
//                               ),
//                               Container(
//                                 margin: EdgeInsets.symmetric(vertical: 100),
//                                 child: imageFile != null
//                                     ? registerState
//                                         ? SizedBox(
//                                             width: double.infinity,
//                                             height: 50,
//                                             child: RaisedButton(
//                                               color: Color.fromRGBO(
//                                                   48, 49, 145, 1),
//                                               shape: RoundedRectangleBorder(
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                           10.0)),
//                                               onPressed: () {
//                                                 Navigator.of(context)
//                                                     .pushNamedAndRemoveUntil(
//                                                         '/app',
//                                                         (Route<dynamic>
//                                                                 route) =>
//                                                             false);
//                                               },
//                                               child: Text(
//                                                 "Identify successful",
//                                                 style: TextStyle(
//                                                     color: Colors.white,
//                                                     fontSize: 14.0),
//                                               ),
//                                             ),
//                                           )
//                                         : errorStatus
//                                             ? Center(
//                                                 child: Text(
//                                                     "Something wrong please try again"),
//                                               )
//                                             : null
//                                     : null,
//                               )
//                             ],
//                           ),
//                         ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
