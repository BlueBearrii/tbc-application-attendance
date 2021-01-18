import 'package:firebase_auth/firebase_auth.dart';

class LoginFunctions {
  FirebaseAuth auth = FirebaseAuth.instance;

  Future<List<bool>> onLoginSubmit(String email, password) async {
    bool loginState = false;
    bool error = false;
    await auth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) {
      loginState = true;
    }).catchError((onError) {
      print(onError);
      error = true;
      loginState = false;
    });
    return [loginState, error];
  }
}
