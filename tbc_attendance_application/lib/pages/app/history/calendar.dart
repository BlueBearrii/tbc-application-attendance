// Container(
//                 child: TableCalendar(
//                   initialSelectedDay: DateTime(2021, 1, 1),
//                   calendarController: _calendarController,
//                   initialCalendarFormat: CalendarFormat.month,
//                   availableCalendarFormats: {CalendarFormat.month: ''},
//                   events: {
//                     DateTime(2021, 1, 1): ['New Year\'s Day'],
//                     DateTime(2021, 1, 4): ['New Year\'s Day'],
//                     DateTime(2021, 1, 5): ['New Year\'s Day'],
//                     DateTime(2021, 1, 6): ['New Year\'s Day'],
//                     DateTime(2021, 1, 7): ['New Year\'s Day'],
//                     DateTime(2021, 1, 8): ['New Year\'s Day'],
//                   },
//                   calendarStyle: CalendarStyle(
//                     markersAlignment: Alignment.center,
//                     canEventMarkersOverflow: false,
//                   ),
//                   headerStyle: HeaderStyle(
//                       formatButtonShowsNext: true,
//                       centerHeaderTitle: true,
//                       formatButtonVisible: true,
//                       leftChevronVisible: false,
//                       rightChevronVisible: false),
//                   availableGestures: AvailableGestures.none,
//                   builders: CalendarBuilders(
//                     outsideWeekendDayBuilder: (context, date, events) {
//                       return null;
//                     },
//                     outsideDayBuilder: (context, date, events) {
//                       return null;
//                     },
//                     markersBuilder: (context, date, events, holidays) {
//                       final children = <Widget>[];
//                       children.add(Container(
//                           width: double.infinity,
//                           height: double.infinity,
//                           padding: EdgeInsets.all(5),
//                           child: Container(
//                             width: double.infinity,
//                             height: double.infinity,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(10),
//                               color: Color.fromRGBO(237, 237, 237, 1),
//                             ),
//                             child: Icon(
//                               Icons.emoji_emotions,
//                             ),
//                           )));
//                       return children;
//                     },
//                   ),
//                 ),
//               ),
