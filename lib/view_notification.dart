import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:user_app/main.dart';

class ViewNotification extends StatefulWidget {
  const ViewNotification({super.key});

  @override
  State<ViewNotification> createState() => _ViewNotificationState();
}

class _ViewNotificationState extends State<ViewNotification> {
  List<Map<String, dynamic>> notificationList = [];
  Future<void> fetchNotification() async {
    try {
      final response = await supabase.from("tbl_notification").select();
      if (response.isNotEmpty) {
        setState(() {
          notificationList = response;
        });
      }
    } catch (e) {
      print("error $e");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchNotification();
  }

  String formatDate(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return "Unknown date";
    try {
      DateTime dateTime = DateTime.parse(timestamp);
      DateTime now = DateTime.now();
      Duration difference = now.difference(dateTime);

      if (difference.inDays == 0) {
        return timeago.format(dateTime, locale: 'en');
      } else if (difference.inDays == 1) {
        return "Yesterday";
      } else {
        return DateFormat("dd MMM yyyy").format(dateTime);
      }
    } catch (e) {
      return "Invalid date";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.white),
            backgroundColor: Colors.deepPurple,
            title: Text(
              "Notifications",
              style: TextStyle(color: Colors.white),
            )),
        body: notificationList.isEmpty
            ? Center(
                child: Text("No notifications available"),
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: notificationList.length,
                  itemBuilder: (context, index) {
                    final notif = notificationList[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                      child: ListTile(
                        title: Text(notif["notification_content"]),
                        trailing: Text(formatDate(notif['created_at'])),
                      ),
                    );
                  },
                ),
              ));
  }
}
