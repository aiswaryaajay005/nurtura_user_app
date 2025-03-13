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
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                for (int i = 0; i < 4; i++)
                  CircleAvatar(
                    radius: 100 - (i * 20),
                    backgroundColor: Colors.deepPurple[100 + (i * 100)],
                  ),
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
