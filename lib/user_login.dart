import 'package:flutter/material.dart';
import 'package:user_app/home_ui.dart';
import 'package:user_app/main.dart';
import 'package:user_app/registration.dart';

class UserLogin extends StatefulWidget {
  const UserLogin({super.key});

  @override
  State<UserLogin> createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  TextEditingController _emailcontroller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  TextEditingController _passwordcontroller = TextEditingController();

  Future<void> login() async {
    try {
      await supabase.auth.signInWithPassword(
          password: _passwordcontroller.text, email: _emailcontroller.text);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeUi(),
          ));
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Enter valid data"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(top: 100, right: 30, left: 30),
        children: [
          Image(
              image: AssetImage('assets/images/nurtura.png'),
              height: 200,
              width: 200),
          SizedBox(
            height: 20,
          ),
          Column(
            children: [
              Text(
                "Login to your ",
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 40,
                    color: Colors.deepPurple[400]),
                textAlign: TextAlign.center,
              ),
              Text(
                "account",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 40,
                  color: Colors.deepPurple[400],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "Hello Welcome back to your account",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
          ),
          SizedBox(
            height: 15,
          ),
          Form(
            key: _formKey, // Assign form key
            child: ListView(
              shrinkWrap: true,
              children: [
                TextFormField(
                  controller: _emailcontroller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'E-mail',
                    labelStyle: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w500),
                    hintText: 'example@gmail.com',
                    suffixIcon: Icon(Icons.email, color: Colors.deepPurple),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.deepPurple)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30),
                TextFormField(
                  controller: _passwordcontroller,
                  obscureText: true, // Hides password input
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    labelStyle: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w500),
                    hintText: 'Your password',
                    suffixIcon:
                        Icon(Icons.visibility, color: Colors.deepPurple),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.deepPurple)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple[300],
                  ),
                  onPressed: login,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'Login',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegisterForm(),
                      ),
                    );
                  },
                  child: Text(
                    'Create new account',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w500),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
