import 'package:flutter/material.dart';
import 'package:tbc_attendance_application/pages/login/login_class.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _email;
  String _password;

  bool _authError = false;
  bool isLoading = false;

  // Show password&confirm toggle
  bool _passwordHide = true;
  bool _confirmPasswordHide = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 36),
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
                      obscureText: _passwordHide,
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
                                _passwordHide = !_passwordHide;
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
                    margin: EdgeInsets.symmetric(vertical: 50),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: RaisedButton(
                        color: Color.fromRGBO(48, 49, 145, 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        onPressed: () async {
                          print(isLoading);
                          setState(() {
                            isLoading = true;
                          });
                          _formKey.currentState.validate();
                          if (_formKey.currentState.validate()) {
                            print(isLoading);
                            LoginFunctions()
                                .onLoginSubmit(_email, _password)
                                .then((value) {
                              setState(() {
                                isLoading = false;
                              });
                              print(value);
                              if (value[0]) {
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                    '/app', (Route<dynamic> route) => false);
                              }
                              if (value[1]) {
                                setState(() {
                                  _authError = true;
                                });
                              }
                            });
                          } else {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        },
                        child: isLoading
                            ? Center(
                                child: CircularProgressIndicator(),
                              )
                            : Text(
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
