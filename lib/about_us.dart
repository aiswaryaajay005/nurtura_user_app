import 'package:flutter/material.dart';
import 'package:user_app/main.dart';
import 'package:user_app/user_login.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({super.key});

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  List<Map<String, dynamic>> feeDetails = [];

  Future<void> FetchFees() async {
    try {
      final response = await supabase.from('tbl_fees').select('*');
      setState(() {
        feeDetails = response;
      });
    } catch (e) {
      print("Error fetching fees: $e");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    FetchFees();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("About Us",
            style:
                TextStyle(fontFamily: "AmsterdamThree", color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple.shade700,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/logotree.png",
                height: 150,
              ),
              SizedBox(height: 10),
              Text(
                "Nurtura",
                style: TextStyle(
                  fontFamily: "AmsterdamThree",
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade800,
                ),
              ),
              SizedBox(height: 20),
              _buildSectionTitle("Our Vision"),
              _buildSectionContent(
                  "To nurture young minds and shape a better future."),
              _buildSectionTitle("Our Mission"),
              _buildSectionContent(
                  "Providing quality education in a safe and supportive environment."),
              _buildSectionTitle("Location"),
              _buildSectionContent("123 Green Street, Nature Valley, Earth"),
              _buildSectionTitle("Contact Details"),
              _buildSectionContent(
                  "Phone: +91 9048820456 | Email: nurtura@gmail.com"),
              _buildSectionTitle("Working Days"),
              _buildSectionContent(
                  "Mondays to Saturdays (Public holidays are considered as leave days for our daycare)"),
              _buildSectionTitle("Timings"),
              _buildSectionContent("Morning 9:00 AM to Evening 6:00 PM"),
              _buildSectionTitle("Fee Structure"),
              feeDetails.isEmpty
                  ? CircularProgressIndicator()
                  : DataTable(
                      columnSpacing: 20,
                      headingRowColor: MaterialStateColor.resolveWith(
                          (states) => Colors.deepPurple.shade800),
                      columns: [
                        DataColumn(label: _buildTableHeader("F.No")),
                        DataColumn(label: _buildTableHeader("Fees Amount")),
                        DataColumn(label: _buildTableHeader("Child Age")),
                      ],
                      rows: feeDetails.asMap().entries.map((entry) {
                        int index = entry.key + 1;
                        Map<String, dynamic> fee = entry.value;
                        return DataRow(cells: [
                          DataCell(Text(index.toString())),
                          DataCell(Text(fee['fees_amount'].toString() ?? '')),
                          DataCell(Text(fee['fees_age'].toString() ?? '')),
                        ]);
                      }).toList(),
                    ),
              ElevatedButton(
                  style: ButtonStyle(
                      elevation: WidgetStatePropertyAll(10),
                      padding: WidgetStatePropertyAll(EdgeInsets.only(
                          left: 30, right: 30, top: 10, bottom: 15)),
                      backgroundColor: WidgetStatePropertyAll(Colors.white)),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserLogin(),
                        ));
                  },
                  child: Text("Get Started")),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple.shade800,
        ),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        content,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Montserrat-Regular',
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}
