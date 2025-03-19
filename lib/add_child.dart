import 'dart:developer';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:user_app/form_validation.dart';
import 'package:user_app/main.dart';
import 'package:file_picker/file_picker.dart';
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

  File? selectedFile; // Holds the selected file

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
        _proofcontroller.text = result.files.single.name; // Show file name
      });
    }
  }

  Future<String?> uploadFile() async {
    if (selectedFile == null) {
      return "";
    }

    try {
      final fileExt = selectedFile!.path.split('.').last;
      final fileName =
          'proofs/${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      // Upload file to Supabase Storage
      await supabase.storage
          .from('child_profile')
          .upload(fileName, selectedFile!);

      // Get the public URL
      final fileUrl =
          supabase.storage.from('child_profile').getPublicUrl(fileName);

      // Save the URL to the database if needed
      print("File Uploaded: $fileUrl");

      return fileUrl;
    } catch (e) {
      print("Upload Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("File upload failed!")),
      );
      return "";
    }
  }

  Future<void> checkData() async {
    String userId = supabase.auth.currentUser!.id;
    try {
      final response = await supabase
          .from('tbl_child')
          .select()
          .eq('parent_id', userId)
          .maybeSingle(); // No need for `.limit(1)`

      if (response != null) {
        setState(() {
          _motherNameController.text = response['mother_name'] ?? '';
          _fatherNameController.text = response['father_name'] ?? '';
          _altPhoneController.text = response['alt_phone'] ?? '';
        });
      } else {
        log("No child data found for this user.");
      }
    } catch (e) {
      log("Error fetching child data: $e");
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

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _datecontroller = TextEditingController();
  final TextEditingController _childnamecontroller = TextEditingController();
  final TextEditingController _allergycontroller = TextEditingController();
  final TextEditingController _proofcontroller = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _motherNameController = TextEditingController();
  final TextEditingController _altPhoneController = TextEditingController();
  String selectedGender = '';
  Future<void> insertData() async {
    try {
      if (_image != null) {
        String userId = supabase.auth.currentUser!.id;
        String? photoUrl = await _uploadImage(_image!);
        String? proofUrl = await uploadFile();

        DateTime dob = DateTime.parse(_datecontroller.text);
        DateTime today = DateTime.now();

        int age = today.year - dob.year;

        if (today.month < dob.month ||
            (today.month == dob.month && today.day < dob.day)) {
          age--;
        }

        await supabase.from('tbl_child').insert({
          'child_name': _childnamecontroller.text,
          'child_dob': _datecontroller.text,
          'child_age': age,
          'child_allergy': _allergycontroller.text,
          'child_gender': selectedGender,
          'parent_id': userId,
          'child_photo': photoUrl,
          'child_docs': proofUrl,
          'father_name': _fatherNameController.text,
          'mother_name': _motherNameController.text,
          'alt_phone': _altPhoneController.text,
        });

        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserLogin(),
            ));

        _childnamecontroller.clear();
        _datecontroller.clear();
        _allergycontroller.clear();
        _fatherNameController.clear();
        _motherNameController.clear();
        _altPhoneController.clear();
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Select a photo first")));
      }
    } catch (e) {
      print("Error inserting event: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to insert data. Please try again."),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    checkData();
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
              child: Form(
                key: _formKey,
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
                          color: Colors.deepPurple,
                          strokeWidth: 2,
                          borderType: BorderType.RRect,
                          radius: Radius.circular(12),
                          dashPattern: [6, 3],
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
                                  backgroundImage: _image != null
                                      ? FileImage(_image!)
                                      : null,
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
                                        color: const Color.fromRGBO(
                                            103, 58, 183, 1),
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
                      validator: (value) => FormValidation.validateName(value),
                      controller: _childnamecontroller,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'Enter child’s name',
                        prefixIcon:
                            Icon(Icons.person, color: Colors.deepPurple),
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
                        labelText: 'Date of Birth',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onTap: () async {
                        DateTime now = DateTime.now();
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: now.subtract(Duration(days: 365)),
                          firstDate: now.subtract(Duration(days: 3 * 365)),
                          lastDate: now.subtract(Duration(days: 365)),
                        );
                        if (pickedDate != null) {
                          String formattedDate =
                              "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                          setState(() {
                            _datecontroller.text = formattedDate;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    // Allergy Details
                    const Text(
                      'Child Allergy Details',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      validator: (value) => FormValidation.validateValue(value),
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
                    TextFormField(
                      validator: (value) => FormValidation.validateName(value),
                      controller: _fatherNameController,
                      decoration: InputDecoration(
                        labelText: 'Father\'s Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      validator: (value) => FormValidation.validateName(value),
                      controller: _motherNameController,
                      decoration: InputDecoration(
                        labelText: 'Mother\'s Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      validator: (value) =>
                          FormValidation.validateContact(value),
                      controller: _altPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Alternative Phone Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    const Text(
                      'Documents',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    GestureDetector(
                      onTap: pickFile,
                      child: AbsorbPointer(
                        child: TextFormField(
                          readOnly: true,
                          controller: _proofcontroller,
                          maxLines: 3,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            hintText:
                                'Click here to upload childs birth certificate',
                            prefixIcon: Icon(Icons.upload_file,
                                color: Colors.deepPurple),
                          ),
                        ),
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
                          if (_formKey.currentState!.validate()) {
                            insertData();
                          }
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
      ),
    );
  }
}
