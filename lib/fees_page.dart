import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:user_app/form_validation.dart';
import 'package:user_app/main.dart';
import 'package:user_app/payment_success_screen.dart';

class FeesPage extends StatefulWidget {
  final int idChild;
  const FeesPage({super.key, required this.idChild});

  @override
  State<FeesPage> createState() => _FeesPageState();
}

class _FeesPageState extends State<FeesPage>
    with SingleTickerProviderStateMixin {
  int fee = 1000;
  TabController? _tabController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> updateStatus(int childId) async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    try {
      await supabase
          .from('tbl_child')
          .update({'child_status': 3, 'child_doj': formattedDate}).eq(
              'id', widget.idChild);

      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessScreen(childId: childId),
          ));
      setState(() {});
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration Fee Payments',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to Nutura Family',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Let’s proceed with the fee payment:',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                SizedBox(height: 20),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListTile(
                      title: Text(
                        "Total Fees",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      trailing: Text(
                        "₹$fee",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Select Payment Method",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          _tabController != null
              ? TabBar(
                  controller: _tabController,
                  labelColor: Colors.deepPurple,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.deepPurple,
                  tabs: [
                    Tab(text: "Credit Card"),
                    Tab(text: "UPI"),
                  ],
                )
              : SizedBox(),
          Expanded(
            child: _tabController != null
                ? TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCreditCardForm(),
                      _buildUpiForm(),
                    ],
                  )
                : Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditCardForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("CREDIT CARD NUMBER",
                    style: TextStyle(color: Colors.deepPurple)),
                TextFormField(
                    validator: (value) =>
                        FormValidation.validateCreditCardNumber(value),
                    decoration: InputDecoration()),
                SizedBox(height: 20),
                Text("CARD HOLDER NAME",
                    style: TextStyle(color: Colors.deepPurple)),
                TextFormField(
                  decoration: InputDecoration(),
                  validator: (value) =>
                      FormValidation.validateCardHolderName(value),
                ),
                SizedBox(height: 20),
                Text("EXPIRY", style: TextStyle(color: Colors.deepPurple)),
                TextFormField(
                  decoration: InputDecoration(),
                  validator: (value) =>
                      FormValidation.validateExpiryDate(value),
                ),
                SizedBox(height: 20),
                Text("CVV", style: TextStyle(color: Colors.deepPurple)),
                TextFormField(
                  decoration: InputDecoration(),
                  validator: (value) => FormValidation.validateCVV(value),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      updateStatus(widget.idChild);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.deepPurple,
                  ),
                  child: Center(
                    child: Text("Pay Now",
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpiForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("UPI ID", style: TextStyle(color: Colors.deepPurple)),
                TextFormField(
                  decoration: InputDecoration(),
                  validator: (value) => FormValidation.validateUpiId(value),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      updateStatus(widget.idChild);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.deepPurple,
                  ),
                  child: Center(
                    child: Text("Pay Now",
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
