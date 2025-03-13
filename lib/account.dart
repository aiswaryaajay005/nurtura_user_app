import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
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
  String imageUrl = "";

  File? _image;
  final ImagePicker _picker = ImagePicker();
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    print(pickedFile);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _mediaupload();
    }
  }

  Future<void> _mediaupload() async {
    try {
      String userId = supabase.auth.currentUser!.id;
      String? photoUrl;
      if (_image != null) {
        photoUrl = await _uploadImage(_image!, userId);
      }
      if (photoUrl!.isNotEmpty) {
        await supabase.from("tbl_parent").update({
          'parent_photo': photoUrl,
        }).eq('id', userId);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Photo Added")));
      } else {
        print("Photo url is empty");
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Please try Again")));
      }
    } catch (e) {
      print("Error:$e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error:$e")));
    }
  }

  Future<String?> _uploadImage(File image, String userId) async {
    try {
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('dd-MM-yyyy-HH-mm-ss').format(now);
      final fileName = '$userId-$formattedDate';

      await supabase.storage.from('parent_profile').upload(fileName, image);

      // Get public URL of the uploaded image
      final imageUrl =
          supabase.storage.from('parent_profile').getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      print('Image upload failed: $e');
      return null;
    }
  }

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
          imageUrl = response['parent_photo'] ?? "";
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
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color.fromARGB(97, 123, 56, 56),
                      backgroundImage: _image != null
                          ? FileImage(_image!)
                          : NetworkImage(imageUrl),
                    ),
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
