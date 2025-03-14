// ignore_for_file: deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:user_app/add_child.dart';
import 'package:user_app/fees_page.dart';
import 'package:user_app/main.dart';
import 'package:user_app/parent_dashboard.dart';
import 'package:confetti/confetti.dart';
import 'package:user_app/wish_birthday.dart';

class HomeUi extends StatefulWidget {
  const HomeUi({super.key});

  @override
  State<HomeUi> createState() => _HomeUiState();
}

class _HomeUiState extends State<HomeUi> {
  final List<String> introCards = [
    "Welcome to Nurtura Daycare! \nA place where your child can learn, play, and grow.",
    "What We Offer:\n Safe Environment\n Fun Learning Activities\n Healthy Meals & Snacks\n Daily Parent Updates",
    "How It Works:\n1️ Add your child’s profile\n2️ Get daily updates & activities\n3️ Communicate with caregivers easily",
    "Let's Get Started! \nTap the button below to view your child’s profile."
  ];
  final List<String> photoCards = [
    "assets/images/backpack.svg",
    "assets/images/curiosity.svg",
    "assets/images/dolls.svg",
    "assets/images/child.svg"
  ];
  final ConfettiController _confettiController =
      ConfettiController(duration: Duration(seconds: 5));

  Future<void> checkAndShowBirthdayDialogue(BuildContext context) async {
    List<Map<String, dynamic>> todaysBirthdays = await getTodaysBirthdays();

    if (todaysBirthdays.isNotEmpty) {
      String names =
          todaysBirthdays.map((child) => child['child_name']).join(', ');
      birthdayDialogue(context, names);
    }
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

  void birthdayDialogue(BuildContext context, String birthdayNames) {
    _confettiController.play();
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.deepPurple.shade500,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "🎉 We have a birthday today! 🎂",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "$birthdayNames is celebrating their birthday today! Let's make it special!",
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _confettiController.stop();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WishBirthday(),
                            ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text("Wish",
                          style: TextStyle(color: Colors.deepPurple)),
                    )
                  ],
                ),
              ),
              Positioned(
                top: 0,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: [
                    Colors.white,
                    Colors.deepPurple,
                    Colors.red,
                    Colors.pink,
                    Colors.blue,
                    Colors.yellow,
                    Colors.green
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> childdetails = [];
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    checkAndShowBirthdayDialogue(context);
    fetchChild();
    _confettiController.play();
  }

  Future<void> fetchChild() async {
    try {
      String userId = supabase.auth.currentUser!.id;
      print("User: $userId");
      final response =
          await supabase.from('tbl_child').select().eq('parent_id', userId);
      if (response.isNotEmpty) {
        setState(() {
          childdetails = response;
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> viewStatus(int childId, int childStatus) async {
    if (childStatus == 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Under Review"),
      ));
    } else if (childStatus == 1) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FeesPage(
                    idChild: childId,
                  )));
    } else if (childStatus == 3) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ParentDashboard(childId: childId)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Application Rejected, your data will be removed soon"),
      ));
      await supabase.from('tbl_child').delete().eq('id', childId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepPurple,
        title: GestureDetector(
          onTap: () {},
          child: Text(
            "Nurtura",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'AmsterdamThree',
              fontSize: 50,
            ),
          ),
        ),
        actions: [
          // IconButton(
          //   icon: Icon(Icons.brightness_6),
          //   onPressed: () {
          //     Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
          //   },
          // )
          IconButton(
              onPressed: () {
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => ViewNotification(),
                //     ));
                // birthdayDialogue();
              },
              icon: Icon(Icons.notifications, color: Colors.white))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 40),
            SizedBox(
              height: 400,
              child: PageView.builder(
                controller: _pageController,
                itemCount: introCards.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.deepPurple, Colors.purpleAccent],
                        ),
                        borderRadius: BorderRadius.circular(20)),
                    child: Card(
                      margin: EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                introCards[index],
                                style: TextStyle(
                                    color: Colors.deepPurple,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Cheese'),
                                textAlign: TextAlign.center,
                              ),
                              Expanded(
                                child: SvgPicture.asset(
                                  photoCards[index],
                                  height: 200,
                                  width: double.infinity,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: introCards.length,
                effect: WormEffect(
                  dotWidth: 10,
                  dotHeight: 10,
                  radius: 5,
                  spacing: 16,
                  dotColor: Colors.deepPurple.withOpacity(0.5),
                  activeDotColor: Colors.deepPurple,
                ),
              ),
            ),
            SizedBox(height: 30),
            childdetails.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: childdetails.length + 1,
                      itemBuilder: (context, index) {
                        return childdetails.length == index
                            ? CircleAvatar(
                                child: Center(
                                  child: IconButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AddChild(),
                                            ));
                                      },
                                      icon: Icon(Icons.add)),
                                ),
                              )
                            : GestureDetector(
                                onTap: () {
                                  viewStatus(childdetails[index]['id'],
                                      childdetails[index]['child_status']);
                                },
                                child: Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.deepPurple,
                                        Colors.purpleAccent
                                      ],
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundImage: childdetails[index]
                                                    ['child_photo']
                                                ?.isNotEmpty ==
                                            true
                                        ? NetworkImage(
                                            childdetails[index]['child_photo'])
                                        : const AssetImage(
                                            'assets/images/colors.jpg'),
                                  ),
                                ),
                              );
                      },
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      "No child profiles added yet!",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
