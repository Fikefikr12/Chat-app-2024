import 'package:chatapp1/model/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user stream
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  // Send message and create chat room if necessary
  Future<void> sendMessage(String receiverID, String message) async {
    // Get current user info
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    // Create a new message object
    Message newMessage = Message(
      senderId: currentUserID,        // Ensure senderId is added here
      senderEmail: currentUserEmail,
      receiverId: receiverID,
      message: message,
      timeStamp: timestamp,
    );

    // Construct chat room ID for the two users
    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');

    // Create or update the chat room document with metadata
    await _firestore.collection("chat_rooms").doc(chatRoomID).set({
      'receiverId': receiverID,            // Store receiver ID
      'lastMessage': message,              // Store the latest message
      'lastMessageTime': timestamp,        // Timestamp of the latest message
      'lastMessageSender': currentUserEmail,  // Sender's email of the latest message
    }, SetOptions(merge: true)); // Merge to ensure no overwriting

    // Add the new message to the messages sub-collection with senderId
    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());   // Use toMap to ensure all fields are saved
  }

  // Get messages from Firestore
  Stream<QuerySnapshot> getMessages(String userID, String otherUserID) {
    // Construct a chatroom ID for the two users
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    // Return messages ordered by timestamp
    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)  // Sort messages in chronological order
        .snapshots();
  }
}
