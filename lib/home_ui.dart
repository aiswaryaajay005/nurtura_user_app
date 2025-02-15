import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:user_app/main.dart';
import 'package:user_app/parent_dashboard.dart'; // Import the package

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

  List<Map<String, dynamic>> childdetails = [];
  PageController _pageController =
      PageController(); // PageController for PageView

  @override
  void initState() {
    super.initState();
    fetchChild();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepPurple,
        title: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ParentDashboard(),
                ));
          },
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
      ),
      body: Column(
        children: [
          SizedBox(height: 40),
          SizedBox(
            height: 400,
            child: PageView.builder(
              controller: _pageController, // Attach the PageController
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
          // SmoothPageIndicator
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: SmoothPageIndicator(
              controller: _pageController, // Bind the controller here
              count:
                  introCards.length, // Set the number of items in the PageView
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
                                    onPressed: () {}, icon: Icon(Icons.add)),
                              ),
                            )
                          : Container(
                              padding: EdgeInsets.all(4), // Border thickness
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
                            );
                    },
                  ),
                )
              : Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "No child profiles added yet!",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
        ],
      ),
    );
  }
}
