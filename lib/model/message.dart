import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String senderId;
  String receiverId;
  String message;
  String imageUrl;
  String type;
  Timestamp timeStamp;
  String senderEmail;

  Message({
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.imageUrl,
    required this.type,
    required this.timeStamp,
    required this.senderEmail,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'imageUrl': imageUrl,
      'type': type,
      'timeStamp': timeStamp,
      'senderEmail': senderEmail,
    };
  }

  static Message fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      message: map['message'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      type: map['type'] ?? 'text',
      timeStamp: map['timeStamp'],
      senderEmail: map['senderEmail'] ?? '',
    );
  }
}
