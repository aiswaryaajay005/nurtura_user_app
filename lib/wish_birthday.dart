import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_app/main.dart';

class WishBirthday extends StatefulWidget {
  const WishBirthday({super.key});

  @override
  State<WishBirthday> createState() => _WishBirthdayState();
}

class _WishBirthdayState extends State<WishBirthday> {
  List<Map<String, dynamic>> birthdayChildren = [];
  bool isLoading = true;
  TextEditingController wishController = TextEditingController();
  @override
  void initState() {
    super.initState();
    fetchBirthdays();
  }

  Future<void> sendWish(int childId) async {
    if (wishController.text.isEmpty) return;

    final User? user = supabase.auth.currentUser;

    if (user == null) {
      print("User not logged in!");
      return;
    }

    try {
      await supabase.from('tbl_wish').insert({
        'child_id': childId,
        'parent_id': user.id,
        'wish_content': wishController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Wish sent successfully! 🎉")),
      );
      wishController.clear();
      Navigator.pop(context);
    } catch (e) {
      print("Error sending wish: $e");
    }
  }

  Future<void> fetchBirthdays() async {
    List<Map<String, dynamic>> todaysBirthdays = await getTodaysBirthdays();
    setState(() {
      birthdayChildren = todaysBirthdays;
      isLoading = false;
    });
  }

  Future<List<Map<String, dynamic>>> getTodaysBirthdays() async {
    String today = DateFormat('MM-dd').format(DateTime.now());

    try {
      final response = await supabase
          .from('tbl_child')
          .select('id, child_name, child_dob, child_photo');

      if (response.isEmpty) return [];

      List<Map<String, dynamic>> birthdayChildren = response.where((child) {
        String dob = child['child_dob'];

        return dob.substring(5) == today;
      }).toList();

      return birthdayChildren;
    } catch (e) {
      print("Error fetching birthdays: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepPurple,
        title: Text("Wishes", style: TextStyle(color: Colors.white)),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : birthdayChildren.isEmpty
              ? Center(child: Text("No birthdays today! 🎂"))
              : Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: birthdayChildren.length,
                    itemBuilder: (context, index) {
                      var child = birthdayChildren[index];

                      return Card(
                        shadowColor: Colors.deepPurple,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            children: [
                              SizedBox(height: 20),
                              Row(
                                children: [
                                  SizedBox(width: 5),
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundImage:
                                        child['child_photo'] != null
                                            ? NetworkImage(child['child_photo'])
                                            : AssetImage(
                                                    "assets/default_avatar.png")
                                                as ImageProvider,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                      "${child['child_name']} is celebrating today! 🎉"),
                                ],
                              ),
                              SizedBox(height: 20),
                              ElevatedButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (context) {
                                        return SizedBox(
                                          height: 200,
                                          child: Column(
                                            children: [
                                              SizedBox(height: 20),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0,
                                                    bottom: 8.0,
                                                    left: 20,
                                                    right: 20),
                                                child: Form(
                                                  child: TextFormField(
                                                    controller: wishController,
                                                    decoration: InputDecoration(
                                                        border:
                                                            OutlineInputBorder(),
                                                        enabledBorder: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                            borderSide: BorderSide(
                                                                color: Colors
                                                                    .deepPurple)),
                                                        focusedBorder: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                            borderSide: BorderSide(
                                                                color: Colors
                                                                    .deepPurple)),
                                                        hintText:
                                                            "Enter your wishes"),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 20),
                                              ElevatedButton(
                                                  onPressed: () {
                                                    int childid = child['id'];
                                                    sendWish(childid);
                                                  },
                                                  child: Text("Send Wishes"))
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Text("Wish Me")),
                              SizedBox(height: 20)
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
