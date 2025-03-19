import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:intl/intl.dart';
import 'package:user_app/attendence_calender.dart';
import 'package:user_app/main.dart';

class ParentAttendanceCard extends StatefulWidget {
  final int childId;

  const ParentAttendanceCard({Key? key, required this.childId})
      : super(key: key);

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
      totalWorkingDays = _calculateWorkingDays(firstDayOfMonth, now);

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

      final attendanceResponse = await supabase
          .from('tbl_childattendence')
          .select('attendence_status')
          .eq('child_id', widget.childId)
          .gte('attendence_date', DateFormat('yyyy-MM-01').format(now))
          .lte('attendence_date', DateFormat('yyyy-MM-dd').format(now));

      attendedDays = attendanceResponse
          .where((record) => record['attendence_status'] == 1)
          .length;

      if (totalWorkingDays > 0) {
        attendancePercentage = (attendedDays / totalWorkingDays);
      }

      setState(() {});
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

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
        title: Text(
          "Attendance",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        // This centers the entire column
        child: SingleChildScrollView(
          // Prevents overflow issues
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(childPhoto),
                      radius: 40,
                    ),
                    SizedBox(height: 10),
                    Text(
                      childName,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text("Total Days: $totalWorkingDays"),
                    Text("Present Days: $attendedDays"),
                    SizedBox(height: 20),
                    CircularPercentIndicator(
                      radius: 80.0,
                      lineWidth: 10.0,
                      percent: attendancePercentage,
                      center: Text(
                        "${(attendancePercentage * 100).toStringAsFixed(2)}%",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      progressColor: Colors.green,
                      backgroundColor: Colors.grey[300]!,
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AttendanceCalendarPage(childId: widget.childId),
                          ),
                        );
                      },
                      child: Text("View Attendance Calendar"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
