import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_app/main.dart';

class EditPassword extends StatefulWidget {
  const EditPassword({super.key});

  @override
  State<EditPassword> createState() => _EditPasswordState();
}

class _EditPasswordState extends State<EditPassword> {
  TextEditingController _oldcontroller = TextEditingController();
  TextEditingController _newcontroller = TextEditingController();
  TextEditingController _recontroller = TextEditingController();
  Future<void> changePassword() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("User is not logged in.")));
      return;
    }

    if (_newcontroller.text != _recontroller.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Passwords do not match.")));
      return;
    }

    if (_newcontroller.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Password cannot be empty.")));
      return;
    }

    try {
      final UserResponse res = await supabase.auth.updateUser(
        UserAttributes(
          password: _newcontroller.text,
        ),
      );
      final userResponse = await supabase.from('tbl_parent').update({
        'parent_password': _newcontroller.text,
      }).eq('id', user.id);
      if (res.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Password changed successfully!")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to change password.")));
      }
      _newcontroller.clear();
      _oldcontroller.clear();
      _recontroller.clear();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.shade300,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Form(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Edit Password',
                    style: TextStyle(color: Colors.deepPurple, fontSize: 30)),
                SizedBox(height: 20),
                Text(
                  'Current Password',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: _oldcontroller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: 'Enter Current Password',
                    prefixIcon: Icon(Icons.person, color: Colors.deepPurple),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'New Password',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: _newcontroller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: 'Enter New Password',
                    prefixIcon: Icon(Icons.person, color: Colors.deepPurple),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Repeat New Password',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: _recontroller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: 'Repeat the new Password',
                    prefixIcon: Icon(Icons.person, color: Colors.deepPurple),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple[300],
                  ),
                  onPressed: () {
                    changePassword();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'Change Password',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ])),
        ),
      ),
    );
  }
}
