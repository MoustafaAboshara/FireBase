import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PostDetailsScreen extends StatefulWidget {
  final DocumentSnapshot post;

  const PostDetailsScreen({super.key, required this.post});

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  void showEditDialog() {
    _titleController.text = widget.post.get("title");
    _bodyController.text = widget.post.get("body");

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
              onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection("posts")
                    .doc(widget.post.id)
                    .update({
                  "title": _titleController.text,
                  "body": _bodyController.text,
                });
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Post updated")),
                );
                setState(() {}); // refresh UI
              },
              child: Text("Save")),
        ],
      ),
    );
  }

  void deletePost() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Delete this post?"),
        content: Text("This action cannot be undone."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection("posts")
                  .doc(widget.post.id)
                  .delete();
              Navigator.pop(context);
              Navigator.pop(context); // go back to home screen

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Post deleted")),
              );
            },
            child: Text("Delete"),
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          ),
        ],
      ),
    );
  }

  String formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('MMM d, y – hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.post.get("title") ?? "Untitled";
    final String body = widget.post.get("body") ?? "No content";
    final String author = widget.post.get("author") ?? "Unknown";
    final Timestamp createdAt =
        widget.post.get("createdAt") ?? Timestamp.now();

    return Scaffold(
      appBar: AppBar(
        title: Text("Post Details"),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.blue),
            tooltip: "Edit",
            onPressed: showEditDialog,
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            tooltip: "Delete",
            onPressed: deletePost,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            Divider(height: 30),
            Text(
              body,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 30),
            Text(
              "By $author",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              formatTimestamp(createdAt),
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}