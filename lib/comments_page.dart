import 'package:flutter/material.dart';
import 'package:user_app/form_validation.dart';
import 'package:user_app/main.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:timeago/timeago.dart' as timeago;

class CommentsPage extends StatefulWidget {
  final int postId;
  const CommentsPage({super.key, required this.postId});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> commentList = [];
  TextEditingController _commentController = TextEditingController();

  Future<void> insertComment() async {
    try {
      await supabase.from('tbl_comment').insert({
        'comment_content': _commentController.text,
        'post_id': widget.postId,
      });
      _commentController.clear();
      viewComments();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Stored Successfully")));
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> viewComments() async {
    try {
      final response = await supabase
          .from('tbl_comment')
          .select("*,tbl_parent(*)")
          .eq('post_id', widget.postId);

      if (response.isNotEmpty) {
        setState(() {
          commentList = response;
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    viewComments();
  }

  String formatDate(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return "Unknown date";
    try {
      DateTime dateTime = DateTime.parse(timestamp);
      DateTime now = DateTime.now();
      Duration difference = now.difference(dateTime);

      if (difference.inDays == 0) {
        return timeago.format(dateTime, locale: 'en');
      } else if (difference.inDays == 1) {
        return "Yesterday";
      } else {
        return DateFormat("dd MMM yyyy").format(dateTime);
      }
    } catch (e) {
      return "Invalid date";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title: Text('Comments'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Form(
                  key: _formKey,
                  child: Row(
                    children: [
                      CircleAvatar(radius: 30),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                            validator: (value) =>
                                FormValidation.validateValue(value),
                            controller: _commentController,
                            maxLines: 3,
                            decoration: InputDecoration(
                                hintText: "Enter your comments here...",
                                suffixIcon: GestureDetector(
                                    onTap: () {
                                      if (_formKey.currentState!.validate()) {
                                        insertComment();
                                      }
                                    },
                                    child: Icon(Icons.send)),
                                border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.grey)))),
                      ),
                    ],
                  )),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: commentList.length,
                  itemBuilder: (context, index) {
                    final commentView = commentList[index];
                    return ListTile(
                      leading: CircleAvatar(),
                      title: Row(
                        children: [
                          Text(commentView['tbl_parent']?['parent_name'] ?? ""),
                          SizedBox(width: 20),
                          Text(formatDate(commentView['created_at'])),
                        ],
                      ),
                      subtitle: Text(commentView['comment_content'] ?? ""),
                    );
                  },
                ),
              )
            ],
          ),
        ));
  }
}
