import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  CalendarController _calendarController;
  CalendarController _initialCalendarControler1;
  CalendarController _initialCalendarControler2;
  CalendarController _initialCalendarControler3;
  CalendarController _initialCalendarControler4;
  CalendarController _initialCalendarControler5;
  CalendarController _initialCalendarControler6;
  CalendarController _initialCalendarControler7;
  CalendarController _initialCalendarControler8;
  CalendarController _initialCalendarControler9;
  CalendarController _initialCalendarControler10;
  CalendarController _initialCalendarControler11;
  CalendarController _initialCalendarControler12;

  var controllersList;

  List<String> yearLists;
  List<String> monthLists = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];
  String dropdownValue = DateTime.now().year.toString();
  String dropdownMonthValue = DateFormat.MMM().format(new DateTime.now());

  var id;
  var selectMonth = DateTime.now().month;
  var emoStatics = [0.0, 0.0, 0.0, 0.0, 0.0];
  var emoStaticsYear = [0.0, 0.0, 0.0, 0.0, 0.0];
  var lateTime = 0;
  var lateTimeYear = 0;
  var weekdayCountYear = 0;
  var absent = 0;
  var absentYear = 0;

  var firstPage = true;

  initialId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> yearArr = [];
    for (int i = 0; i <= 9; i++) {
      var year = DateTime.now().year;
      yearArr.add((year - i).toString());
    }

    var arrController = [
      _initialCalendarControler1,
      _initialCalendarControler2,
      _initialCalendarControler3,
      _initialCalendarControler4,
      _initialCalendarControler5,
      _initialCalendarControler6,
      _initialCalendarControler7,
      _initialCalendarControler8,
      _initialCalendarControler9,
      _initialCalendarControler10,
      _initialCalendarControler11,
      _initialCalendarControler12,
    ];

    if (mounted) {
      setState(() {
        id = prefs.get("id");
        yearLists = yearArr;
        controllersList = arrController;
      });
    }
  }

  Future emotionStatic() async {
    var month;
    for (int i = 0; i <= 11; i++) {
      if (dropdownMonthValue == monthLists[i]) {
        month = i + 1;
      }
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _absent = 0;
    return await FirebaseFirestore.instance
        .collection("check_out_log")
        .where("id", isEqualTo: prefs.get("id"))
        .where("year", isEqualTo: int.parse(dropdownValue))
        .where("month", isEqualTo: month)
        .get()
        .then((QuerySnapshot querySnapshot) {
      var arr = [0.0, 0.0, 0.0, 0.0, 0.0];
      var _lateTime = 0;
      querySnapshot.docs.forEach((element) {
        if (element.data()["emoticon"] == 1) arr[0] = arr[0] + 1;
        if (element.data()["emoticon"] == 2) arr[1] = arr[1] + 1;
        if (element.data()["emoticon"] == 3) arr[2] = arr[2] + 1;
        if (element.data()["emoticon"] == 4) arr[3] = arr[3] + 1;
        if (element.data()["emoticon"] == 5) arr[4] = arr[4] + 1;

        if (element.data()["late"] == true) _lateTime = _lateTime + 1;
        _absent = _absent + 1;
      });

      var dayCount;
      var weekdayCount = 0;
      if (month == DateTime.now().month &&
          int.parse(dropdownValue) == DateTime.now().year) {
        dayCount = DateTime(int.parse(dropdownValue), month, DateTime.now().day)
                .difference(DateTime(int.parse(dropdownValue), month, 1))
                .inDays +
            1;
      } else {
        dayCount = DateTime(int.parse(dropdownValue), month + 1, 1)
            .difference(DateTime(int.parse(dropdownValue), month, 1))
            .inDays;
      }
      for (int i = 1; i <= dayCount; i++) {
        var day = DateTime(int.parse(dropdownValue), month, i).weekday;
        if (day == 6 || day == 7) weekdayCount = weekdayCount + 1;
      }

      print("Day count : $dayCount");
      print("Week count : $weekdayCount");
      if (mounted) {
        setState(() {
          emoStatics = arr;
          lateTime = _lateTime;
          absent = dayCount - weekdayCount - _absent;
        });
      }
    });
  }

  Future emotionStaticYear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _absent = 0;
    return await FirebaseFirestore.instance
        .collection("check_out_log")
        .where("id", isEqualTo: prefs.get("id"))
        .where("year", isEqualTo: int.parse(dropdownValue))
        .get()
        .then((QuerySnapshot querySnapshot) {
      var arr = [0.0, 0.0, 0.0, 0.0, 0.0];
      var _lateTime = 0;
      querySnapshot.docs.forEach((element) {
        if (element.data()["emoticon"] == 1) arr[0] = arr[0] + 1;
        if (element.data()["emoticon"] == 2) arr[1] = arr[1] + 1;
        if (element.data()["emoticon"] == 3) arr[2] = arr[2] + 1;
        if (element.data()["emoticon"] == 4) arr[3] = arr[3] + 1;
        if (element.data()["emoticon"] == 5) arr[4] = arr[4] + 1;

        if (element.data()["late"] == true) _lateTime = _lateTime + 1;
        _absent = _absent + 1;
      });

      var dayCount;
      var weekdayCount = 0;

      if (int.parse(dropdownValue) == DateTime.now().year) {
        dayCount = DateTime(int.parse(dropdownValue), DateTime.now().month,
                DateTime.now().day)
            .difference(DateTime(int.parse(dropdownValue), 1, 1))
            .inDays;
      } else {
        dayCount = DateTime(int.parse(dropdownValue), 12, 31)
            .difference(DateTime(int.parse(dropdownValue), 1, 1))
            .inDays;
      }
      for (int i = 0; i <= dayCount; i++) {
        var day = DateTime(int.parse(dropdownValue), 1, i).weekday;

        if (day == 6 || day == 7) weekdayCount = weekdayCount + 1;
      }
      //print("dayCount : $weekdayCount");

      if (mounted) {
        setState(() {
          emoStaticsYear = arr;
          lateTimeYear = _lateTime;
          absentYear = dayCount - weekdayCount - _absent;
        });
      }
    });
  }

  Future fetchDataForYear() async {
    return await FirebaseFirestore.instance
        .collection('check_out_log')
        .where("id", isEqualTo: id)
        .get()
        .then((QuerySnapshot querySnapshot) {
      Map<DateTime, List<dynamic>> data = {};
      querySnapshot.docs.forEach((element) {
        var year = element.data()['year'];
        var month = element.data()['month'];
        var day = element.data()['day'];
        var emotion = element.data()['emoticon'];
        var late = element.data()['late'];
        data[DateTime(year, month, day)] = [emotion, late];
      });

      return data;
    });
  }

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    _initialCalendarControler1 = CalendarController();
    _initialCalendarControler2 = CalendarController();
    _initialCalendarControler3 = CalendarController();
    _initialCalendarControler4 = CalendarController();
    _initialCalendarControler5 = CalendarController();
    _initialCalendarControler6 = CalendarController();
    _initialCalendarControler7 = CalendarController();
    _initialCalendarControler8 = CalendarController();
    _initialCalendarControler9 = CalendarController();
    _initialCalendarControler10 = CalendarController();
    _initialCalendarControler11 = CalendarController();
    _initialCalendarControler12 = CalendarController();
    initialId();
    fetchDataForYear();
    emotionStatic();
    emotionStaticYear();
    print("initial");
  }

  @override
  void dispose() {
    _calendarController.dispose();
    _initialCalendarControler1.dispose();
    _initialCalendarControler2.dispose();
    _initialCalendarControler3.dispose();
    _initialCalendarControler4.dispose();
    _initialCalendarControler5.dispose();
    _initialCalendarControler6.dispose();
    _initialCalendarControler7.dispose();
    _initialCalendarControler8.dispose();
    _initialCalendarControler9.dispose();
    _initialCalendarControler10.dispose();
    _initialCalendarControler11.dispose();
    _initialCalendarControler12.dispose();
    initialId();
    fetchDataForYear();
    emotionStatic();
    emotionStaticYear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: SingleChildScrollView(
            child: Column(
          children: [
            sorting(),
            firstPage ? calendar() : calendarForYear(),
            summaryChart(),
            otherStatics(),
            firstPage ? checkInLogDaily() : Container()
          ],
        )));
  }

  Widget emotionRender(var selectData) {
    var emoticons = [
      "assets/emoticons/1.png",
      "assets/emoticons/2.png",
      "assets/emoticons/3.png",
      "assets/emoticons/4.png",
      "assets/emoticons/5.png",
    ];
    var bgColors = [
      Color.fromRGBO(255, 230, 226, 1),
      Color.fromRGBO(255, 249, 221, 1),
      Color.fromRGBO(224, 255, 221, 1),
      Color.fromRGBO(221, 246, 255, 1),
      Color.fromRGBO(245, 230, 254, 1),
    ];
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: bgColors[selectData[0] - 1],
          ),
          child: Container(
            padding: EdgeInsets.all(3.5),
            child: Image.asset(
              emoticons[selectData[0] - 1],
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
        selectData[1] == true
            ? Container(
                child: Image.asset("assets/late-sign.png"),
              )
            : Container()
      ],
    );
  }

  Widget calendar() {
    var month;
    for (int i = 0; i <= 11; i++) {
      if (dropdownMonthValue == monthLists[i]) {
        month = i + 1;
      }
    }
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('check_out_log')
          .where("id", isEqualTo: id)
          .get()
          .then((QuerySnapshot querySnapshot) {
        Map<DateTime, List<dynamic>> data = {};
        querySnapshot.docs.forEach((element) {
          var year = element.data()['year'];
          var month = element.data()['month'];
          var day = element.data()['day'];
          var emotion = element.data()['emoticon'];
          var late = element.data()['late'];
          data[DateTime(year, month, day)] = [emotion, late];
        });
        return data;
      }),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: LinearProgressIndicator(),
          );
        }
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 36),
          margin: EdgeInsets.only(bottom: 36, top: 10),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  10,
                )),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 20,
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10))),
                ),
                TableCalendar(
                  initialSelectedDay:
                      DateTime(int.parse(dropdownValue), month, 1),
                  calendarController: _calendarController,
                  initialCalendarFormat: CalendarFormat.month,
                  startingDayOfWeek: StartingDayOfWeek.sunday,
                  endDay: DateTime.now(),
                  availableCalendarFormats: {CalendarFormat.month: ''},
                  events: snapshot.data,
                  calendarStyle: CalendarStyle(
                    markersAlignment: Alignment.center,
                    outsideDaysVisible: false,
                    canEventMarkersOverflow: false,
                  ),
                  headerStyle: HeaderStyle(
                      formatButtonShowsNext: true,
                      centerHeaderTitle: true,
                      formatButtonVisible: true,
                      leftChevronVisible: false,
                      rightChevronVisible: false),
                  availableGestures: AvailableGestures.none,
                  builders: CalendarBuilders(
                    weekendDayBuilder: (context, date, events) {
                      return Container(
                        width: double.infinity,
                        height: double.infinity,
                        padding: EdgeInsets.all(5),
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Color.fromRGBO(237, 237, 237, 1)),
                        ),
                      );
                    },
                    outsideWeekendDayBuilder: (context, date, events) {
                      return Container();
                    },
                    outsideDayBuilder: (context, date, events) {
                      return Container();
                    },
                    dayBuilder: (context, date, events) {
                      selectMonth = date.month;
                      return Container(
                        width: double.infinity,
                        height: double.infinity,
                        padding: EdgeInsets.all(5),
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Color.fromRGBO(237, 237, 237, 1)),
                        ),
                      );
                    },
                    selectedDayBuilder: (context, date, events) {
                      return Container(
                        width: double.infinity,
                        height: double.infinity,
                        padding: EdgeInsets.all(4.5),
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  width: 0.5,
                                  color: Theme.of(context).primaryColor),
                              color: Color.fromRGBO(237, 237, 237, 1)),
                        ),
                      );
                    },
                    markersBuilder: (context, date, events, holidays) {
                      final children = <Widget>[];
                      children.add(Container(
                          width: double.infinity,
                          height: double.infinity,
                          padding: EdgeInsets.all(5),
                          child: emotionRender(events)));

                      return children;
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget summaryChart() {
    var emoticons = [
      "assets/emoticons/1.png",
      "assets/emoticons/2.png",
      "assets/emoticons/3.png",
      "assets/emoticons/4.png",
      "assets/emoticons/5.png",
    ];
    var bgColors = [
      Color.fromRGBO(252, 87, 59, 1),
      Color.fromRGBO(255, 210, 0, 1),
      Color.fromRGBO(42, 137, 109, 1),
      Color.fromRGBO(0, 169, 255, 1),
      Color.fromRGBO(190, 99, 249, 1),
    ];

    var avg = firstPage == false
        ? emoStaticsYear[0] +
            emoStaticsYear[1] +
            emoStaticsYear[2] +
            emoStaticsYear[3] +
            emoStaticsYear[4]
        : emoStatics[0] +
            emoStatics[1] +
            emoStatics[2] +
            emoStatics[3] +
            emoStatics[4];

    Widget graph(var icon, var colors, double value, var sum) {
      return Container(
        height: (MediaQuery.of(context).size.height * 0.3) / 5,
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Image.asset(emoticons[icon]),
            Expanded(
                child: Container(
              width: double.infinity,
              margin: EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value == 0.0 ? 0.0 : (value * 100) / sum / 100.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: bgColors[colors],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(''),
                ),
              ),
            )),
            Text(value == 0.0 ? "0.0%" : "${((value * 100) / sum).floor()}%")
          ],
        ),
      );
    }

    return Container(
        height: MediaQuery.of(context).size.height * 0.3,
        padding: EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          children: [
            graph(4, 4, firstPage == false ? emoStaticsYear[4] : emoStatics[4],
                avg),
            graph(3, 3, firstPage == false ? emoStaticsYear[3] : emoStatics[3],
                avg),
            graph(2, 2, firstPage == false ? emoStaticsYear[2] : emoStatics[2],
                avg),
            graph(1, 1, firstPage == false ? emoStaticsYear[1] : emoStatics[1],
                avg),
            graph(0, 0, firstPage == false ? emoStaticsYear[0] : emoStatics[0],
                avg)
          ],
        ));
  }

  Widget sorting() {
    var monthIndex = 0;
    return yearLists == null
        ? Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.05,
          )
        : Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.05,
            padding: EdgeInsets.symmetric(horizontal: 36),
            margin: EdgeInsets.only(top: 10),
            child: Row(
              children: [
                firstPage == false
                    ? Container()
                    : Container(
                        child: DropdownButton(
                          value: dropdownValue,
                          iconSize: 24,
                          elevation: 16,
                          items: yearLists
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String newValue) {
                            var year = int.parse(newValue);

                            print(year);
                            _calendarController
                                .setSelectedDay(DateTime(year, selectMonth, 1));

                            setState(() {
                              dropdownValue = newValue;
                            });
                            fetchDataForYear();
                            emotionStatic();
                            emotionStaticYear();
                          },
                        ),
                      ),
                firstPage == false
                    ? Container()
                    : Container(
                        child: DropdownButton(
                          value: dropdownMonthValue,
                          iconSize: 24,
                          elevation: 16,
                          items: monthLists
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String newValue) {
                            var year;
                            var month;
                            for (int i = 0; i <= 11; i++) {
                              if (newValue == monthLists[i]) {
                                month = i + 1;
                              }
                            }
                            for (int i = 0; i <= 9; i++) {
                              if (dropdownValue == yearLists[i]) {
                                year = int.parse(dropdownValue);
                              }
                            }
                            _calendarController
                                .setSelectedDay(DateTime(year, month, 1));

                            setState(() {
                              dropdownMonthValue = newValue;
                              selectMonth = month;
                            });

                            emotionStatic();
                          },
                        ),
                      ),
                Expanded(
                  child: Container(),
                ),
                Container(
                  height: double.infinity,
                  width: MediaQuery.of(context).size.height * 0.05,
                  padding: EdgeInsets.all(5),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        firstPage = true;
                      });
                      var month;
                      for (int i = 0; i <= 11; i++) {
                        if (dropdownMonthValue == monthLists[i]) {
                          month = i + 1;
                        }
                      }
                      _calendarController
                          .setSelectedDay(DateTime(2020, month, 1));

                      fetchDataForYear();
                      emotionStatic();
                      emotionStaticYear();

                      print("Month : $month");
                    },
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                          color: firstPage
                              ? Theme.of(context).primaryColor
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(
                          child: Text(
                        "M",
                        style: TextStyle(
                            color: firstPage
                                ? Colors.white
                                : Theme.of(context).primaryColor),
                      )),
                    ),
                  ),
                ),
                Container(
                  height: double.infinity,
                  width: MediaQuery.of(context).size.height * 0.05,
                  padding: EdgeInsets.all(5),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        firstPage = false;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                          color: firstPage == false
                              ? Theme.of(context).primaryColor
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(
                          child: Text(
                        "Y",
                        style: TextStyle(
                          color: firstPage == false
                              ? Colors.white
                              : Theme.of(context).primaryColor,
                        ),
                      )),
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  Widget otherStatics() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.15,
      padding: EdgeInsets.symmetric(horizontal: 36),
      margin: EdgeInsets.only(top: 30, bottom: 40),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                  child: Container(
                      margin: EdgeInsets.only(right: 5),
                      decoration: BoxDecoration(
                        color: Theme.of(context).backgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Late"),
                          Text(firstPage == false
                              ? lateTimeYear.toString()
                              : lateTime.toString()),
                        ],
                      )))),
              Expanded(
                  child: Container(
                      margin: EdgeInsets.only(left: 5),
                      decoration: BoxDecoration(
                        color: Theme.of(context).backgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Absent"),
                          Text(firstPage == false
                              ? absentYear.toString()
                              : absent.toString()),
                        ],
                      )))),
            ],
          ),
        ),
      ),
    );
  }

  Widget checkInLogDaily() {
    var checkInFetchData = FirebaseFirestore.instance
        .collection('check_in_log')
        .where('id', isEqualTo: id)
        .where('year', isEqualTo: DateTime.now().year)
        .where('month', isEqualTo: DateTime.now().month)
        .where('day', isEqualTo: DateTime.now().day)
        .get()
        .then((QuerySnapshot querySnapshot) {
      var _element;
      querySnapshot.docs.forEach((element) {
        _element = element.data();
      });
      return _element;
    });

    var checkOutFetchData = FirebaseFirestore.instance
        .collection('check_out_log')
        .where('id', isEqualTo: id)
        .where('year', isEqualTo: DateTime.now().year)
        .where('month', isEqualTo: DateTime.now().month)
        .where('day', isEqualTo: DateTime.now().day)
        .get()
        .then((QuerySnapshot querySnapshot) {
      var _element;
      querySnapshot.docs.forEach((element) {
        _element = element.data();
      });
      return _element;
    });

    Widget logCard(data, label) {
      var date = label == "Out" ? data['checkOutTimeStamp'] : data['timeStamp'];
      var convertDate =
          DateTime.fromMillisecondsSinceEpoch(date.seconds * 1000);
      var convertTime = DateFormat('HH:mm a').format(convertDate);
      print(convertTime);

      return Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.2,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: label == "In"
              ? BorderRadius.only(topLeft: Radius.circular(10))
              : BorderRadius.only(bottomLeft: Radius.circular(10)),
        ),
        child: Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.15,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: label == "In"
                    ? BorderRadius.only(topLeft: Radius.circular(10))
                    : BorderRadius.only(bottomLeft: Radius.circular(10)),
              ),
              height: double.infinity,
              child: Center(
                  child: Text(
                label,
                style: TextStyle(color: Colors.white),
              )),
            ),
            Container(
                child: FutureBuilder(
              future: FirebaseStorage.instance
                  .ref(label == "Out" ? data['checkOutRef'] : data['ref'])
                  .getDownloadURL(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                print(snapshot.data);
                if (snapshot.hasData) {
                  return Image.network(
                    snapshot.data,
                    height: double.infinity,
                  );
                }
                return CircularProgressIndicator();
              },
            )),
            Expanded(
              child: Container(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Text("$convertTime"), Icon(Icons.timer)],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            label == "Out"
                                ? Container()
                                : Text(data['late'] ? "Late" : "On-time")
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 36),
      child: FutureBuilder(
        future: Future.wait([checkInFetchData, checkOutFetchData]),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          print("SnapShot : ${snapshot.data}");
          if (snapshot.hasData) {
            if (snapshot.data[0] == null && snapshot.data[1] == null) {
              return Center(
                child: Text('Please check in'),
              );
            } else {
              return Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Center(
                      child: Text("Today"),
                    ),
                  ),
                  logCard(snapshot.data[0], "In"),
                  snapshot.data[1] == null
                      ? Container()
                      : logCard(snapshot.data[1], "Out"),
                ],
              );
            }
          }
          return Container();
        },
      ),
    );
  }

  Widget calendarForYear() {
    var _itemCount;
    if (int.parse(dropdownValue) == DateTime.now().year) {
      _itemCount = DateTime.now().month;
    } else {
      _itemCount = 12;
    }
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: FutureBuilder(
            future: fetchDataForYear(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              print(snapshot.data);
              if (!snapshot.hasData) {
                return Center(
                  child: LinearProgressIndicator(),
                );
              }
              return snapshot.data == null
                  ? Center(child: LinearProgressIndicator())
                  : GridView.builder(
                      shrinkWrap: true,
                      itemCount: _itemCount,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate:
                          new SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                      ),
                      itemBuilder: (context, index) {
                        print("index : $index");

                        return Container(
                          padding: EdgeInsets.all(10),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  10,
                                )),
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10))),
                                ),
                                TableCalendar(
                                  initialSelectedDay: DateTime(
                                      int.parse(dropdownValue), index + 1, 1),
                                  calendarController: controllersList[index],
                                  initialCalendarFormat: CalendarFormat.month,
                                  startingDayOfWeek: StartingDayOfWeek.sunday,
                                  endDay: DateTime.now(),
                                  availableCalendarFormats: {
                                    CalendarFormat.month: ''
                                  },
                                  events: snapshot.data,
                                  calendarStyle: CalendarStyle(
                                    markersAlignment: Alignment.center,
                                    outsideDaysVisible: false,
                                    canEventMarkersOverflow: false,
                                  ),
                                  headerStyle: HeaderStyle(
                                      formatButtonShowsNext: true,
                                      centerHeaderTitle: true,
                                      formatButtonVisible: true,
                                      leftChevronVisible: false,
                                      rightChevronVisible: false),
                                  availableGestures: AvailableGestures.none,
                                  builders: CalendarBuilders(
                                    weekendDayBuilder: (context, date, events) {
                                      return Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        padding: EdgeInsets.all(1),
                                        child: Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(1),
                                              color: Color.fromRGBO(
                                                  237, 237, 237, 1)),
                                        ),
                                      );
                                    },
                                    outsideWeekendDayBuilder:
                                        (context, date, events) {
                                      return Container();
                                    },
                                    outsideDayBuilder: (context, date, events) {
                                      return Container();
                                    },
                                    dayBuilder: (context, date, events) {
                                      selectMonth = date.month;
                                      return Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        padding: EdgeInsets.all(1),
                                        child: Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(1),
                                              color: Color.fromRGBO(
                                                  237, 237, 237, 1)),
                                        ),
                                      );
                                    },
                                    markersBuilder:
                                        (context, date, events, holidays) {
                                      final children = <Widget>[];
                                      children.add(Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          padding: EdgeInsets.all(1),
                                          child: emotionRender(events)));

                                      return children;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      });
            },
          ),
        ),
      ],
    );
  }
}

// Widget calendarForYear() {
//     var _itemCount;
//     if (int.parse(dropdownValue) == DateTime.now().year) {
//       _itemCount = DateTime.now().month;
//     } else {
//       _itemCount = 12;
//     }
//     return Column(
//       children: [
//         Container(
//           width: double.infinity,
//           padding: EdgeInsets.symmetric(horizontal: 10),
//           child: FutureBuilder(
//             future: fetchDataForYear(),
//             builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
//               print(snapshot.data);
//               if (!snapshot.hasData) {
//                 return Center(
//                   child: LinearProgressIndicator(),
//                 );
//               }
//               return snapshot.data == null
//                   ? Center(child: LinearProgressIndicator())
//                   : ListView.builder(
//                       scrollDirection: Axis.vertical,
//                       physics: NeverScrollableScrollPhysics(),
//                       shrinkWrap: true,
//                       itemCount: _itemCount,
//                       itemBuilder: (context, index) {
//                         print("index : $index");

//                         return Container(
//                           margin: EdgeInsets.only(bottom: 5, top: 5),
//                           child: Container(
//                             decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(
//                                   10,
//                                 )),
//                             child: Column(
//                               children: [
//                                 Container(
//                                   decoration: BoxDecoration(
//                                       color: Theme.of(context).primaryColor,
//                                       borderRadius: BorderRadius.only(
//                                           topLeft: Radius.circular(10),
//                                           topRight: Radius.circular(10))),
//                                 ),
//                                 TableCalendar(
//                                   initialSelectedDay: DateTime(
//                                       int.parse(dropdownValue), index + 1, 1),
//                                   calendarController: controllersList[index],
//                                   initialCalendarFormat: CalendarFormat.month,
//                                   startingDayOfWeek: StartingDayOfWeek.sunday,
//                                   endDay: DateTime.now(),
//                                   availableCalendarFormats: {
//                                     CalendarFormat.month: ''
//                                   },
//                                   events: snapshot.data,
//                                   calendarStyle: CalendarStyle(
//                                     markersAlignment: Alignment.center,
//                                     outsideDaysVisible: false,
//                                     canEventMarkersOverflow: false,
//                                   ),
//                                   headerStyle: HeaderStyle(
//                                       formatButtonShowsNext: true,
//                                       centerHeaderTitle: true,
//                                       formatButtonVisible: true,
//                                       leftChevronVisible: false,
//                                       rightChevronVisible: false),
//                                   availableGestures: AvailableGestures.none,
//                                   builders: CalendarBuilders(
//                                     weekendDayBuilder: (context, date, events) {
//                                       return Container(
//                                         width: double.infinity,
//                                         height: double.infinity,
//                                         padding: EdgeInsets.all(5),
//                                         child: Container(
//                                           width: double.infinity,
//                                           height: double.infinity,
//                                           decoration: BoxDecoration(
//                                               borderRadius:
//                                                   BorderRadius.circular(10),
//                                               color: Color.fromRGBO(
//                                                   237, 237, 237, 1)),
//                                         ),
//                                       );
//                                     },
//                                     outsideWeekendDayBuilder:
//                                         (context, date, events) {
//                                       return Container();
//                                     },
//                                     outsideDayBuilder: (context, date, events) {
//                                       return Container();
//                                     },
//                                     dayBuilder: (context, date, events) {
//                                       selectMonth = date.month;
//                                       return Container(
//                                         width: double.infinity,
//                                         height: double.infinity,
//                                         padding: EdgeInsets.all(5),
//                                         child: Container(
//                                           width: double.infinity,
//                                           height: double.infinity,
//                                           decoration: BoxDecoration(
//                                               borderRadius:
//                                                   BorderRadius.circular(10),
//                                               color: Color.fromRGBO(
//                                                   237, 237, 237, 1)),
//                                         ),
//                                       );
//                                     },
//                                     markersBuilder:
//                                         (context, date, events, holidays) {
//                                       final children = <Widget>[];
//                                       children.add(Container(
//                                           width: double.infinity,
//                                           height: double.infinity,
//                                           padding: EdgeInsets.all(5),
//                                           child: emotionRender(events)));

//                                       return children;
//                                     },
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       });
//             },
//           ),
//         ),
//       ],
//     );
//   }
