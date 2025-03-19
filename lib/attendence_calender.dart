import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:user_app/main.dart';

class AttendanceCalendarPage extends StatefulWidget {
  final int childId;

  const AttendanceCalendarPage({Key? key, required this.childId})
      : super(key: key);

  @override
  _AttendanceCalendarPageState createState() => _AttendanceCalendarPageState();
}

class _AttendanceCalendarPageState extends State<AttendanceCalendarPage> {
  Map<DateTime, Color> attendanceMap = {};
  DateTime firstDay = DateTime.now();
  DateTime lastDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchAttendanceData();
  }

  Future<void> fetchAttendanceData() async {
    try {
      final childResponse = await supabase
          .from('tbl_child')
          .select('child_doj')
          .eq('id', widget.childId)
          .maybeSingle();

      if (childResponse != null) {
        firstDay = DateTime.parse(childResponse['child_doj']);
      }

      final attendanceResponse = await supabase
          .from('tbl_childattendence')
          .select('attendence_date, attendence_status')
          .eq('child_id', widget.childId);

      DateTime today = DateTime.now();

      for (var record in attendanceResponse) {
        DateTime date = DateTime.parse(record['attendence_date']);
        int status = record['attendence_status'];

        if (status == 1) {
          attendanceMap[date] = Colors.green; // Present
        } else {
          attendanceMap[date] = Colors.red; // Absent
        }
      }

      for (DateTime day = firstDay;
          day.isBefore(today) || day.isAtSameMomentAs(today);
          day = day.add(Duration(days: 1))) {
        if (!attendanceMap.containsKey(day)) {
          if (day.weekday == DateTime.sunday) {
            attendanceMap[day] = Colors.blue; // Sundays
          } else {
            attendanceMap[day] = Colors.grey; // Not Marked
          }
        }
      }

      setState(() {});
    } catch (e) {
      print("Error fetching attendance data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Attendance Calendar")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TableCalendar(
          focusedDay: DateTime.now(),
          firstDay: firstDay,
          lastDay: DateTime.now(),
          calendarFormat: CalendarFormat.month,
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, date, _) {
              return Container(
                margin: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: attendanceMap[date] ?? Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    DateFormat('d').format(date),
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
