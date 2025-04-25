import 'package:flutter/material.dart';
import 'package:user_app/fees_page.dart';
import 'package:user_app/main.dart';

class ChildPaymentView extends StatefulWidget {
  final int idch;
  const ChildPaymentView({super.key, required this.idch});

  @override
  State<ChildPaymentView> createState() => _ChildPaymentViewState();
}

class _ChildPaymentViewState extends State<ChildPaymentView> {
  String fee = "";
  bool isLoading = true;

  Future<void> feeAmount() async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await supabase
          .from('tbl_child')
          .select('child_dob')
          .eq('id', widget.idch)
          .single();

      DateTime childDob = DateTime.parse(response['child_dob']);
      int childAge = DateTime.now().difference(childDob).inDays ~/ 365;

      final output = await supabase
          .from('tbl_fees')
          .select('fees_amount')
          .eq('fees_age', childAge)
          .single();

      int amount = output['fees_amount'];

      setState(() {
        fee = amount.toString();
        isLoading = false;
      });

      print("Fee: $feeAmount");
      print("Child DOB: $childDob");
      print("Calculated Child Age: $childAge");
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    feeAmount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50], // Light background
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepPurple,
        title: Text(
          "Payment Details",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Text(
                    "Welcome to Nurtura",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: 20),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Text(
                            "Your Child's Fee Details",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          Divider(color: Colors.deepPurple),
                          SizedBox(height: 10),
                          _feeRow("Registration Fee:", "₹1000"),
                          SizedBox(height: 10),
                          _feeRow("Monthly Fee:", "₹$fee"),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FeesPage(
                                    idChild: widget.idch,
                                  )));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Proceed to Pay",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _feeRow(String title, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
