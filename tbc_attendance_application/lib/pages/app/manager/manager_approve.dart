import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tbc_attendance_application/pages/app/manager/memberHistory.dart';

class ManagerApprove extends StatefulWidget {
  @override
  _ManagerApproveState createState() => _ManagerApproveState();
}

class _ManagerApproveState extends State<ManagerApprove> {
  CollectionReference users =
      FirebaseFirestore.instance.collection('team_members');
  CollectionReference allUser =
      FirebaseFirestore.instance.collection('identify_employee');
  CollectionReference approve =
      FirebaseFirestore.instance.collection('approve');

  var employeeId;
  var keyword = "";

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
    var newMemberArray = [];
    await users.get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((element) {
        print(element.data());
        if (element.data()['manager'] == employeeId) {
          print(element.data());
          memberArray.add(element.data());
        }
      });
    }).then((value) async {
      await approve.get().then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((element) {
          for (int i = 0; i < memberArray.length; i++) {
            if (element.data()["id"] == memberArray[i]['id']) {
              newMemberArray.add(memberArray[i]);
            }
          }
        });
      });
    });

    print(memberArray);
    print(newMemberArray);

    return newMemberArray;
  }

  Future loadMemberBySearch() async {
    print(keyword);
    var memberArray = [];
    var newMemberArray = [];
    await users
        .orderBy('name')
        .startAt([keyword])
        .endAt([keyword + '\uf8ff'])
        .get()
        .then((QuerySnapshot querySnapshot) {
          querySnapshot.docs.forEach((element) {
            print(element.data());
            if (element.data()['manager'] == employeeId) {
              print(element.data());
              memberArray.add(element.data());
            }
          });
        })
        .then((value) async {
          await approve.get().then((QuerySnapshot querySnapshot) {
            querySnapshot.docs.forEach((element) {
              for (int i = 0; i < memberArray.length; i++) {
                if (element.data()["id"] == memberArray[i]['id']) {
                  newMemberArray.add(memberArray[i]);
                }
              }
            });
          });
        });

    //print(memberArray);
    //print(newMemberArray);

    return newMemberArray;
  }

  imageUrl(var refUrl) {
    return FirebaseStorage.instance.ref(refUrl).getDownloadURL();
  }

  setApproveState(var value, var id) async {
    print("Update");
    await approve
        .where("id", isEqualTo: id)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((element) async {
        //print(element.data());
        await approve.doc(element.id).update({"approveState": value});
      });
    });
  }

  approveStateListener(var snapshot) async {
    var data;
    await approve
        .where("id", isEqualTo: snapshot)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((element) {
        print(element.data()["approveState"]);
        data = element.data()["approveState"];
      });
    });

    return data;
  }

  @override
  void initState() {
    super.initState();
    setInitialState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.people_sharp),
            onPressed: () {
              Navigator.of(context).pushNamed("/manager_management");
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              width: double.infinity,
              child: Form(
                  child: TextFormField(
                onChanged: (value) {
                  setState(() {
                    keyword = value;
                  });
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
              )),
            ),
            StreamBuilder(
                stream: users.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) return renderCard(snapshot);
                  }
                  return LinearProgressIndicator();
                })
          ],
        ),
      ),
    );
  }

  Widget renderCard(snapshot) {
    return FutureBuilder(
        future: keyword != "" ? loadMemberBySearch() : loadMember(),
        builder: ((BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          print(snapshot.connectionState);
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData)
              return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) =>
                      GestureDetector(
                        onLongPress: () {
                          Navigator.of(context).push(PageRouteBuilder(
                              opaque: false,
                              pageBuilder: (BuildContext context, _, __) =>
                                  MemberHistory(
                                      id: snapshot.data[index]['data']['id'])));
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                              border: Border.all(width: 0.25),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: Row(
                            children: [
                              Container(
                                  padding: EdgeInsets.all(10),
                                  child: CircleAvatar(
                                    backgroundImage: snapshot.data[index]
                                                ['data']['path'] ==
                                            null
                                        ? null
                                        : NetworkImage(snapshot.data[index]
                                            ['data']['path']),
                                  )),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(snapshot.data[index]['data']['name']),
                                  Text(snapshot.data[index]['data']['id'])
                                ],
                              ),
                              Expanded(flex: 1, child: Container()),
                              Container(child: renderToggle(snapshot, index))
                            ],
                          ),
                        ),
                      ));
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        }));
  }

  Widget renderToggle(snapshot, index) {
    return StreamBuilder(
        stream: approve.doc(snapshot.data[index]['data']['id']).snapshots(),
        builder: (context, snapshotToggle) {
          if (snapshotToggle.connectionState == ConnectionState.active) {
            if (snapshotToggle != null) {
              return Switch(
                  value: snapshotToggle.data['approveState'],
                  onChanged: (value) {
                    setApproveState(value, snapshot.data[index]['id']);
                  });
            }
          }

          return Container();
        });
  }
}
