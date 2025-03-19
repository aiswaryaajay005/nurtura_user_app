import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_app/main.dart';

class ViewEvent extends StatefulWidget {
  final int childId;
  const ViewEvent({super.key, required this.childId});

  @override
  State<ViewEvent> createState() => _ViewEventState();
}

class _ViewEventState extends State<ViewEvent> {
  String? eventStatus;
  Color? statusColor;
  List<Map<String, dynamic>> viewevent = [];
  Map<int, int> eventResponses = {}; // Store responses for events
  bool isLoading = true;

  Future<void> fetchEvent() async {
    try {
      final response = await supabase.from('tbl_event').select();
      if (response.isNotEmpty) {
        setState(() {
          viewevent = response;
        });
      }

      // Fetch existing participation responses
      await fetchResponses();
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchResponses() async {
    try {
      final response = await supabase
          .from('tbl_participate')
          .select()
          .eq('child_id', widget.childId);

      if (response.isNotEmpty) {
        Map<int, int> fetchedResponses = {};
        for (var entry in response) {
          fetchedResponses[entry['event_id']] = entry['participate_status'];
        }

        setState(() {
          eventResponses = fetchedResponses;
        });
      }
    } catch (e) {
      print("Error fetching responses: $e");
    }
  }

  Future<void> respondToEvent(int eid, int status) async {
    try {
      await supabase.from('tbl_participate').upsert({
        'participate_status': status,
        'child_id': widget.childId,
        'event_id': eid
      });

      setState(() {
        eventResponses[eid] = status;
      });
    } catch (e) {
      print("Error inserting response: $e");
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
          backgroundColor: Colors.deepPurple,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            'View Events',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : viewevent.isEmpty
                ? Center(child: Text("No events"))
                : GridView.builder(
                    padding: EdgeInsets.all(10),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.4,
                    ),
                    itemCount: viewevent.length,
                    itemBuilder: (context, index) {
                      final event = viewevent[index];
                      final eventId = event['id'];

                      // Convert event date to DateTime format
                      DateTime eventDate = DateTime.parse(event['event_date']);
                      DateTime today = DateTime.now();

                      String eventStatus;
                      Color statusColor;

                      if (eventDate.isAfter(today)) {
                        eventStatus = "Happening Soon";
                        statusColor = Colors.blue;
                      } else if (eventDate.year == today.year &&
                          eventDate.month == today.month &&
                          eventDate.day == today.day) {
                        eventStatus = "Happening Now";
                        statusColor = Colors.orange;
                      } else {
                        eventStatus = "Completed";
                        statusColor = Colors.grey;
                      }

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

                              Center(
                                child: Text(
                                  event['event_name'],
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
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
                                DateFormat('yyyy-MM-dd').format(eventDate),
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              SizedBox(height: 10),
                              SizedBox(height: 10),
                              Text(
                                "Event Time:",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              Text(
                                event['event_time'] ?? "10:00:00",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Event Venue:",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              Text(
                                event['event_venue'] ?? "Common Hall",
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
                                maxLines: 2,
                              ),
                              SizedBox(height: 15),
                              // Event Status
                              Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  eventStatus,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 15),
                              eventResponses.containsKey(eventId)
                                  ? Text(
                                      eventResponses[eventId] == 1
                                          ? "✅ Participating!"
                                          : "❌ Maybe next time!",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: eventResponses[eventId] == 1
                                              ? Colors.white
                                              : Colors.deepPurple),
                                    )
                                  : Column(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () =>
                                              respondToEvent(eventId, 1),
                                          child: Text(
                                            'Will be there',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.deepPurple),
                                        ),
                                        SizedBox(height: 10),
                                        ElevatedButton(
                                          onPressed: () =>
                                              respondToEvent(eventId, 0),
                                          child: Text('Maybe Next Time'),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white),
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                        ),
                      );
                    }));
  }
}
