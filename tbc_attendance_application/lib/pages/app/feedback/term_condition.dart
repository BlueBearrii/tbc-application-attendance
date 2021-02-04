import 'package:flutter/material.dart';

class TermAndCondition extends StatelessWidget {
  const TermAndCondition({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 36),
          width: double.infinity,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(bottom: 30),
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Image.asset(
                      "assets/flat_term.png",
                    ),
                  ),
                ),
                Expanded(child: Container()),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 20),
                  height: 50,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    color: Theme.of(context).primaryColor,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Next",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              ]),
        ),
      ),
    );
  }
}
