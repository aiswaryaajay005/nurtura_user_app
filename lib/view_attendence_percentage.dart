import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:intl/intl.dart';

import 'package:user_app/main.dart';

class ParentAttendanceCard extends StatefulWidget {
  final int childId;

  const ParentAttendanceCard({required this.childId});

  @override
  _ParentAttendanceCardState createState() => _ParentAttendanceCardState();
}

class _ParentAttendanceCardState extends State<ParentAttendanceCard> {
  String childName = "Loading...";
  String childPhoto = "";
  int totalWorkingDays = 0;
  int attendedDays = 0;
  double attendancePercentage = 0.0;

  @override
  void initState() {
    super.initState();
    fetchChildAndAttendanceData();
  }

  Future<void> fetchChildAndAttendanceData() async {
    try {
      DateTime now = DateTime.now();
      DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);

      // Get total working days (Monday-Friday)
      totalWorkingDays = _calculateWorkingDays(firstDayOfMonth, now);

      // Fetch child details
      final childResponse = await supabase
          .from('tbl_child')
          .select('child_name, child_photo')
          .eq('id', widget.childId)
          .maybeSingle();

      if (childResponse != null) {
        childName = childResponse['child_name'] ?? "Unknown";
        childPhoto = childResponse['child_photo'] ??
            "https://example.com/default-profile.png";
      }

      // Fetch attendance records
      final attendanceResponse = await supabase
          .from('tbl_childattendence')
          .select('attendence_status')
          .eq('child_id', widget.childId)
          .gte('attendence_date', DateFormat('yyyy-MM-01').format(now))
          .lte('attendence_date', DateFormat('yyyy-MM-dd').format(now));

      // Count Present Days
      attendedDays = attendanceResponse
          .where((record) => record['attendence_status'] == 1)
          .length;

      // Calculate percentage
      if (totalWorkingDays > 0) {
        attendancePercentage = (attendedDays / totalWorkingDays);
      }

      setState(() {}); // Update UI
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  // Function to count working days (excluding weekends)
  int _calculateWorkingDays(DateTime start, DateTime end) {
    int count = 0;
    for (var day = start;
        day.isBefore(end) || day.isAtSameMomentAs(end);
        day = day.add(Duration(days: 1))) {
      if (day.weekday != DateTime.saturday && day.weekday != DateTime.sunday) {
        count++;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepPurple,
        title: Text("Attendence "),
      ),
      body: Padding(
        padding: const EdgeInsets.all(100),
        child: Card(
          shadowColor: Colors.deepPurple,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 20,
              children: [
                SizedBox(width: 10),
                SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        childName,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text("Total Days  : $totalWorkingDays"),
                      Text("Present Days: $attendedDays"),
                    ],
                  ),
                ),
                CircularPercentIndicator(
                  radius: 70.0,
                  lineWidth: 8.0,
                  percent: attendancePercentage,
                  center: Text(
                    "${(attendancePercentage * 100).toStringAsFixed(2)}%",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  progressColor: Colors.green,
                  backgroundColor: Colors.grey[300]!,
                  circularStrokeCap: CircularStrokeCap.round,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
