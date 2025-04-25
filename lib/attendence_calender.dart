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
  Map<DateTime, String> attendanceMap = {};
  late DateTime selectedMonth;
  late DateTime firstDay;
  late DateTime lastDay;

  @override
  void initState() {
    super.initState();
    selectedMonth = DateTime.now(); // Default to current month
    fetchAttendanceData(selectedMonth);
  }

  Future<void> fetchAttendanceData(DateTime selectedMonth) async {
    try {
      // Calculate first and last day of the selected month
      firstDay = DateTime(selectedMonth.year, selectedMonth.month, 1);
      lastDay = DateTime(selectedMonth.year, selectedMonth.month + 1,
          0); // Last day of the month

      // Fetch attendance records for the selected month
      final attendanceResponse = await supabase
          .from('tbl_childattendence')
          .select('attendence_date, attendence_status')
          .eq('child_id', widget.childId)
          .gte('attendence_date', DateFormat('yyyy-MM-dd').format(firstDay))
          .lte('attendence_date', DateFormat('yyyy-MM-dd').format(lastDay));

      // Map attendance data
      Map<DateTime, String> tempAttendanceMap = {};
      for (var record in attendanceResponse) {
        DateTime date = DateTime.parse(record['attendence_date']);
        DateTime dateOnly = DateTime(date.year, date.month, date.day);

        int status = record[
            'attendence_status']; // Get the status (0 = absent, 1 = present)

        if (status == 1) {
          tempAttendanceMap[dateOnly] = "present"; // Present
        } else if (status == 0) {
          tempAttendanceMap[dateOnly] = "absent"; // Absent
        }
      }

      // Mark unmarked days
      DateTime today = DateTime.now();
      for (DateTime day = firstDay;
          day.isBefore(lastDay) || day.isAtSameMomentAs(lastDay);
          day = day.add(Duration(days: 1))) {
        if (!tempAttendanceMap.containsKey(day)) {
          if (day.weekday == DateTime.sunday) {
            tempAttendanceMap[day] = "sunday"; // Sundays
          } else {
            tempAttendanceMap[day] = "unmarked"; // Not marked
          }
        }
      }

      setState(() {
        attendanceMap = tempAttendanceMap;
      });
    } catch (e) {
      print("Error fetching attendance data: $e");
    }
  }

  // Function to get the color based on the status
  Color getStatusColor(String status) {
    switch (status) {
      case "present":
        return Colors.green; // Present - Green
      case "absent":
        return Colors.red; // Absent - Red
      case "sunday":
        return Colors.blue; // Sunday - Blue
      case "unmarked":
        return Colors.grey; // Unmarked - Grey
      default:
        return Colors.white; // Default to white for no status
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Attendance Calendar")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display the current month
            Text(
              DateFormat('MMMM yyyy').format(selectedMonth),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            // Table Calendar
            TableCalendar(
              focusedDay: selectedMonth,
              firstDay: DateTime(2020, 1, 1), // First date for the calendar
              lastDay: DateTime.now(), // Can change this to a future date
              calendarFormat: CalendarFormat.month,
              onPageChanged: (focusedDay) {
                // When the user scrolls to a different month
                setState(() {
                  selectedMonth = focusedDay;
                });
                fetchAttendanceData(focusedDay); // Fetch data for the new month
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, date, _) {
                  String status = attendanceMap[date] ??
                      "unmarked"; // Default to "unmarked"
                  Color color =
                      getStatusColor(status); // Get the corresponding color

                  return Container(
                    margin: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('d').format(date), // Day number
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 2),
                          Text(
                            status == "unmarked"
                                ? ""
                                : status.substring(0, 1).toUpperCase() +
                                    status.substring(
                                        1), // Capitalized status text
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// This code defines a Flutter widget that displays an attendance calendar for a specific child. It uses the TableCalendar package to create a calendar view and fetches attendance data from a Supabase database. The calendar highlights days based on their attendance status (present, absent, unmarked, or Sunday) using different colors. The user can scroll through months, and the attendance data is fetched accordingly.
// The calendar also displays the current month and allows for easy navigation through the days. The attendance data is represented in a map, and the colors are determined based on the status of each day.
