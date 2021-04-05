import 'package:flutter/material.dart';

class ErrorStatus extends StatelessWidget {
  const ErrorStatus({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black.withOpacity(0.0),
        body: GestureDetector(
          onTap: () {
            print("TAB");
            Navigator.of(context).pop();
          },
          child: Container(
            color: Colors.black.withOpacity(0.85),
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: Text(
                "Something wrong, please try again",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ));
  }
}
