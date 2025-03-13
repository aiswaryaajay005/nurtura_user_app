import 'package:flutter/material.dart';
import 'package:user_app/comments_page.dart';
import 'package:user_app/main.dart';

class ViewPost extends StatefulWidget {
  const ViewPost({super.key});

  @override
  State<ViewPost> createState() => _ViewPostState();
}

class _ViewPostState extends State<ViewPost> {
  List<Map<String, dynamic>> post = [];
  bool isLoading = true;
  Future<void> fetchPost() async {
    try {
      final response = await supabase.from('tbl_post').select();

      if (response.isNotEmpty) {
        setState(() {
          post = response;
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
    fetchPost();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepPurple[300],
        title: Text('View Post',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        actions: [
          Text(
            "Nurtura",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'AmsterdamThree',
              fontSize: 40,
            ),
          ),
          SizedBox(width: 10),
          CircleAvatar(
            backgroundImage: AssetImage('assets/images/nurtura.png'),
          ),
          SizedBox(width: 20),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator()) // Show loader while fetching
          : post.isEmpty
              ? Center(child: Text("No posts available"))
              : GridView.builder(
                  padding: EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: 0.5,
                  ),
                  itemCount: post.length,
                  itemBuilder: (context, index) {
                    final postview = post[index];
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
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Expanded(
                                child: Image.network(
                                  postview['post_file'],
                                  height: 500,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.broken_image,
                                        size: 100, color: Colors.grey);
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Post Name:",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            Text(
                              postview['post_title'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Posted Time:",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            Text(
                              postview['created_at'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      Icon(
                                        Icons.thumb_up_off_alt,
                                        color: Colors.deepPurple,
                                      ),
                                      Text('Like')
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => CommentsPage(
                                              postId: postview['id'],
                                            ),
                                          ));
                                    },
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.add_comment_sharp,
                                          color: Colors.deepPurple,
                                        ),
                                        Text('Comment')
                                      ],
                                    ),
                                  )
                                ])
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
