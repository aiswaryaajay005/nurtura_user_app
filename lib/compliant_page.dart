import 'package:flutter/material.dart';

import 'package:user_app/main.dart';

class ComplaintPage extends StatefulWidget {
  const ComplaintPage({
    super.key,
  });

  @override
  State<ComplaintPage> createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  final TextEditingController _complaintController = TextEditingController();

  Future<void> submitComplaint() async {
    try {
      final user = supabase.auth.currentUser; // Get current user
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("You must be logged in to submit a complaint!"),
              backgroundColor: Colors.red),
        );
        return;
      }

      if (_complaintController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Complaint cannot be empty!"),
              backgroundColor: Colors.red),
        );
        return;
      }

      await supabase.from('tbl_complaints').insert({
        'user_id': user.id, // Retrieve user ID automatically
        'complaint': _complaintController.text.trim(),
        'status': 'Pending',
      });

      _complaintController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Complaint Submitted!")),
      );
    } catch (e) {
      print("Error submitting complaint: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Failed to submit. Try again!"),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Submit a Complaint",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextFormField(
              controller: _complaintController,
              maxLines: 4,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Your Complaint",
                hintText: "Describe your issue...",
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitComplaint,
              child: Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
