import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_page.dart';

class ChatUserListPage extends StatefulWidget {
  @override
  _ChatUserListPageState createState() => _ChatUserListPageState();
}

class _ChatUserListPageState extends State<ChatUserListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;  // Get current logged-in user
  String _searchQuery = '';  // To store the search query

  // Filter the users by search query and remove the current logged-in user
  List<QueryDocumentSnapshot> _filterUsers(List<QueryDocumentSnapshot> users) {
    return users.where((user) {
      final data = user.data() as Map<String, dynamic>;
      final name = data.containsKey('name') ? data['name']?.toLowerCase() : '';
      final userId = user.id;  // Get the user ID
      // Filter by search query and exclude the current logged-in user
      return name.contains(_searchQuery.toLowerCase()) && userId != currentUser!.uid;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Users'),
      ),
      body: Column(
        children: [
          // Search bar to filter users by name
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search by name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;  // Update search query on text input
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('users').snapshots(),  // Fetch user data from Firestore
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final users = _filterUsers(snapshot.data!.docs);  // Filter users by search query and exclude current user

                if (users.isEmpty) {
                  return Center(child: Text('No users found'));
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final data = user.data() as Map<String, dynamic>;

                    final String name = data.containsKey('name') ? data['name'] ?? 'No name' : 'No name';  // Safely access 'name'
                    final String imageUrl = data.containsKey('imageUrl') ? data['imageUrl'] ?? '' : '';  // Safely access 'imageUrl'

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: imageUrl.isNotEmpty
                            ? NetworkImage(imageUrl)  // Use user's profile image
                            : AssetImage('assets/default_avatar.png'),  // Placeholder if no image
                      ),
                      title: Text(name),  // Display user's name
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(userId: user.id),  // Navigate to chat page
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
