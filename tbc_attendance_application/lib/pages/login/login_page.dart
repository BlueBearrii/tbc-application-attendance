import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FirebaseAuth auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();
  String _email;
  String _password;

  bool _authError = false;
  bool isLoading = false;

  // Show password&confirm toggle
  bool passwordHide = true;

  Future onLoginSubmit() async {
    await auth
        .signInWithEmailAndPassword(email: _email, password: _password)
        .then((value) {
      print(value);
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/app', (Route<dynamic> route) => false);
      print(value);
    }).catchError((onError) {
      print("Error : $onError");
      setState(() {
        isLoading = false;
        _authError = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 36,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    child: Image.asset(
                      'assets/Logo.png',
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _email = value;
                        });
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.email,
                            color: Color.fromRGBO(139, 139, 139, 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                              borderSide: BorderSide(
                                  color: Color.fromRGBO(139, 139, 139, 1),
                                  width: 1.0)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                              borderSide: BorderSide(
                                  color: Color.fromRGBO(48, 49, 145, 1),
                                  width: 1.0)),
                          errorBorder: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                              borderSide:
                                  BorderSide(color: Colors.red, width: 1.0)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                              borderSide:
                                  BorderSide(color: Colors.red, width: 1.0)),
                          hintText: 'Email address'),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.text,
                      obscureText: passwordHide,
                      onChanged: (value) {
                        setState(() {
                          _password = value;
                        });
                      },
                      decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.lock,
                            color: Color.fromRGBO(139, 139, 139, 1),
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                passwordHide = !passwordHide;
                              });
                            },
                            child: Icon(
                              Icons.remove_red_eye,
                              color: Color.fromRGBO(139, 139, 139, 1),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                              borderSide: BorderSide(
                                  color: Color.fromRGBO(139, 139, 139, 1),
                                  width: 1.0)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                              borderSide: BorderSide(
                                  color: Color.fromRGBO(48, 49, 145, 1),
                                  width: 1.0)),
                          errorBorder: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                              borderSide:
                                  BorderSide(color: Colors.red, width: 1.0)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                              borderSide:
                                  BorderSide(color: Colors.red, width: 1.0)),
                          hintText: 'Enter password'),
                    ),
                  ),
                  Container(
                      child: _authError
                          ? Text(
                              "Invalid email or password incorrect",
                              style: TextStyle(color: Colors.red),
                            )
                          : null),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: isLoading
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : RaisedButton(
                              color: Color.fromRGBO(48, 49, 145, 1),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              onPressed: () async {
                                _formKey.currentState.validate();
                                if (_formKey.currentState.validate()) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  onLoginSubmit();
                                }
                              },
                              child: Text(
                                "Login",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14.0),
                              ),
                            ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, "/register");
                          },
                          child: Text("Register"),
                        ),
                      ),
                      Expanded(child: Container()),
                      Container(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, "/register");
                          },
                          child: Text("Forgot password"),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
