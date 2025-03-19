// ignore_for_file: prefer_final_fields, avoid_print

import 'package:flutter/material.dart';
import 'package:user_app/add_child.dart';
import 'package:user_app/form_validation.dart';
import 'package:user_app/main.dart';
import 'package:user_app/user_login.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _namecontroller = TextEditingController();
  TextEditingController _emailcontroller = TextEditingController();
  TextEditingController _contactcontroller = TextEditingController();
  TextEditingController _addresscontroller = TextEditingController();
  TextEditingController _passwordcontroller = TextEditingController();
  TextEditingController _repeatcontroller = TextEditingController();
  Future<void> register() async {
    try {
      final auth = await supabase.auth.signUp(
          password: _passwordcontroller.text, email: _emailcontroller.text);
      final uid = auth.user!.id;
      if (uid.isNotEmpty || uid != "") {
        storeData(uid);
      }
    } catch (e) {
      print('Error: $e and enter same password in both fields');
    }
  }

  Future<void> storeData(final uid) async {
    try {
      if (_passwordcontroller.text == _repeatcontroller.text) {
        await supabase.from("tbl_parent").insert({
          'id': uid,
          'parent_name': _namecontroller.text,
          'parent_email': _emailcontroller.text,
          'parent_contact': _contactcontroller.text,
          'parent_password': _passwordcontroller.text,
          'parent_address': _addresscontroller.text,
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Check passwords and try again")));
      }
      _namecontroller.clear();
      _emailcontroller.clear();
      _contactcontroller.clear();
      _passwordcontroller.clear();
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddChild(),
          ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Try Again after checking all fields")));
      print("Error storing data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(30),
          shrinkWrap: true,
          children: [
            Image(image: AssetImage('assets/images/image.png')),
            SizedBox(height: 20),
            Text(
              "Sign up",
              style: TextStyle(
                  color: Colors.deepPurple,
                  fontSize: 60,
                  fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              "Welcome to Nurtura - Let's create an account",
              style: TextStyle(
                color: Colors.deepPurple[400],
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'Name',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            ),
            SizedBox(
              height: 5,
            ),
            TextFormField(
              validator: (value) => FormValidation.validateName(value),
              controller: _namecontroller,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.deepPurple),
                ),
                hintText: 'Enter your name',
                hintStyle:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                suffixIcon: Icon(
                  Icons.person,
                  color: Colors.deepPurple,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.deepPurple),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Email',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            ),
            SizedBox(
              height: 5,
            ),
            TextFormField(
              validator: (value) => FormValidation.validateEmail(value),
              controller: _emailcontroller,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.deepPurple),
                ),
                hintText: 'Enter your email',
                hintStyle:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                suffixIcon: Icon(Icons.email, color: Colors.deepPurple),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.deepPurple),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Contact Number',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            ),
            SizedBox(
              height: 5,
            ),
            TextFormField(
              validator: (value) => FormValidation.validateContact(value),
              controller: _contactcontroller,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.deepPurple),
                ),
                hintText: 'Enter your contact number',
                hintStyle:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                suffixIcon: Icon(
                  Icons.call,
                  color: Colors.deepPurple,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.deepPurple),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              maxLines: 3,
              'Address',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            ),
            SizedBox(
              height: 5,
            ),
            TextFormField(
              validator: (value) => FormValidation.validateValue(value),
              controller: _addresscontroller,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.deepPurple),
                ),
                hintText: 'Enter your address',
                hintStyle:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                suffixIcon: Icon(Icons.location_on, color: Colors.deepPurple),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.deepPurple),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              'Password',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            ),
            TextFormField(
              controller: _passwordcontroller,
              validator: (value) => FormValidation.validatePassword(value),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.deepPurple),
                ),
                hintText: 'Enter your password',
                hintStyle:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                suffixIcon: Icon(Icons.visibility, color: Colors.deepPurple),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.deepPurple),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Repeat Password',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            ),
            SizedBox(
              height: 5,
            ),
            TextFormField(
              validator: (value) => FormValidation.validateConfirmPassword(
                  value, _passwordcontroller.text),
              controller: _repeatcontroller,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.deepPurple),
                ),
                hintText: 'Repeat your password',
                hintStyle:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                suffixIcon: Icon(Icons.visibility, color: Colors.deepPurple),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.deepPurple),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  register(); // Only call register if the form is valid
                } else {
                  print("Form is not valid");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
              child: Text(
                "Create Account",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserLogin(),
                      ));
                },
                child: Text(
                  'Already have an account? Log in',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w500),
                ))
          ],
        ),
      ),
    );
  }
}
