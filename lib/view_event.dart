import 'package:flutter/material.dart';
import 'package:user_app/main.dart';

class ViewEvent extends StatefulWidget {
  const ViewEvent({super.key});

  @override
  State<ViewEvent> createState() => _ViewEventState();
}

class _ViewEventState extends State<ViewEvent> {
  List<Map<String, dynamic>> viewevent = [];
  bool isLoading = true;
  Future<void> fetchEvent() async {
    try {
      final response = await supabase.from('tbl_event').select();

      if (response.isNotEmpty) {
        setState(() {
          viewevent = response;
        });
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        isLoading = false; // Stop loading after fetching data
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchEvent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'View Events',
            style: TextStyle(color: Colors.deepPurple),
          ),
        ),
        body: isLoading
            ? Center(
                child:
                    CircularProgressIndicator()) // Show loader while fetching
            : viewevent.isEmpty
                ? Center(child: Text("No events"))
                : Expanded(
                    child: GridView.builder(
                    padding: EdgeInsets.all(10),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: viewevent.length,
                    itemBuilder: (context, index) {
                      final event = viewevent[index];
                      return Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10),
                              Text(
                                "Event Name:",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              Text(
                                event['event_name'],
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Event Date:",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              Text(
                                event['event_date'],
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Event Details:",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              Text(
                                event['event_details'],
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )));
  }
}
