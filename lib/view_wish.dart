import 'package:flutter/material.dart';
import 'package:user_app/main.dart';

class ViewWish extends StatefulWidget {
  final int childId;
  const ViewWish({super.key, required this.childId});

  @override
  State<ViewWish> createState() => _ViewWishState();
}

class _ViewWishState extends State<ViewWish> {
  List<Map<String, dynamic>> wishes = [];
  Future<void> viewWishes() async {
    try {
      final response = await supabase
          .from('tbl_wish')
          .select("*,tbl_parent(id, parent_name, parent_photo)")
          .eq('child_id', widget.childId);
      if (response.isNotEmpty) {
        setState(() {
          wishes = response;
        });
      }
    } catch (e) {
      print("Error $e");
    }
  }

  @override
  void initState() {
    super.initState();
    viewWishes(); // Call the function to fetch wishes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
      ),
      body: wishes.isEmpty
          ? Center(
              child: Text("No wishes"),
            )
          : ListView.builder(
              shrinkWrap: true,
              itemCount: wishes.length,
              itemBuilder: (context, index) {
                final wishList = wishes[index];

                return ListTile(
                  leading: CircleAvatar(
                      backgroundImage: AssetImage("assets/images/flowers.png")),
                  title: Text(wishList['tbl_parent']?['parent_name'] ??
                      "Unknown Parent"),
                  subtitle: Text(wishList['wish_content']),
                );
              },
            ),
    );
  }
}
