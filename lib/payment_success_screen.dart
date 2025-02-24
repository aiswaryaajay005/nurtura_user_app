import 'package:flutter/material.dart';
import 'dart:async';

import 'package:user_app/parent_dashboard.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final int childId;

  const PaymentSuccessScreen({super.key, required this.childId});

  @override
  _PaymentSuccessScreenState createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  @override
  void initState() {
    super.initState();

    // Delay for 2 seconds and then navigate to the next screen
    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ParentDashboard(
                  childId: widget.childId,
                )),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Success color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center, // Align everything at the center
              children: [
                // Generate concentric circles dynamically
                for (int i = 0; i < 4; i++)
                  CircleAvatar(
                    radius: 100 - (i * 20), // Decrease radius for each circle
                    backgroundColor: Colors.deepPurple[100 + (i * 100)],
                  ),

                // Icon at the top
                Icon(Icons.check, size: 60, color: Colors.white),
              ],
            ),
            SizedBox(height: 20),
            Text(
              "Payment Successful!",
              style: TextStyle(
                  fontSize: 24,
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
