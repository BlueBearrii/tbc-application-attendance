import 'package:flutter/material.dart';

class EmotionPage extends StatelessWidget {
  const EmotionPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black.withOpacity(0.85),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.symmetric(horizontal: 36),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    margin: EdgeInsets.only(bottom: 15),
                    child: Text(
                      "How are you feeling today",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    )),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset("assets/angry.png"),
                    Image.asset("assets/frown.png"),
                    Image.asset("assets/confusing.png"),
                    Image.asset("assets/grinning.png"),
                    Image.asset("assets/blow-kiss.png"),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
