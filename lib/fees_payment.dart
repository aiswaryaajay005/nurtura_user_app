import 'package:flutter/material.dart';
import 'package:user_app/monthly_fees.dart';

class FeesPayment extends StatefulWidget {
  const FeesPayment({super.key});

  @override
  State<FeesPayment> createState() => _FeesPaymentState();
}

class _FeesPaymentState extends State<FeesPayment> {
  List months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(children: [
        ListView.builder(
          shrinkWrap: true,
          itemCount: 12,
          itemBuilder: (context, index) => ListTile(
            title: Text(months[index]),
            trailing: IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MonthlyFees(),
                      ));
                },
                icon: Icon(
                  Icons.arrow_forward_ios_outlined,
                )),
          ),
        ),
      ]),
    );
  }
}
