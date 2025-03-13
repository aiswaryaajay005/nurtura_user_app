import 'package:flutter/material.dart';
import 'package:user_app/compliant_page.dart';
import 'package:user_app/main.dart';

class UserComplaintsPage extends StatefulWidget {
  const UserComplaintsPage({Key? key}) : super(key: key);

  @override
  State<UserComplaintsPage> createState() => _UserComplaintsPageState();
}

class _UserComplaintsPageState extends State<UserComplaintsPage> {
  List<Map<String, dynamic>> _complaints = [];

  @override
  void initState() {
    super.initState();
    fetchUserComplaints();
  }

  Future<void> fetchUserComplaints() async {
    try {
      final user = supabase.auth.currentUser; // Get logged-in user
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("You must be logged in!"),
              backgroundColor: Colors.red),
        );
        return;
      }

      final response = await supabase
          .from('tbl_complaints')
          .select('*')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      setState(() {
        _complaints = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print("Error fetching complaints: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "My Complaints",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: _complaints.isEmpty
          ? Center(child: Text("No complaints found"))
          : ListView.builder(
              itemCount: _complaints.length,
              itemBuilder: (context, index) {
                final complaint = _complaints[index];

                return Card(
                  margin: EdgeInsets.all(10),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Complaint: ${complaint['complaint']}",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        Text("Status: ${complaint['status']}",
                            style: TextStyle(
                                color: complaint['status'] == 'Resolved'
                                    ? Colors.green
                                    : Colors.red)),
                        SizedBox(height: 10),
                        complaint['response'] != null
                            ? Text("Admin Response: ${complaint['response']}",
                                style: TextStyle(color: Colors.blue))
                            : Text("No response yet",
                                style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ComplaintPage(),
              ));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
