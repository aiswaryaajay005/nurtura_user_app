import 'package:flutter/material.dart';
import 'package:user_app/main.dart';
import 'package:user_app/user_login.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String username = "";
  String usercontact = "";
  String useremail = "";
  String userpassword = "";
  String useraddress = "";
  bool isLoading = false;
  Future<void> fetchUser() async {
    try {
      String userId = supabase.auth.currentUser!.id;
      final response =
          await supabase.from('tbl_parent').select().eq('id', userId).single();
      if (response.isNotEmpty) {
        setState(() {
          username = response['parent_name'];
          usercontact = response['parent_contact'];
          useremail = response['parent_email'];
          userpassword = response['parent_password'];
          useraddress = response['parent_address'];
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[300],
        title: Center(
            child: Text(
          'My profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        )),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                SizedBox(height: 20),
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    foregroundImage: AssetImage('assets/images/flower.png'),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                    child: Text(
                  username,
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Colors.deepPurple[300]),
                )),
                SizedBox(height: 20),
                ListView(
                  shrinkWrap: true,
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.email_outlined,
                        color: Colors.deepPurple[300],
                      ), // Leading icon for the username
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email'),
                          Text(useremail, style: TextStyle(color: Colors.grey)),
                          Divider(
                              thickness: 1,
                              color: Colors.grey), // Underline below the text
                        ],
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 50), // Removes extra padding
                    ),
                    ListTile(
                      leading: Icon(Icons.contact_phone_outlined,
                          color: Colors.deepPurple[
                              300]), // Leading icon for the username
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Contact'),
                          Text(usercontact,
                              style: TextStyle(color: Colors.grey)),
                          Divider(
                              thickness: 1,
                              color: Colors.grey), // Underline below the text
                        ],
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 50), // Removes extra padding
                    ),
                    ListTile(
                      leading: Icon(Icons.home_outlined,
                          color: Colors.deepPurple[
                              300]), // Leading icon for the username
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Address'),
                          Text(useraddress,
                              style: TextStyle(color: Colors.grey)),
                          Divider(
                              thickness: 1,
                              color: Colors.grey), // Underline below the text
                        ],
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 50), // Removes extra padding
                    ),
                    ListTile(
                      leading: Icon(Icons.password_outlined,
                          color: Colors.deepPurple[
                              300]), // Leading icon for the username
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Password'),
                          Text(userpassword,
                              style: TextStyle(color: Colors.grey)),
                          Divider(
                              thickness: 1,
                              color: Colors.grey), // Underline below the text
                        ],
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 50), // Removes extra padding
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 100, right: 100, top: 30),
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple[300],
                          padding:
                              EdgeInsets.symmetric(vertical: 15, horizontal: 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          "Edit Profile",
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 100, right: 100, top: 30),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await supabase.auth.signOut();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserLogin(),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple[300],
                          padding:
                              EdgeInsets.symmetric(vertical: 15, horizontal: 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                        ),
                        icon: Icon(Icons.logout_sharp),
                        label: Text(
                          "Log out",
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
    );
  }
}
