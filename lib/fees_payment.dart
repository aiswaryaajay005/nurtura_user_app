// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:user_app/main.dart';
import 'package:user_app/monthly_fees.dart';

class FeesPayment extends StatefulWidget {
  final int idChild;
  const FeesPayment({super.key, required this.idChild});

  @override
  State<FeesPayment> createState() => _FeesPaymentState();
}

class _FeesPaymentState extends State<FeesPayment> {
  int totalDueAmount = 0;
  bool isLoading = true;
  String? timestamp;
  @override
  void initState() {
    super.initState();
    calculateFeesDue();
    fetchPaymentDetails();
  }

  List<Map<String, dynamic>> payments = [];
  Future<void> fetchPaymentDetails() async {
    try {
      final response = await supabase
          .from('tbl_payment')
          .select()
          .eq('child_id', widget.idChild);
      setState(() {
        payments = response;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> calculateFeesDue() async {
    try {
      DateTime now = DateTime.now();
      DateTime lastPaidDate;

      // Fetch latest payment timestamp (if exists)
      final latestPaymentResponse = await supabase
          .from('tbl_payment')
          .select('created_at')
          .eq('child_id', widget.idChild)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle(); // Handles empty results safely

      if (latestPaymentResponse == null) {
        // No previous payment history, fetch child's joining date (DOJ)
        final childResponse = await supabase
            .from('tbl_child')
            .select('child_doj, child_dob')
            .eq('id', widget.idChild)
            .single();

        lastPaidDate =
            DateTime.parse(childResponse['child_doj']); // Start from DOJ
      } else {
        lastPaidDate = DateTime.parse(latestPaymentResponse['created_at']);
      }

      // Calculate number of unpaid months
      int unpaidMonths = (now.year - lastPaidDate.year) * 12 +
          (now.month - lastPaidDate.month);

      // Fetch child's age
      final childResponse = await supabase
          .from('tbl_child')
          .select('child_dob')
          .eq('id', widget.idChild)
          .single();

      DateTime childDob = DateTime.parse(childResponse['child_dob']);
      int childAge = now.difference(childDob).inDays ~/ 365;

      // Fetch fee amount based on child's age
      final feeResponse = await supabase
          .from('tbl_fees')
          .select('fees_amount')
          .eq('fees_age', childAge)
          .single();

      int monthlyFee = feeResponse['fees_amount'];
      int totalDue = unpaidMonths * monthlyFee;

      setState(() {
        totalDueAmount = totalDue;
        isLoading = false;
      });
    } catch (e) {
      print("Error calculating fees due: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fees Due"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: isLoading
                  ? Text("No due")
                  : totalDueAmount == 0
                      ? Text(
                          "No pending fees!",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Total Fees Due:",
                              style: TextStyle(fontSize: 22),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "₹$totalDueAmount",
                              style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber),
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MonthlyFees(
                                        fees: totalDueAmount,
                                        childId: widget.idChild,
                                      ),
                                    ));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.deepPurple,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                textStyle: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              child: Text("Proceed to Pay"),
                            ),
                          ],
                        ),
            ),
          ),
          Divider(),
          Text(
            "Payment History",
            style: TextStyle(fontSize: 26),
          ),
          SizedBox(
              height: 400,
              width: 400,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: payments.length,
                  itemBuilder: (context, index) {
                    DateTime dateTime =
                        DateTime.parse(payments[index]['created_at']);
                    String formattedDate =
                        DateFormat('yyyy-MM-dd').format(dateTime);
                    return Card(
                      child: Column(
                        children: [
                          Text("Payment date: $formattedDate"),
                          Text(
                              "Payment Amount:" + payments[index]['amount_due'])
                        ],
                      ),
                    );
                  }))
        ],
      ),
    );
  }
}
