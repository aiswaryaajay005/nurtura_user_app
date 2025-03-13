import 'package:flutter/material.dart';
import 'package:user_app/main.dart';

class ViewChildDetails extends StatefulWidget {
  final int chId;
  const ViewChildDetails({super.key, required this.chId});

  @override
  State<ViewChildDetails> createState() => _ViewChildDetailsState();
}

class _ViewChildDetailsState extends State<ViewChildDetails> {
  List<Map<String, dynamic>> childdetails = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchChild();
  }

  Future<void> fetchChild() async {
    try {
      String userId = supabase.auth.currentUser!.id;
      final response =
          await supabase.from('tbl_child').select().eq('id', widget.chId);
      if (response.isNotEmpty) {
        setState(() {
          childdetails = response;
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: childdetails.length,
          itemBuilder: (context, index) {
            final child = childdetails[index];
            return Card(
              shadowColor: Colors.deepPurple,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  spacing: 20,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(child['child_photo']),
                    ),
                    Row(
                      children: [
                        Text(
                          'Child Name:',
                          style: TextStyle(color: Colors.deepPurple),
                        ),
                        Text(child['child_name']),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Child Gender: ',
                          style: TextStyle(color: Colors.deepPurple),
                        ),
                        Text(child['child_gender']),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Date of Birth :',
                          style: TextStyle(color: Colors.deepPurple),
                        ),
                        Text(child['child_dob']),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Child allergy details: ',
                          style: TextStyle(color: Colors.deepPurple),
                        ),
                        Text(child['child_allergy']),
                      ],
                    ),
                    ElevatedButton(onPressed: () {}, child: Text('Edit'))
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
