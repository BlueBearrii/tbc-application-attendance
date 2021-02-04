import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_util/date_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  var checkOutLogs;
  var checkOutLogsYear;
  var _selectYear;
  var _selectMonth;
  var employeeId;

  var _sortingButtonSelected = 1;
  var keep = [];
  var keepYear = [
    [],
    [],
    [],
    [],
    [],
    [],
    [],
    [],
    [],
    [],
    [],
    [],
  ];
  var emotionStatic = {
    "1": 0,
    "2": 0,
    "3": 0,
    "4": 0,
    "5": 0,
    "count": 0,
    "late": 0,
    "absent": 0,
  };

  var yearLists;
  var monthLists = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  Future fetchDataFromDatabase() async {
    print("Initial state");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    employeeId = prefs.getString("employeeId");

    var yearLoad = List<String>(5);
    var data = [
      [List(2), List(2), List(2), List(2), List(2)],
      [List(2), List(2), List(2), List(2), List(2)],
      [List(2), List(2), List(2), List(2), List(2)],
      [List(2), List(2), List(2), List(2), List(2)],
      [List(2), List(2), List(2), List(2), List(2)],
    ];

    var emotionStaticCount = {
      "1": 0,
      "2": 0,
      "3": 0,
      "4": 0,
      "5": 0,
      "count": 0,
      "late": 0,
      "absent": 0,
    };
    if (mounted) {
      setState(() {
        keep = [];
        checkOutLogs = data;
        emotionStatic = emotionStaticCount;
      });
    }

    for (int i = 0; i <= 4; i++) {
      var thisYear = int.parse(DateFormat.y().format(new DateTime.now()));
      var _yearLoad = thisYear - i;
      yearLoad[i] = "$_yearLoad";
    }
    if (mounted) {
      setState(() {
        yearLists = yearLoad;
      });
    }
    //print(DateFormat.M().format(new DateTime.now()));
    //print(_selectYear);

    await FirebaseFirestore.instance
        .collection('check_out_log')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        var _employeeId = doc.data()["employeeId"];
        var year = doc.data()["year"];
        var month = doc.data()["month"];
        var week = doc.data()["week"];
        var day = doc.data()["day"];
        var emotion = doc.data()["emotion"];
        print(doc.data());
        if (_employeeId == employeeId &&
            year == _selectYear &&
            month == _selectMonth) {
          keep.add({
            "year": year,
            "month": month,
            "week": week,
            "day": day,
            "emotion": emotion,
          });
          print("KEEP : $keep");
          emotionStaticCount['$emotion'] = emotionStaticCount['$emotion'] + 1;
          emotionStaticCount['count'] = emotionStaticCount['count'] + 1;
        }
      });
    }).then((value) async {
      await FirebaseFirestore.instance
          .collection('check_in_log')
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          var _employeeId = doc.data()["employeeId"];
          var year = doc.data()["year"];
          var month = doc.data()["month"];
          var week = doc.data()["week"];
          var day = doc.data()["day"];
          var lateTime = doc.data()["late"];
          for (int i = 0; i < keep.length; i++) {
            if (_employeeId == employeeId &&
                keep[i]['year'] == year &&
                keep[i]['month'] == month &&
                keep[i]['week'] == week &&
                keep[i]['day'] == day) {
              print(doc.data());
              print(keep[i]);
              keep[i]["late"] = lateTime;
              if (lateTime) {
                emotionStaticCount['late'] = emotionStaticCount['late'] + 1;
              }
            }
          }
        });
      });
    });

    findMonthInt(var monthName) {
      for (int i = 0; i <= 11; i++) {
        if (monthName == monthLists[i]) return i + 1;
      }
    }

    for (int weekCount = 0; weekCount <= 4; weekCount++) {
      for (int dayCount = 0; dayCount <= 4; dayCount++) {
        for (int loop = 0; loop < keep.length; loop++) {
          if (weekCount + 1 == keep[loop]['week']) {
            if (dayCount + 1 == keep[loop]['day']) {
              if (_selectYear == keep[loop]['year']) {
                if (_selectMonth == keep[loop]['month']) {
                  data[weekCount][dayCount][0] = keep[loop]['emotion'];
                  data[weekCount][dayCount][1] = keep[loop]['late'];
                }
              }
            }
          } else {
            if (findAbsent(int.parse(_selectYear), findMonthInt(_selectMonth),
                weekCount, dayCount)) {
              emotionStaticCount['absent'] = emotionStaticCount['absent'] + 1;
            }
            data[weekCount][dayCount][0] = null;
            data[weekCount][dayCount][1] = false;
          }
        }
      }
    }
    if (mounted) {
      setState(() {
        checkOutLogs = data;
        emotionStatic = emotionStaticCount;
      });
    }

    print(keep);
    print(data);
    //print(emotionStaticCount);
  }

  Future fetchDataFromDatabaseForYear() async {
    var data = [
      [
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
      ],
      [
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
      ],
      [
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
      ],
      [
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
      ],
      [
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
      ],
      [
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
      ],
      [
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
      ],
      [
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
      ],
      [
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
      ],
      [
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
      ],
      [
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
      ],
      [
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
        [List(2), List(2), List(2), List(2), List(2)],
      ],
    ];

    var emotionStaticCount = {
      "1": 0,
      "2": 0,
      "3": 0,
      "4": 0,
      "5": 0,
      "count": 0,
      "late": 0,
      "absent": 0,
    };
    if (mounted) {
      setState(() {
        keepYear = [
          [],
          [],
          [],
          [],
          [],
          [],
          [],
          [],
          [],
          [],
          [],
          [],
        ];
        checkOutLogs = data;
        emotionStatic = emotionStaticCount;
      });
    }

    await FirebaseFirestore.instance
        .collection('check_out_log')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        var _employeeId = doc.data()["employeeId"];
        var year = doc.data()["year"];
        var month = doc.data()["month"];
        var week = doc.data()["week"];
        var day = doc.data()["day"];
        var emotion = doc.data()["emotion"];

        if (_employeeId == employeeId && year == _selectYear) {
          for (int monthLoop = 0; monthLoop <= 11; monthLoop++) {
            if (month == monthLists[monthLoop]) {
              keepYear[monthLoop].add({
                "year": year,
                "month": month,
                "week": week,
                "day": day,
                "emotion": emotion,
              });

              //print("YEAR : $year, SELECT YEAR : $_selectYear");

              emotionStaticCount['$emotion'] =
                  emotionStaticCount['$emotion'] + 1;
              emotionStaticCount['count'] = emotionStaticCount['count'] + 1;
            }
          }
        }
      });
    }).then((value) async {
      await FirebaseFirestore.instance
          .collection('check_in_log')
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          var _employeeId = doc.data()["employeeId"];
          var year = doc.data()["year"];
          var month = doc.data()["month"];
          var week = doc.data()["week"];
          var day = doc.data()["day"];
          var lateTime = doc.data()["late"];

          //print(lateTime);
          if (lateTime) {
            emotionStaticCount['late'] = emotionStaticCount['late'] + 1;
          }

          for (int monthLoop = 0; monthLoop <= 11; monthLoop++) {
            for (int i = 0; i < keepYear[monthLoop].length; i++) {
              if (_employeeId == employeeId &&
                  keepYear[monthLoop][i]['year'] == year &&
                  keepYear[monthLoop][i]['month'] == month &&
                  keepYear[monthLoop][i]['week'] == week &&
                  keepYear[monthLoop][i]['day'] == day) {
                //print(doc.data());
                //print(keepYear[][i]);
                keepYear[monthLoop][i]["late"] = lateTime;
              }
            }
          }
        });
      });
    });

    for (int monthLoop = 0; monthLoop <= 11; monthLoop++) {
      for (int weekCount = 0; weekCount <= 4; weekCount++) {
        for (int dayCount = 0; dayCount <= 4; dayCount++) {
          for (int loop = 0; loop < keepYear[monthLoop].length; loop++) {
            if (weekCount + 1 == keepYear[monthLoop][loop]['week']) {
              if (dayCount + 1 == keepYear[monthLoop][loop]['day']) {
                if (_selectYear == keepYear[monthLoop][loop]['year']) {
                  data[monthLoop][weekCount][dayCount][0] =
                      keepYear[monthLoop][loop]['emotion'];
                  data[monthLoop][weekCount][dayCount][1] =
                      keepYear[monthLoop][loop]['late'];
                }
              }
            } else {
              if (findAbsent(
                  int.parse(_selectYear), monthLoop + 1, weekCount, dayCount)) {
                emotionStaticCount['absent'] = emotionStaticCount['absent'] + 1;
              }
              data[monthLoop][weekCount][dayCount][0] = null;
              data[monthLoop][weekCount][dayCount][1] = false;
            }
          }
        }
      }
    }

    //print(keepYear);
    //print(data);

    if (mounted) {
      setState(() {
        checkOutLogsYear = data;
        emotionStatic = emotionStaticCount;
      });
    }
  }

  resetCalendar() {
    print("Function is work $_selectYear");
    if (_sortingButtonSelected == 1) {
      fetchDataFromDatabase();
    }
    if (_sortingButtonSelected == 2) {
      fetchDataFromDatabaseForYear();
    }
  }

  findMonth(var i, var data) {
    //print(keepYear[i]);
    if (keepYear[i].isNotEmpty && keepYear[i][0]['year'] == _selectYear)
      return true;
    else
      return false;
  }

  findAbsent(var olderYear, var olderMonth, var olderWeek, var olderDay) {
    var now = new DateTime.now();
    var year = now.year;
    var month = now.month;
    var week = calculateWeekOfMonth() - 1;
    var dayOfWeek = now.weekday - 1;
    var day = now.day;

    //print("$year : $month : $week : $dayOfWeek ");
    //print("$olderYear : $olderMonth : $olderWeek : $olderDay");

    if (olderYear < year) {
      return true;
    } else {
      if (olderMonth < month) {
        return true;
      } else {
        if (olderWeek < week) {
          return true;
        } else {
          if (olderDay < dayOfWeek)
            return true;
          else
            return false;
        }
      }
    }
  }

  calculateWeekOfMonth() {
    var now = new DateTime.now();
    var day = DateFormat.d().format(now);
    var dayOfWeek = now.weekday;
    var countDayOfWeek = dayOfWeek + 1;

    for (int i = int.parse(day); i >= 1; i--) {
      countDayOfWeek = countDayOfWeek - 1;
      if (countDayOfWeek == 0) countDayOfWeek = 7;
    }
    var findWeekCount = 1;
    for (int i = 1; i <= int.parse(day); i++) {
      countDayOfWeek = countDayOfWeek + 1;
      if (countDayOfWeek == 8) {
        findWeekCount++;
        countDayOfWeek = 1;
      }
    }

    //print(findWeekCount);

    return findWeekCount.toInt();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchDataFromDatabase();

    setState(() {
      _selectYear = DateFormat.y().format(new DateTime.now()).toString();
      _selectMonth = DateFormat.LLLL().format(new DateTime.now()).toString();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    fetchDataFromDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            children: [
              Container(
                height: 60,
                child: Row(
                  children: [
                    yearLists != null ? dropdownToSelectYears() : Container(),
                    Expanded(child: Container()),
                    sortingButton()
                  ],
                ),
              ),
              _sortingButtonSelected == 1
                  ? calendar(context, 300)
                  : yearCalendar(checkOutLogsYear),
              summaryGraph(),
              lateAndAbsent()
            ],
          ),
        ),
      ),
    );
  }

  Widget dropdownToSelectYears() {
    return DropdownButton<String>(
      value: _selectYear,
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Theme.of(context).primaryColor),
      onChanged: (String newValue) {
        print("RESET CALENDAR PRESSED");
        setState(() {
          _selectYear = newValue;
        });
        resetCalendar();
      },
      items: yearLists.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget sortingButton() {
    return Row(
      children: [
        Container(
          margin: EdgeInsets.only(left: 5),
          width: 60,
          child: RaisedButton(
            color: _sortingButtonSelected == 1
                ? Theme.of(context).primaryColor
                : Colors.white,
            onPressed: () {
              fetchDataFromDatabase();
              setState(() {
                _sortingButtonSelected = 1;
              });
            },
            child: Text(
              "1M",
              style: TextStyle(
                  color: _sortingButtonSelected == 1
                      ? Colors.white
                      : Theme.of(context).primaryColor),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 5),
          width: 60,
          child: RaisedButton(
            color: _sortingButtonSelected == 2
                ? Theme.of(context).primaryColor
                : Colors.white,
            onPressed: () {
              fetchDataFromDatabaseForYear();
              setState(() {
                _sortingButtonSelected = 2;
              });
            },
            child: Text(
              "1Y",
              style: TextStyle(
                  color: _sortingButtonSelected == 2
                      ? Colors.white
                      : Theme.of(context).primaryColor),
            ),
          ),
        )
      ],
    );
  }

  Widget dropdownToSelectMonth() {
    return DropdownButton<String>(
      value: _selectMonth,
      style: TextStyle(color: Colors.white, fontSize: 16),
      dropdownColor: Theme.of(context).primaryColor,
      isExpanded: false,
      underline: Container(color: Colors.transparent),
      onChanged: (String newValue) {
        print("RESET CALENDAR PRESSED : $newValue");
        setState(() {
          _selectMonth = newValue;
        });
        resetCalendar();
      },
      items: monthLists.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: TextStyle(color: Colors.white),
          ),
        );
      }).toList(),
    );
  }

  Widget calendar(context, double customHeight) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 10),
          height: 50,
          width: double.infinity,
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10))),
          child: Center(child: dropdownToSelectMonth()),
        ),
        Container(
          color: Colors.white,
          height: customHeight,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          width: double.infinity,
          child: checkOutLogs != null
              ? Column(
                  children: [
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(child: Center(child: Text("Mon"))),
                          Expanded(child: Center(child: Text("Tue"))),
                          Expanded(child: Center(child: Text("Wed"))),
                          Expanded(child: Center(child: Text("Thu"))),
                          Expanded(child: Center(child: Text("Fri")))
                        ],
                      ),
                    ),
                    emotionPerWeek(checkOutLogs[0], 50),
                    emotionPerWeek(checkOutLogs[1], 50),
                    emotionPerWeek(checkOutLogs[2], 50),
                    emotionPerWeek(checkOutLogs[3], 50),
                    emotionPerWeek(checkOutLogs[4], 50)
                  ],
                )
              : Center(
                  child: CircularProgressIndicator(),
                ),
        )
      ],
    );
  }

  Widget emotionPerWeek(var dataOfTheWeek, double customHeight) {
    var emotionMapping = [
      "assets/angry.png",
      "assets/frown.png",
      "assets/confusing.png",
      "assets/grinning.png",
      "assets/blow-kiss.png",
      "assets/absent.png",
    ];

    //print("LOGS : $dataOfTheWeek");

    var lateSign = "assets/late-sign.png";

    Widget emotionLayout(data) {
      return Center(
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 3),
            child: Stack(children: [
              Center(
                child: Image.asset(data[0] != null
                    ? emotionMapping[data[0] - 1]
                    : emotionMapping[5]),
              ),
              data[1] == true ? Image.asset(lateSign) : Container()
            ])),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 1),
      height: customHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: emotionLayout(dataOfTheWeek[0])),
          Expanded(child: emotionLayout(dataOfTheWeek[1])),
          Expanded(child: emotionLayout(dataOfTheWeek[2])),
          Expanded(child: emotionLayout(dataOfTheWeek[3])),
          Expanded(child: emotionLayout(dataOfTheWeek[4])),
        ],
      ),
    );
  }

  Widget summaryGraph() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 2.5),
            width: double.infinity,
            child: Text(
              "Summary",
              style: TextStyle(
                  color: Color.fromRGBO(61, 61, 61, 1),
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
          summaryChartOnly("assets/blow-kiss.png",
              emotionStatic["5"].toDouble(), Colors.purple),
          summaryChartOnly("assets/grinning.png", emotionStatic["4"].toDouble(),
              Colors.blue),
          summaryChartOnly("assets/confusing.png",
              emotionStatic["3"].toDouble(), Colors.green),
          summaryChartOnly(
              "assets/frown.png", emotionStatic["2"].toDouble(), Colors.yellow),
          summaryChartOnly("assets/angry.png", emotionStatic["1"].toDouble(),
              Colors.redAccent)
        ],
      ),
    );
  }

  Widget summaryChartOnly(String assetName, double percent, Color colorCode) {
    var avg = (percent * 100 / emotionStatic["count"]).floorToDouble();
    var diffPercent = ((percent * 100 / emotionStatic["count"]) / 100);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 2.5),
      width: double.infinity,
      child: Row(
        children: [
          Image.asset(assetName),
          Expanded(
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10)),
                  ),
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: [
                      Flexible(
                        child: FractionallySizedBox(
                          widthFactor: diffPercent.isNaN ? null : diffPercent,
                          child: Container(
                            decoration: BoxDecoration(
                                color: colorCode,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10),
                                    bottomRight: Radius.circular(10))),
                            child: Text(''),
                          ),
                        ),
                      ),
                    ],
                  ))),
          Text(avg.isNaN ? "0.0 %" : "$avg %")
        ],
      ),
    );
  }

  Widget yearCalendar(checkOutLogsYear) {
    List<Widget> mapping() {
      List<Widget> getWidget = [];
      for (int number = 0; number <= 11; number++) {
        //print("Number : $number");
        if (findMonth(number, checkOutLogsYear[number])) {
          getWidget.add(calendarForYearNewVersion(
              checkOutLogsYear[number], monthLists[number]));
        }
      }
      return getWidget;
    }

    return Container(
      width: double.infinity,
      child: checkOutLogsYear != null
          ? Wrap(direction: Axis.horizontal, children: mapping())
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget calendarForYear(value, month) {
    //print("VALUE : $value");
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 10),
          height: 30,
          width: double.infinity,
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10))),
          child: Center(
              child: Text(
            month,
            style: TextStyle(color: Colors.white),
          )),
        ),
        Container(
          color: Colors.white,
          height: 180,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          width: double.infinity,
          child: Column(
            children: [
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: Center(child: Text("Mon"))),
                    Expanded(child: Center(child: Text("Tue"))),
                    Expanded(child: Center(child: Text("Wed"))),
                    Expanded(child: Center(child: Text("Thu"))),
                    Expanded(child: Center(child: Text("Fri")))
                  ],
                ),
              ),
              emotionPerWeek(value[0], 25),
              emotionPerWeek(value[1], 25),
              emotionPerWeek(value[2], 25),
              emotionPerWeek(value[3], 25),
              emotionPerWeek(value[4], 25),
            ],
          ),
        )
      ],
    );
  }

  Widget calendarForYearNewVersion(value, month) {
    //print("VALUE : $value");
    return Container(
      margin: EdgeInsets.symmetric(vertical: 3),
      //height: (MediaQuery.of(context).size.width / 2) - 36,
      width: (MediaQuery.of(context).size.width / 2) - 36,
      padding: EdgeInsets.all(3),
      child: Column(
        children: [
          Container(
            width: (MediaQuery.of(context).size.width / 2) - 36,
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10))),
            child: Center(
                child: Text(
              month,
              style: TextStyle(color: Colors.white),
            )),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              children: [
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          child: Center(
                              child: Text(
                        "Mon",
                        style: TextStyle(fontSize: 10),
                      ))),
                      Expanded(
                          child: Center(
                              child: Text(
                        "Tue",
                        style: TextStyle(fontSize: 10),
                      ))),
                      Expanded(
                          child: Center(
                              child: Text(
                        "Wed",
                        style: TextStyle(fontSize: 10),
                      ))),
                      Expanded(
                          child: Center(
                              child: Text(
                        "Thu",
                        style: TextStyle(fontSize: 10),
                      ))),
                      Expanded(
                          child: Center(
                              child: Text(
                        "Fri",
                        style: TextStyle(fontSize: 10),
                      )))
                    ],
                  ),
                ),
                emotionPerWeek(value[0], 25),
                emotionPerWeek(value[1], 25),
                emotionPerWeek(value[2], 25),
                emotionPerWeek(value[3], 25),
                emotionPerWeek(value[4], 25),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget lateAndAbsent() {
    return Container(
        child: Text(
            "Late ${emotionStatic['late']} : Absent ${emotionStatic['absent']}"));
  }
}
