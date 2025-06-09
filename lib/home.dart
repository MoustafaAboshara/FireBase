import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'posts.dart'; // 👈 make sure this import is here

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final User user;
  final CollectionReference posts =
      FirebaseFirestore.instance.collection("posts");

  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil(
        "login", (Route<dynamic> route) => false);
  }

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
  }

  void showCreatePostDialog() {
    _titleController.clear();
    _bodyController.clear();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("New Post"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: _bodyController,
                decoration: InputDecoration(labelText: "Body"),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel")),
          ElevatedButton(
              onPressed: () async {
                if (_titleController.text.isEmpty ||
                    _bodyController.text.isEmpty) return;

                await posts.add({
                  "title": _titleController.text,
                  "body": _bodyController.text,
                  "createdAt": Timestamp.now(),
                  "author": user.email,
                });
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Post created successfully")),
                );
              },
              child: Text("Post")),
        ],
      ),
    );
  }

  void showEditPostDialog(DocumentSnapshot post) {
    _titleController.text = post.get("title");
    _bodyController.text = post.get("body");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Edit Post"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: _bodyController,
                decoration: InputDecoration(labelText: "Body"),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel")),
          ElevatedButton(
              onPressed: () async {
                if (_titleController.text.isEmpty ||
                    _bodyController.text.isEmpty) return;

                await posts.doc(post.id).update({
                  "title": _titleController.text,
                  "body": _bodyController.text,
                });
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Post updated successfully")),
                );
              },
              child: Text("Save")),
        ],
      ),
    );
  }

  void deletePost(String postId) async {
    await posts.doc(postId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Post deleted")),
    );
  }

  String formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('MMM d, y – hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome ${user.email}"),
        actions: [
          IconButton(
            onPressed: logout,
            icon: Icon(Icons.logout),
            tooltip: "Logout",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: posts.orderBy("createdAt", descending: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Center(child: CircularProgressIndicator());

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
              return Center(child: Text("No posts found."));

            return ListView(
              children: snapshot.data!.docs.map((item) {
                String title = item.get("title") ?? "Untitled";
                String body = item.get("body") ?? "No content";
                String author = item.get("author") ?? "Unknown";
                Timestamp createdAt = item.get("createdAt") ?? Timestamp.now();

                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            PostDetailsScreen(post: item),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Divider(height: 20),
                          Text(
                            body,
                            style: TextStyle(fontSize: 15),
                          ),
                          SizedBox(height: 12),
                          Text(
                            "By $author",
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[600]),
                          ),
                          Text(
                            formatTimestamp(createdAt),
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[500]),
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                tooltip: "Edit",
                                onPressed: () => showEditPostDialog(item),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                tooltip: "Delete",
                                onPressed: () => deletePost(item.id),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showCreatePostDialog,
        child: Icon(Icons.add),
        tooltip: "Create New Post",
      ),
    );
  }
}
