import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManagerManagement extends StatefulWidget {
  @override
  _ManagerManagementState createState() => _ManagerManagementState();
}

class _ManagerManagementState extends State<ManagerManagement> {
  CollectionReference users =
      FirebaseFirestore.instance.collection('team_members');
  CollectionReference allUser =
      FirebaseFirestore.instance.collection('identify_employee');

  var employeeId;
  var message;
  var data;

  final _formKey = GlobalKey<FormState>();

  void setInitialState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        employeeId = prefs.getString("id");
      });
    }
  }

  Future loadMember() async {
    var memberArray = [];
    await users.get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((element) {
        if (element.data()['manager'] == employeeId) {
          memberArray.add(element.data());
        }
      });
    });

    return memberArray;
  }

  Future loadAllEmployee() async {
    var listsArray = [];
    var selectedUser = [];
    await users.orderBy("id").get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((element) {
        listsArray.add({"id": element.data()['id']});
      });
    }).then((value) async {
      await allUser.orderBy("id").get().then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((element) async {
          var isExist = false;
          if (element.data()['id'] != employeeId) {
            //print("DATA : ${element.data()}");
            //print("ARRAY : $listsArray");
            for (int i = 0; i < listsArray.length; i++) {
              if (listsArray[i]["id"] == element.data()['id']) {
                return isExist = true;
              }
            }
          } else {
            isExist = true;
          }
          if (isExist != true) {
            selectedUser.add(element.data());
          }
        });
      });
    });

    for (int i = 0; i < selectedUser.length; i++) {
      if (selectedUser[i]['pic'] != null) {
        var loadImagePath = await imageUrl(selectedUser[i]['pic']);
        selectedUser[i]['path'] = loadImagePath;
      }
    }

    return selectedUser;
  }

  Future loadAllEmployeeBySearch(var keyword) async {
    print("Click");
    await allUser.get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((element) {
        print(element.data());
      });
    });

    var listsArray = [];
    var selectedUser = [];
    await users.orderBy("id").get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((element) {
        listsArray.add({"id": element.data()['id']});
      });
    }).then((value) async {
      await allUser
          .orderBy('name')
          .startAt([keyword])
          .endAt([keyword + '\uf8ff'])
          .get()
          .then((QuerySnapshot querySnapshot) {
            querySnapshot.docs.forEach((element) async {
              var isExist = false;
              if (element.data()['id'] != employeeId) {
                //print("DATA : ${element.data()}");
                //print("ARRAY : $listsArray");
                for (int i = 0; i < listsArray.length; i++) {
                  if (listsArray[i]["id"] == element.data()['id']) {
                    return isExist = true;
                  }
                }
              } else {
                isExist = true;
              }
              if (isExist != true) {
                selectedUser.add(element.data());
              }
            });
          });
    });

    for (int i = 0; i < selectedUser.length; i++) {
      if (selectedUser[i]['pic'] != null) {
        var loadImagePath = await imageUrl(selectedUser[i]['pic']);
        selectedUser[i]['path'] = loadImagePath;
      }
    }

    return selectedUser;
  }

  addMember(var data) async {
    await FirebaseFirestore.instance.collection('team_members').add({
      "id": data['id'],
      "data": data,
      "manager": employeeId,
      "name": data['name'],
      "docId": null
    }).then((value) async {
      print(value.id);
      await FirebaseFirestore.instance
          .collection('team_members')
          .doc(value.id)
          .update({"docId": value.id}).then((value) => print("User Updated"));
    });
  }

  removeMember(var data) async {
    await FirebaseFirestore.instance
        .collection('team_members')
        .doc(data['docId'])
        .delete();
  }

  imageUrl(var refUrl) {
    return FirebaseStorage.instance.ref(refUrl).getDownloadURL();
  }

  setDataState(var value) {
    print(value);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setInitialState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 36),
          height: double.infinity,
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      onChanged: (value) {
                        setState(() {
                          message = value;
                        });
                        print(message);
                      },
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Search",
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
                      maxLines: 1,
                    ),
                  ),
                ),
                StreamBuilder(
                  stream: users.snapshots(),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    //print(snapshot.connectionState);
                    //print(snapshot.data);

                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        return Container();
                      case ConnectionState.waiting:
                        return Container();
                      case ConnectionState.active:
                        return Column(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height * 0.4,
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                  border: Border.all(width: 0.25),
                                  borderRadius: BorderRadius.circular(10)),
                              child: FutureBuilder(
                                future: message != null
                                    ? loadAllEmployeeBySearch(message)
                                    : loadAllEmployee(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<dynamic> snapshot) {
                                  //print(snapshot.connectionState);

                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    setDataState(snapshot.data);
                                    return renderAllUser(snapshot.data);
                                  }
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  Text(
                                    "Your team member",
                                    style: TextStyle(
                                        color: Color.fromRGBO(61, 61, 61, 1),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              child: FutureBuilder(
                                future: loadMember(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<dynamic> snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    return renderMember(snapshot.data);
                                  }
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      case ConnectionState.done:
                        return Container();
                    }
                    return LinearProgressIndicator();
                  },
                ),
              ],
            ),
          ),
        ));
  }

  Widget renderMember(var snapShotData) {
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: snapShotData.length,
        itemBuilder: (BuildContext ctxt, int index) => Container(
            decoration:
                BoxDecoration(border: Border(bottom: BorderSide(width: 0.25))),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  child: CircleAvatar(
                    backgroundImage: snapShotData[index]['data']['path'] == null
                        ? null
                        : NetworkImage(snapShotData[index]['data']['path']),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(snapShotData[index]['data']['name']),
                    Text(snapShotData[index]['data']['id']),
                  ],
                ),
                Expanded(child: Container()),
                Container(
                  child: GestureDetector(
                    onTap: () {
                      removeMember(snapShotData[index]);
                    },
                    child: Text(
                      "Remove",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                )
              ],
            )));
  }

  Widget renderAllUser(var snapShotData) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: snapShotData.length,
        itemBuilder: (BuildContext ctxt, int index) => SingleChildScrollView(
            child: Container(
                decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(width: 0.25))),
                child: Row(children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 1,
                              color: Colors.grey,
                              spreadRadius: 0.01)
                        ],
                      ),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage: snapShotData[index]['path'] == null
                            ? null
                            : NetworkImage(snapShotData[index]['path']),
                        radius: 30.0,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(snapShotData[index]['name']),
                        Text(snapShotData[index]['id'])
                      ],
                    ),
                  ),
                  Container(
                    child: GestureDetector(
                      onTap: () {
                        addMember(snapShotData[index]);
                      },
                      child: Icon(Icons.add),
                    ),
                  )
                ]))));
  }
}
