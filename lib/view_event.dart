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
  List<Map<String, dynamic>> viewevent = [];
  Map<int, int> eventResponses = {};
  bool isLoading = true;

  Future<void> fetchEvent() async {
    try {
      final response = await supabase.from('tbl_event').select();
      if (response.isNotEmpty) {
        setState(() {
          viewevent = response;
        });
      }
      await fetchResponses();
    } catch (e) {
      print("Error fetching events: $e");
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
        'event_id': eid,
      });
      setState(() {
        eventResponses[eid] = status;
      });
    } catch (e) {
      print("Error inserting response: $e");
    }
  }

  void showEventDetails(BuildContext context, Map<String, dynamic> event) {
    final eventDate = DateTime.parse(event['event_date']);
    final eventStatus = eventDate.isAfter(DateTime.now())
        ? "Happening Soon"
        : eventDate.year == DateTime.now().year &&
                eventDate.month == DateTime.now().month &&
                eventDate.day == DateTime.now().day
            ? "Happening Now"
            : "Completed";
    final statusColor = eventDate.isAfter(DateTime.now())
        ? Colors.blue
        : eventDate.year == DateTime.now().year &&
                eventDate.month == DateTime.now().month &&
                eventDate.day == DateTime.now().day
            ? Colors.orange
            : Colors.grey;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          event['event_name'],
          style:
              TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Date: ${DateFormat('yyyy-MM-dd').format(eventDate)}"),
              SizedBox(height: 8),
              Text("Time: ${event['event_time'] ?? '10:00:00'}"),
              SizedBox(height: 8),
              Text("Venue: ${event['event_venue'] ?? 'Common Hall'}"),
              SizedBox(height: 8),
              Text("Details: ${event['event_details']}"),
              SizedBox(height: 8),
              if (event['event_notice'] != null &&
                  event['event_notice'].isNotEmpty) ...[
                Text("Notice Image:"),
                SizedBox(height: 8),
                Container(
                  constraints: BoxConstraints(
                    maxHeight: 200,
                    maxWidth: double.infinity,
                  ),
                  child: Image.network(
                    event['event_notice'],
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.broken_image,
                      size: 100,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  eventStatus,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      ),
    );
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
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: viewevent.length,
                  itemBuilder: (context, index) {
                    final event = viewevent[index];
                    final eventId = event['id'];
                    final eventDate = DateTime.parse(event['event_date']);
                    final eventStatus = eventDate.isAfter(DateTime.now())
                        ? "Happening Soon"
                        : eventDate.year == DateTime.now().year &&
                                eventDate.month == DateTime.now().month &&
                                eventDate.day == DateTime.now().day
                            ? "Happening Now"
                            : "Completed";
                    final statusColor = eventDate.isAfter(DateTime.now())
                        ? Colors.blue
                        : eventDate.year == DateTime.now().year &&
                                eventDate.month == DateTime.now().month &&
                                eventDate.day == DateTime.now().day
                            ? Colors.orange
                            : Colors.grey;

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
                            Center(
                              child: Text(
                                event['event_name'],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              DateFormat('yyyy-MM-dd').format(eventDate),
                              style: TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              decoration: BoxDecoration(
                                color: statusColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                eventStatus,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => showEventDetails(context, event),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                minimumSize: Size(double.infinity, 32),
                              ),
                              child: Text(
                                "View Details",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                            SizedBox(height: 8),
                            Expanded(
                              child: Center(
                                child: eventResponses.containsKey(eventId)
                                    ? Text(
                                        eventResponses[eventId] == 1
                                            ? "✅ Participating!"
                                            : "❌ Maybe next time!",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: eventResponses[eventId] == 1
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                        textAlign: TextAlign.center,
                                      )
                                    : eventStatus == "Completed"
                                        ? Text(
                                            "Event completed",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                            ),
                                            textAlign: TextAlign.center,
                                          )
                                        : Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () =>
                                                    respondToEvent(eventId, 1),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  minimumSize:
                                                      Size(double.infinity, 32),
                                                ),
                                                child: Text(
                                                  "Will be there",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              ElevatedButton(
                                                onPressed: () =>
                                                    respondToEvent(eventId, 0),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  minimumSize:
                                                      Size(double.infinity, 32),
                                                ),
                                                child: Text(
                                                  "Maybe Next Time",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
