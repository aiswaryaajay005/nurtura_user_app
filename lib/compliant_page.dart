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
      final user = supabase.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("You must be logged in to submit a complaint!"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_complaintController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Complaint cannot be empty!"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      print("DEBUG: User ID = ${user.id}"); // Ensure it's a valid UUID

      final response = await supabase.from('tbl_complaints').insert({
        'user_id': user.id,
        'complaint': _complaintController.text.trim(),
        'status': 'Pending',
      }).select();

      print("DEBUG: Insert Response = $response"); // Log response

      _complaintController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Complaint Submitted!")),
      );
    } catch (e) {
      print("ERROR: $e"); // Print actual error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"), // Show error message
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepPurple,
        title:
            Text("Register Complaints", style: TextStyle(color: Colors.white)),
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
