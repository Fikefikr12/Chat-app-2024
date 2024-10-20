import 'package:cloud_firestore/cloud_firestore.dart';  // Required for Firestore's Timestamp

class Message {
  String senderId;
  String senderEmail;
  String receiverId;
  String message;
  Timestamp timeStamp;

  Message({
    required this.senderId,
    required this.senderEmail,
    required this.receiverId,
    required this.message,
    required this.timeStamp,
  });

  // Convert the message to a map to store in Firestore
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,          // Sender's ID
      'senderEmail': senderEmail,    // Sender's email
      'receiverId': receiverId,      // Receiver's ID
      'message': message,            // The actual message
      'timestamp': timeStamp,        // Time the message was sent
    };
  }
}
