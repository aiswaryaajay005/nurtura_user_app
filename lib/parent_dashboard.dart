import 'package:flutter/material.dart';
import 'package:user_app/account.dart';
import 'package:user_app/add_child.dart';
import 'package:user_app/view_child_details.dart';
import 'package:user_app/view_event.dart';
import 'package:user_app/view_post.dart';

class ParentDashboard extends StatelessWidget {
  const ParentDashboard({super.key});

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
                        builder: (context) => ViewEvent(),
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
                leading: Icon(Icons.child_care_sharp, color: Colors.deepPurple),
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
                        builder: (context) => ViewChildDetails(),
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
    );
  }
}
