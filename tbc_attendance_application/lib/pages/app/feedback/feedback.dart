import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({Key key}) : super(key: key);

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  var _selectedReciever = "- Select the employee -";
  var initialRecieverLists = ["- Select the employee -"];
  var message;
  final _formKey = GlobalKey<FormState>();

  Future fetchEmployeeLists() async {
    await FirebaseFirestore.instance
        .collection('identify_employee')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        print(doc.data()['name']);
        if (mounted) {
          setState(() {
            initialRecieverLists.add(doc.data()['name'].toString());
          });
        }
      });
    });
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Feedback'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Message was send'),
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

  sendFeedBack() async {
    await FirebaseFirestore.instance
        .collection('feedback')
        .doc(DateTime.now().toIso8601String())
        .set({
      "name": _selectedReciever,
      "message": message,
      "timestamp": DateTime.now().toIso8601String()
    }).then((value) {
      setState(() {
        _formKey.currentState.reset();
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState

    fetchEmployeeLists();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    fetchEmployeeLists();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 36, vertical: 20),
          width: double.infinity,
          color: Theme.of(context).backgroundColor,
          child: Column(
            children: [
              Row(
                children: [
                  Text("Select the reciever"),
                ],
              ),
              Container(
                width: double.infinity,
                child: dropdownToSelectReciever(),
              ),
              Row(
                children: [
                  Text("Comment"),
                ],
              ),
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Form(
                  key: _formKey,
                  child: TextFormField(
                    onChanged: (value) {
                      if (value.length < 120) {
                        setState(() {
                          message = value;
                        });
                      }
                      print(message);
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Enter your message",
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          width: 0.25,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          width: 0.25,
                        ),
                      ),
                    ),
                    maxLength: 120,
                    maxLines: 10,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 50,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  color: Colors.white,
                  onPressed: () {
                    _showMyDialog();
                    sendFeedBack();
                  },
                  child: Text("Send",
                      style: TextStyle(color: Theme.of(context).primaryColor)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget dropdownToSelectReciever() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: 0.25),
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: DropdownButton<String>(
        value: _selectedReciever,
        iconSize: 24,
        elevation: 8,
        isExpanded: true,
        style: TextStyle(color: Theme.of(context).primaryColor),
        underline: Container(color: Colors.transparent),
        onChanged: (String newValue) {
          setState(() {
            _selectedReciever = newValue;
          });
        },
        items: initialRecieverLists.map<DropdownMenuItem<String>>((value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }
}
