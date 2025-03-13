import 'package:flutter/material.dart';

class MonthlyFees extends StatefulWidget {
  const MonthlyFees({super.key});

  @override
  State<MonthlyFees> createState() => _MonthlyFeesState();
}

class _MonthlyFeesState extends State<MonthlyFees>
    with SingleTickerProviderStateMixin {
  int fee = 8500;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Fee Payment', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: "Credit Card"),
            Tab(text: "UPI"),
          ],
        ),
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
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCreditCardForm(),
                _buildUpiForm(),
              ],
            ),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("CREDIT CARD NUMBER",
                  style: TextStyle(color: Colors.deepPurple)),
              TextFormField(decoration: InputDecoration()),
              SizedBox(height: 20),
              Text("CARD HOLDER NAME",
                  style: TextStyle(color: Colors.deepPurple)),
              TextFormField(decoration: InputDecoration()),
              SizedBox(height: 20),
              Text("EXPIRY", style: TextStyle(color: Colors.deepPurple)),
              TextFormField(decoration: InputDecoration()),
              SizedBox(height: 20),
              Text("CVV", style: TextStyle(color: Colors.deepPurple)),
              TextFormField(decoration: InputDecoration()),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
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
    );
  }

  Widget _buildUpiForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("UPI ID", style: TextStyle(color: Colors.deepPurple)),
              TextFormField(decoration: InputDecoration()),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
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
    );
  }
}
