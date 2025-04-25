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
  Map<int, int> likesCount = {};
  Set<int> userLikedPosts = {};
  bool isLoading = true;

  Future<void> fetchPost() async {
    try {
      final response = await supabase.from('tbl_post').select();
      if (response.isNotEmpty) {
        setState(() {
          post = response;
        });
      }

      // Fetch likes after fetching posts
      await fetchLikes();
    } catch (e) {
      print("Error fetching posts: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchLikes() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        print("User not logged in");
        return;
      }
      final userId = user.id; // Use UUID from auth

      final likesResponse = await supabase.from('tbl_like').select();
      print("Likes response: $likesResponse"); // Debug

      Map<int, int> likeCounts = {};
      Set<int> likedPosts = {};

      for (var like in likesResponse) {
        int postId = like['post_id'];
        likeCounts[postId] = (likeCounts[postId] ?? 0) + 1;
        if (like['user_id'] == userId) {
          likedPosts.add(postId);
        }
      }

      setState(() {
        likesCount = likeCounts;
        userLikedPosts = likedPosts;
        print("User liked posts: $userLikedPosts"); // Debug
      });
    } catch (e) {
      print("Error fetching likes: $e");
    }
  }

  Future<void> toggleLike(int postId) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        print("User not logged in");
        return;
      }

      final userId = user.id;

      final existingLike = await supabase
          .from('tbl_like')
          .select()
          .eq('user_id', userId)
          .eq('post_id', postId)
          .maybeSingle();

      if (existingLike != null) {
        await supabase
            .from('tbl_like')
            .delete()
            .match({'user_id': userId, 'post_id': postId});

        setState(() {
          userLikedPosts.remove(postId);
          likesCount[postId] = (likesCount[postId] ?? 1) - 1;
        });
      } else {
        await supabase.from('tbl_like').insert({
          'user_id': userId,
          'post_id': postId,
          'created_at': DateTime.now().toIso8601String(),
        });

        setState(() {
          userLikedPosts.add(postId);
          likesCount[postId] = (likesCount[postId] ?? 0) + 1;
        });
      }
    } catch (e) {
      print("Error toggling like: $e");
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
        backgroundColor: Colors.deepPurple,
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
          ? Center(child: CircularProgressIndicator())
          : post.isEmpty
              ? Center(child: Text("No posts available"))
              : ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: post.length,
                  itemBuilder: (context, index) {
                    final postview = post[index];
                    int postId = postview['id'];

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
                              child: Image.network(
                                postview['post_file'],
                                height: 300,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.broken_image,
                                      size: 100, color: Colors.grey);
                                },
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
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  onTap: () => toggleLike(postId),
                                  child: Row(
                                    children: [
                                      Icon(
                                        userLikedPosts.contains(postId)
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: userLikedPosts.contains(postId)
                                            ? Colors.red
                                            : Colors.deepPurple,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        likesCount[postId]?.toString() ?? "0",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CommentsPage(
                                            postId: postId,
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
                              ],
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
