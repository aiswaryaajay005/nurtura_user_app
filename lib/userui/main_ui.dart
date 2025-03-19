import 'dart:math';

import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:user_app/about_us.dart';
import 'package:user_app/user_login.dart';

class MainUi extends StatefulWidget {
  const MainUi({super.key});

  @override
  _MainUiState createState() => _MainUiState();
}

class _MainUiState extends State<MainUi> {
  // Create a PageController to control the PageView
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // PageView with controller
          Expanded(
            child: PageView(
              onPageChanged: (value) {},
              controller: _controller,
              scrollDirection: Axis.horizontal,
              children: [
                _buildPage(
                    'assets/images/mom.webp',
                    'Your little one',
                    'will love us',
                    'A safe, nurturing, and fun environment where your child can learn, play, and grow.',
                    false),
                _buildPage(
                    'assets/images/kid.webp',
                    'We provide ease',
                    'for the parents',
                    'Stay connected with your child’s daily activities, meals, and milestones. Get real-time updates and peace of mind, wherever you are',
                    false),
                _buildPage(
                    'assets/images/last.webp',
                    'Your child will',
                    'be happy here',
                    'From creative learning to playful adventures, we ensure every child enjoys a loving and engaging experience every day.',
                    true),
              ],
            ),
          ),
          // SmoothPageIndicator to show the current page
          Container(
            width: double.infinity,
            color: Colors.white,
            child: Center(
              child: SmoothPageIndicator(
                controller: _controller, // PageController to sync with PageView
                count: 3, // Total number of pages
                effect: WormEffect(
                  // Choose the effect (Worm, Fade, Slide, etc.)
                  paintStyle: PaintingStyle.fill,
                  dotColor: Colors.grey,
                  activeDotColor: Colors.deepPurple,
                  dotHeight: 10,
                  dotWidth: 10,
                  spacing: 8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // A method to build each page
  Widget _buildPage(String image, String title, String subtitle,
      String description, bool showBtn) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 250,
            backgroundImage: AssetImage(image),
          ),
          Text(
            title,
            style: TextStyle(
                fontSize: 30,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontSize: 30,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Nunito'),
            ),
          ),
          showBtn
              ? Column(
                  children: [
                    ElevatedButton(
                        style: ButtonStyle(
                            elevation: WidgetStatePropertyAll(10),
                            padding: WidgetStatePropertyAll(EdgeInsets.only(
                                left: 30, right: 30, top: 10, bottom: 15)),
                            backgroundColor:
                                WidgetStatePropertyAll(Colors.white)),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AboutUs(),
                              ));
                        },
                        child: Text("About Us")),
                    ElevatedButton(
                        style: ButtonStyle(
                            elevation: WidgetStatePropertyAll(10),
                            padding: WidgetStatePropertyAll(EdgeInsets.only(
                                left: 30, right: 30, top: 10, bottom: 15)),
                            backgroundColor:
                                WidgetStatePropertyAll(Colors.white)),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserLogin(),
                              ));
                        },
                        child: Text("Get Started")),
                  ],
                )
              : Container()
        ],
      ),
    );
  }
}
