import 'package:flutter/material.dart';
import 'package:user_app/main.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:giphy_picker/giphy_picker.dart';

class CommentsPage extends StatefulWidget {
  final int postId;
  const CommentsPage({super.key, required this.postId});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> commentList = [];
  final TextEditingController _commentController = TextEditingController();
  String? _selectedGifUrl;

  Future<void> insertComment() async {
    if (_commentController.text.isEmpty && _selectedGifUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a comment or select a GIF")),
      );
      return;
    }

    try {
      await supabase.from('tbl_comment').insert({
        'comment_content':
            _commentController.text.isNotEmpty ? _commentController.text : null,
        'post_id': widget.postId,
        'gif_url': _selectedGifUrl,
      });

      setState(() {
        _commentController.clear();
        _selectedGifUrl = null;
      });
      viewComments();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Comment posted successfully")),
      );
    } catch (e) {
      print('Error inserting comment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to post comment")),
      );
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
          commentList = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      print("Error fetching comments: $e");
    }
  }

  Future<void> _pickGif() async {
    try {
      final GiphyGif? gif = await GiphyPicker.pickGif(
        context: context,
        apiKey:
            'T3cPfidlNK0sCNPQ24LOe6D8UoIL3ZJt', // Replace with your valid GIPHY API key
        fullScreenDialog: false,
        showPreviewPage: false, // Skip the preview page
      );

      if (gif != null) {
        print('GIF selected: ${gif.images.original?.url}');
        setState(() {
          _selectedGifUrl = gif.images.original?.url;
        });
      } else {
        print('GIF picker closed without selection');
      }
    } catch (e) {
      print('Error in GIF picker: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading GIF picker")),
      );
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(radius: 30),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _commentController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: "Enter your comments here...",
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.gif, size: 30),
                        onPressed: _pickGif,
                        tooltip: 'Add GIF',
                      ),
                      ElevatedButton.icon(
                        onPressed: insertComment,
                        icon: Icon(Icons.send),
                        label: Text('Send'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                  if (_selectedGifUrl != null) ...[
                    SizedBox(height: 10),
                    Stack(
                      children: [
                        Image.network(
                          _selectedGifUrl!,
                          height: 100,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Text('Error loading GIF');
                          },
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: IconButton(
                            icon: Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _selectedGifUrl = null;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 20),
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
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (commentView['comment_content'] != null &&
                            commentView['comment_content'].isNotEmpty)
                          Text(commentView['comment_content']),
                        if (commentView['gif_url'] != null) ...[
                          SizedBox(height: 5),
                          Image.network(
                            commentView['gif_url'],
                            height: 100,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(child: CircularProgressIndicator());
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Text('Error loading GIF');
                            },
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
