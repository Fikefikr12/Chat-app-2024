import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChatService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Stream messages between two users
  Stream<QuerySnapshot> getMessagesStream(String userId) {
    final currentUserId = _auth.currentUser?.uid;
    List<String> userIds = [currentUserId!, userId];
    userIds.sort();
    String chatRoomId = userIds.join('_');

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timeStamp', descending: true)
        .snapshots();
  }

  // Send a text message
  Future<void> sendMessage(String userId, String message) async {
    final currentUserId = _auth.currentUser?.uid;
    List<String> userIds = [currentUserId!, userId];
    userIds.sort();
    String chatRoomId = userIds.join('_');

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add({
      'senderId': currentUserId,
      'message': message,
      'timeStamp': Timestamp.now(),
      'imageUrl': '',
    });
  }

  // Send an image message
  Future<void> sendImage(String userId, File imageFile) async {
    final currentUserId = _auth.currentUser?.uid;
    List<String> userIds = [currentUserId!, userId];
    userIds.sort();
    String chatRoomId = userIds.join('_');

    String fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
    final uploadTask = await _storage
        .ref('chat_images/$fileName')
        .putFile(imageFile);

    final imageUrl = await uploadTask.ref.getDownloadURL();

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add({
      'senderId': currentUserId,
      'imageUrl': imageUrl,
      'timeStamp': Timestamp.now(),
      'message': '',
    });
  }

  // Update a message
  Future<void> updateMessage(
      String userId, String messageId, String newMessage) async {
    final currentUserId = _auth.currentUser?.uid;
    List<String> userIds = [currentUserId!, userId];
    userIds.sort();
    String chatRoomId = userIds.join('_');

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId)
        .update({'message': newMessage});
  }

  // Delete a single message
  Future<void> deleteMessage(String userId, String messageId) async {
    final currentUserId = _auth.currentUser?.uid;
    List<String> userIds = [currentUserId!, userId];
    userIds.sort();
    String chatRoomId = userIds.join('_');

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  // Delete multiple messages
  Future<void> deleteMultipleMessages(String userId, List<String> messageIds) async {
    final currentUserId = _auth.currentUser?.uid;
    List<String> userIds = [currentUserId!, userId];
    userIds.sort();
    String chatRoomId = userIds.join('_');

    WriteBatch batch = _firestore.batch();

    for (String messageId in messageIds) {
      DocumentReference messageRef = _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId);

      batch.delete(messageRef);
    }

    await batch.commit();
  }
}
