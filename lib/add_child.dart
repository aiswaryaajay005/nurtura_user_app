import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:user_app/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:user_app/parent_dashboard.dart';
import 'package:user_app/user_login.dart';

class AddChild extends StatefulWidget {
  const AddChild({super.key});

  @override
  State<AddChild> createState() => _AddChildState();
}

class _AddChildState extends State<AddChild> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final fileName = 'child_${DateTime.now().millisecondsSinceEpoch}';
      print("Uploading image: $fileName");

      await supabase.storage.from('child_profile').upload(fileName, image);
      print("Image uploaded successfully");

      // Get public URL of the uploaded image
      final imageUrl =
          supabase.storage.from('child_profile').getPublicUrl(fileName);
      print("Image URL: $imageUrl");

      return imageUrl;
    } catch (e) {
      print('Image upload failed: $e');
      return null;
    }
  }

  TextEditingController _datecontroller = TextEditingController();
  TextEditingController _childnamecontroller = TextEditingController();
  TextEditingController _allergycontroller = TextEditingController();

  String selectedGender = '';
  Future<void> insertData() async {
    try {
      if (_image != null) {
        String userId = supabase.auth.currentUser!.id;
        String? photoUrl = await _uploadImage(_image!);
        await supabase.from('tbl_child').insert({
          'child_name': _childnamecontroller.text,
          'child_dob': _datecontroller.text.toString(),
          'child_allergy': _allergycontroller.text,
          'child_gender': selectedGender,
          'parent_id': userId,
          'child_photo': photoUrl,
        });
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserLogin(),
            ));
        _childnamecontroller.clear();
        _datecontroller.clear();
        _allergycontroller.clear();
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Select a photo first")));
      }
    } catch (e) {
      print("Error inserting event: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to insert data. Please try again.$e"),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Nurtura",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'AmsterdamThree',
            fontSize: 40,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Add Child Details',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: DottedBorder(
                        color: Colors.deepPurple, // Border color
                        strokeWidth: 2, // Border width
                        borderType: BorderType.RRect, // Rounded rectangle
                        radius: Radius.circular(12), // Border radius
                        dashPattern: [6, 3], // Dash and gap length
                        child: Card(
                          shadowColor: Colors.deepPurple,
                          child: Column(
                            children: [
                              SizedBox(width: 300),
                              SizedBox(height: 10),
                              Text(
                                'Child Profile',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.deepPurple[200],
                                backgroundImage:
                                    _image != null ? FileImage(_image!) : null,
                                child: _image == null
                                    ? const Icon(Icons.camera_alt,
                                        color: Colors.white, size: 40)
                                    : null,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Click here to upload',
                                  style: TextStyle(
                                      color:
                                          const Color.fromRGBO(103, 58, 183, 1),
                                      fontFamily: 'Lato',
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Child Name
                  const Text(
                    'Child Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _childnamecontroller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'Enter child’s name',
                      prefixIcon: Icon(Icons.person, color: Colors.deepPurple),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Gender Selection
                  const Text(
                    "Gender",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Text("Boy"),
                      Expanded(
                        child: Radio(
                          value: "Boy",
                          groupValue: selectedGender,
                          onChanged: (e) {
                            setState(() {
                              selectedGender = e!;
                            });
                          },
                        ),
                      ),
                      Text("Girl"),
                      Expanded(
                        child: Radio(
                          value: "Girl",
                          groupValue: selectedGender,
                          onChanged: (e) {
                            setState(() {
                              selectedGender = e!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Date of Birth
                  const Text(
                    'Date of Birth',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                      readOnly: true,
                      controller: _datecontroller,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'Select DOB',
                        prefixIcon: Icon(Icons.calendar_today,
                            color: Colors.deepPurple),
                      ),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          String formattedDate =
                              "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                          setState(() {
                            _datecontroller.text = formattedDate;
                          });
                        }
                      }),
                  const SizedBox(height: 20),

                  // Allergy Details
                  const Text(
                    'Child Allergy Details',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _allergycontroller,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'Mention allergies if any',
                      prefixIcon:
                          Icon(Icons.sick_outlined, color: Colors.deepPurple),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 12),
                      ),
                      onPressed: () {
                        insertData();
                      },
                      child: const Text(
                        "Save Child Details",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
