// home.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final User user;
  final CollectionReference posts =
      FirebaseFirestore.instance.collection("posts");

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    // Navigate to login screen after logout
    Navigator.of(context).pushNamedAndRemoveUntil(
        "login", (Route<dynamic> route) => false);
  }

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
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
          stream: posts.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text("No posts found."));
            }

            return ListView(
              children: snapshot.data!.docs
                  .map((item) {
                    String title = item.get("title") ?? "Untitled";
                    String body = item.get("body") ?? "No content";

                    return Card(
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
                          ],
                        ),
                      ),
                    );
                  })
                  .toList()
                  .cast<Widget>(),
            );
          },
        ),
      ),
    );
  }
}