import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:user_app/chat_page.dart';
import 'package:user_app/main.dart';

// ... Previous imports remain the same

class StaffPage extends StatefulWidget {
  @override
  _StaffPageState createState() => _StaffPageState();
}

class _StaffPageState extends State<StaffPage> {
  Future<List<Map<String, dynamic>>> fetchStaff() async {
    final response = await supabase.from('tbl_staff').select();
    return response;
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      print('Could not launch $phoneNumber');
    }
  }

  void _sendEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      print('Could not launch $email');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepPurple,
        title: Text('Staff Directory', style: TextStyle(color: Colors.white)),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchStaff(),
        builder: (context, snapshot) {
          // ... Keep existing builder logic

          final staffList = snapshot.data!;

          return ListView.builder(
            itemCount: staffList.length,
            itemBuilder: (context, index) {
              final staff = staffList[index];
              return Card(
                child: ListTile(
                  leading: staff['staff_photo'] != null
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(staff['staff_photo']))
                      : CircleAvatar(child: Icon(Icons.person)),
                  title: Text(staff['staff_name']),
                  subtitle: Text(
                      '📞 ${staff['staff_contact']} \n📧 ${staff['staff_email']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.phone, color: Colors.green),
                        onPressed: () => _makePhoneCall(staff['staff_contact']),
                      ),
                      IconButton(
                        icon: Icon(Icons.email, color: Colors.blue),
                        onPressed: () => _sendEmail(staff['staff_email']),
                      ),
                      IconButton(
                        icon: Icon(Icons.chat, color: Colors.purple),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                staffId:
                                    staff['id'], // Assuming there's an id field
                                staffName: staff['staff_name'],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
