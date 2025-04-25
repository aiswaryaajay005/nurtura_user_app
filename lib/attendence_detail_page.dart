import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:user_app/main.dart';

class AttendanceDetailsPage extends StatefulWidget {
  final int childId;

  const AttendanceDetailsPage({Key? key, required this.childId})
      : super(key: key);

  @override
  _AttendanceDetailsPageState createState() => _AttendanceDetailsPageState();
}

class _AttendanceDetailsPageState extends State<AttendanceDetailsPage> {
  Map<int, String> attendanceStatus = {}; // Store day-wise attendance
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAttendanceData();
  }

  Future<void> fetchAttendanceData() async {
    try {
      DateTime now = DateTime.now();
      DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
      DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

      // Fetch attendance records for the current month
      final attendanceResponse = await supabase
          .from('tbl_childattendence')
          .select('attendence_date, attendence_status')
          .eq('child_id', widget.childId)
          .gte('attendence_date', DateFormat('yyyy-MM-01').format(now))
          .lte('attendence_date', DateFormat('yyyy-MM-dd').format(now));

      // Map attendance data
      Map<int, String> tempStatus = {};
      for (var record in attendanceResponse) {
        DateTime date = DateTime.parse(record['attendence_date']);
        int day = date.day;

        if (record['attendence_status'] == 1) {
          tempStatus[day] = "present";
        } else if (record['attendence_status'] == 0) {
          tempStatus[day] = "absent";
        }
      }

      // Mark unmarked days
      for (int i = 1; i <= lastDayOfMonth.day; i++) {
        tempStatus.putIfAbsent(i, () => "unmarked");
      }

      setState(() {
        attendanceStatus = tempStatus;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching attendance: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    int totalDays = DateTime(now.year, now.month + 1, 0).day;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Attendance Details",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('MMMM yyyy').format(DateTime.now()),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: totalDays,
                      itemBuilder: (context, index) {
                        int day = index + 1;
                        String status = attendanceStatus[day] ?? "unmarked";

                        Color getColor(String status) {
                          if (status == "present") return Colors.green;
                          if (status == "absent") return Colors.red;
                          return Colors.grey;
                        }

                        return Container(
                          decoration: BoxDecoration(
                            color: getColor(status),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              "$day",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
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
