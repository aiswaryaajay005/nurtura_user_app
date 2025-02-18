import 'package:flutter/material.dart';
import 'package:user_app/account.dart';
import 'package:user_app/add_child.dart';
import 'package:user_app/all_activities.dart';
import 'package:user_app/main.dart';
import 'package:user_app/view_child_details.dart';
import 'package:user_app/view_event.dart';
import 'package:user_app/view_post.dart';

class ParentDashboard extends StatefulWidget {
  final int childId;
  const ParentDashboard({super.key, required this.childId});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  TextEditingController _nowcontroller = TextEditingController(
    text: DateTime.now().toLocal().toString().split(' ')[0],
  );

  List<Map<String, dynamic>> childdetails = [];
  List<Map<String, dynamic>> childactivity = [];
  Future<void> fetchActivity() async {
    try {
      String todayDate = DateTime.now()
          .toLocal()
          .toString()
          .split(' ')[0]; // Get today's date in 'YYYY-MM-DD' format
      final response = await supabase
          .from('tbl_activity')
          .select()
          .eq('child_id', widget.childId)
          .eq('activity_date', todayDate);

      if (response.isNotEmpty) {
        setState(() {
          childactivity = response;
        });
      } else {
        setState(() {
          childactivity = [];
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchChild();
    fetchActivity();
  }

  Future<void> fetchChild() async {
    try {
      final response =
          await supabase.from('tbl_child').select().eq('id', widget.childId);
      if (response.isNotEmpty) {
        setState(() {
          childdetails = response;
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        title: const Text(
          "Nurtura",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'AmsterdamThree',
              fontSize: 50),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AccountPage()),
              );
            },
            child: const CircleAvatar(
              backgroundImage: AssetImage('assets/images/nurtura.png'),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFEDE7F6)], // Soft purple gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Welcome, Parent! ",
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: childdetails.length,
                  itemBuilder: (context, index) {
                    final child = childdetails[index];
                    return Card(
                      shadowColor: Colors.deepPurple,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          spacing: 20,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage:
                                  NetworkImage(child['child_photo']),
                            ),
                            Row(
                              children: [
                                Text(
                                  'Child Name:',
                                  style: TextStyle(color: Colors.deepPurple),
                                ),
                                Text(child['child_name']),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Child Gender: ',
                                  style: TextStyle(color: Colors.deepPurple),
                                ),
                                Text(child['child_gender']),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Date of Birth :',
                                  style: TextStyle(color: Colors.deepPurple),
                                ),
                                Text(child['child_dob']),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Child allergy details: ',
                                  style: TextStyle(color: Colors.deepPurple),
                                ),
                                Text(child['child_allergy']),
                              ],
                            ),
                            ElevatedButton(
                                onPressed: () {}, child: Text('Edit'))
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),
              Text(
                "How's your child doing today? ",
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 20),
              childactivity.isEmpty
                  ? const Center(
                      child: Text(
                        "No activities recorded for today.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.all(10),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                      ),
                      itemCount: childactivity.length,
                      itemBuilder: (context, index) {
                        final activity = childactivity[index];
                        return Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 5),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Text(
                                    activity['activity_date'] ?? 'No Details',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Feeling details:",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                Text(
                                  activity['feeling_details'] ?? 'No Details',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Nap details:",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                Text(
                                  activity['nap_schedule'] ?? 'No Details',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Playtime activities:",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                Text(
                                  activity['playtime_activities'] ??
                                      'No Details',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Learning activities:",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                Text(
                                  activity['learning_activities'] ??
                                      'No Details',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple, // Button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AllActivities(childId: widget.childId),
                      ),
                    );
                  },
                  child: const Text(
                    "View All Activities",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                child: ListTile(
                  leading: Icon(Icons.child_care, color: Colors.deepPurple),
                  title: const Text("Add child details",
                      style: TextStyle(
                        fontFamily: 'Nunito',
                      )),
                  trailing:
                      Icon(Icons.arrow_forward_ios, color: Colors.deepPurple),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddChild(),
                        ));
                  },
                ),
              ),
              const SizedBox(height: 10),
              // Example of a Styled Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                child: ListTile(
                  leading: Icon(Icons.child_care, color: Colors.deepPurple),
                  title: const Text("View Events",
                      style: TextStyle(
                        fontFamily: 'Nunito',
                      )),
                  trailing:
                      Icon(Icons.arrow_forward_ios, color: Colors.deepPurple),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewEvent(
                            childId: widget.childId,
                          ),
                        ));
                  },
                ),
              ),
              const SizedBox(height: 10),

              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                child: ListTile(
                  leading:
                      Icon(Icons.child_care_sharp, color: Colors.deepPurple),
                  title: const Text("View child details",
                      style: TextStyle(
                        fontFamily: 'Nunito',
                      )),
                  trailing:
                      Icon(Icons.arrow_forward_ios, color: Colors.deepPurple),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewChildDetails(
                            chId: widget.childId,
                          ),
                        ));
                  },
                ),
              ),
              const SizedBox(height: 10),

              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                child: ListTile(
                  leading: Icon(Icons.payment, color: Colors.deepPurple),
                  title: const Text("View Posts",
                      style: TextStyle(
                        fontFamily: 'Nunito',
                      )),
                  trailing:
                      Icon(Icons.arrow_forward_ios, color: Colors.deepPurple),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewPost(),
                        ));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
