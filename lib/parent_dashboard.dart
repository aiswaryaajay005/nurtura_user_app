import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:user_app/account.dart';
import 'package:user_app/all_activities.dart';
import 'package:user_app/child_leave.dart';
import 'package:user_app/fees_payment.dart';
import 'package:user_app/main.dart';
import 'package:user_app/milestones.dart';
import 'package:user_app/staff_contact.dart';
import 'package:user_app/view_attendence_percentage.dart';
import 'package:user_app/view_child_details.dart';
import 'package:user_app/view_complaints.dart';
import 'package:user_app/view_event.dart';
import 'package:user_app/view_notification.dart';
import 'package:user_app/view_post.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:user_app/view_wish.dart';
import 'package:user_app/wish_birthday.dart';

class ParentDashboard extends StatefulWidget {
  final int childId;
  const ParentDashboard({super.key, required this.childId});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  Future<Map<String, dynamic>?> checkTodaysBirthday() async {
    String today = DateFormat('MM-dd').format(DateTime.now());

    try {
      final response = await supabase
          .from('tbl_child')
          .select('id, child_name, child_dob, child_photo')
          .eq('child_dob', today)
          .eq('id', widget.childId)
          .maybeSingle();

      return response;
    } catch (e) {
      print("Error fetching birthday child: $e");
      return null;
    }
  }

  Future<List<String>> fetchMilestones(int childId) async {
    print("fetchMilestones called for child ID: $childId");

    final response = await supabase
        .from('tbl_child')
        .select('child_dob')
        .eq('id', childId)
        .single();

    print("Supabase Response: $response");

    if (response == null || response['child_dob'] == null) {
      print("Error: Child not found or missing DOB");
      throw Exception('Child not found or missing DOB');
    }

    DateTime childDob = DateTime.parse(response['child_dob']);
    int childAge = DateTime.now().difference(childDob).inDays ~/ 365;

    print("Child DOB: $childDob");
    print("Calculated Child Age: $childAge");

    List<String> milestonesByAge = milestones
        .where((milestone) => milestone['age'] == '$childAge years')
        .map((milestone) => milestone['milestone'] as String)
        .toList();

    print("Filtered Milestones: $milestonesByAge"); // Debugging

    if (milestonesByAge.isEmpty) {
      return ["No milestones found for this age."];
    }

    milestonesByAge.shuffle(Random());
    return milestonesByAge.take(3).toList();
  }

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
        iconTheme: IconThemeData(color: Colors.white),
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
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewNotification(),
                    ));
              },
              icon: Icon(Icons.notifications, color: Colors.white)),
          const SizedBox(width: 16),
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
            colors: [Colors.white, Color(0xFFEDE7F6)],
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
              SizedBox(height: 20),
              milestoneCarousel(widget.childId),
              const SizedBox(height: 20),
              FutureBuilder<Map<String, dynamic>?>(
                future: checkTodaysBirthday(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(); // Show loading spinner
                  }

                  if (!snapshot.hasData || snapshot.data == null) {
                    return SizedBox(); // No birthday, show nothing
                  }

                  var birthdayChild = snapshot.data!;

                  return Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade100,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.deepPurple,
                              blurRadius: 4,
                              spreadRadius: 2)
                        ],
                      ),
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage:
                                birthdayChild['child_photo'] != null
                                    ? NetworkImage(birthdayChild['child_photo'])
                                    : AssetImage("assets/default_avatar.png")
                                        as ImageProvider,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "🎉 Today is ${birthdayChild['child_name']}'s Birthday! 🎂",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ViewWish(childId: birthdayChild['id']),
                                ),
                              );
                            },
                            child: Text("View Wishes"),
                          ),
                        ],
                      ),
                    ),
                  );
                },
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
                              radius: 70,
                              backgroundImage:
                                  NetworkImage(child['child_photo']),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  child['child_name'],
                                  style: TextStyle(
                                      color: Colors.deepPurple,
                                      fontFamily: 'Nunito',
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  child['child_dob'],
                                  style: TextStyle(
                                      color: Colors.deepPurple,
                                      fontFamily: 'Nunito',
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  "How's your child doing today? ",
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
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
              SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                child: ListTile(
                  leading: Icon(Icons.event, color: Colors.deepPurple),
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
                  leading: Icon(Icons.photo_size_select_actual_outlined,
                      color: Colors.deepPurple),
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
              const SizedBox(height: 10),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                child: ListTile(
                  leading: Icon(Icons.sticky_note_2, color: Colors.deepPurple),
                  title: const Text("Inform Leave Details",
                      style: TextStyle(
                        fontFamily: 'Nunito',
                      )),
                  trailing:
                      Icon(Icons.arrow_forward_ios, color: Colors.deepPurple),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChildLeave(
                            id: widget.childId,
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
                  leading: Icon(Icons.calendar_month_rounded,
                      color: Colors.deepPurple),
                  title: const Text("Attendence Percentage",
                      style: TextStyle(
                        fontFamily: 'Nunito',
                      )),
                  trailing:
                      Icon(Icons.arrow_forward_ios, color: Colors.deepPurple),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ParentAttendanceCard(childId: widget.childId)));
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
                  leading: Icon(Icons.notes, color: Colors.deepPurple),
                  title: const Text("Compliants Page",
                      style: TextStyle(
                        fontFamily: 'Nunito',
                      )),
                  trailing:
                      Icon(Icons.arrow_forward_ios, color: Colors.deepPurple),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserComplaintsPage()));
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
                      Icon(Icons.contact_emergency, color: Colors.deepPurple),
                  title: const Text("Staff Contact",
                      style: TextStyle(
                        fontFamily: 'Nunito',
                      )),
                  trailing:
                      Icon(Icons.arrow_forward_ios, color: Colors.deepPurple),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => StaffPage()));
                  },
                ),
              ),
              SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                child: ListTile(
                  leading: Icon(Icons.event, color: Colors.deepPurple),
                  title: const Text("Wish birthday",
                      style: TextStyle(
                        fontFamily: 'Nunito',
                      )),
                  trailing:
                      Icon(Icons.arrow_forward_ios, color: Colors.deepPurple),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ViewWish(childId: widget.childId),
                        ));
                  },
                ),
              ),
              SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                child: ListTile(
                  leading: Icon(Icons.event, color: Colors.deepPurple),
                  title: const Text("Payments",
                      style: TextStyle(
                        fontFamily: 'Nunito',
                      )),
                  trailing:
                      Icon(Icons.arrow_forward_ios, color: Colors.deepPurple),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => FeesPayment()));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget milestoneCarousel(int childId) {
    return FutureBuilder<List<String>>(
      future: fetchMilestones(childId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.white));
        } else if (snapshot.hasError || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              "No milestones found for this age.",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          );
        }

        List<String> milestones = snapshot.data!;

        return Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(),
          child: CarouselSlider(
            options: CarouselOptions(
              height: 200,
              aspectRatio: 16 / 9,
              viewportFraction: 0.85,
              initialPage: 0,
              enableInfiniteScroll: true,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 3),
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              autoPlayCurve: Curves.easeInOut,
              enlargeCenterPage: true,
              enlargeFactor: 0.3,
              scrollDirection: Axis.horizontal,
            ),
            items: milestones.map((milestone) {
              return Container(
                width: MediaQuery.of(context).size.width * 0.85,
                margin: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                        "https://images.pexels.com/photos/10116050/pexels-photo-10116050.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2"), // Add a soft floral background
                    fit: BoxFit.cover,
                    opacity: 0.5,
                    // Keep it subtle
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 2,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      milestone,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.deepPurple, // Stylish purple text
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
