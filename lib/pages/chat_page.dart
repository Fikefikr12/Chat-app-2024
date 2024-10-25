import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../service/chat/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String userId;

  ChatPage({required this.userId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _selectedImages;
  Map<String, dynamic>? receiverData;
  String? _editingMessageId;

  Set<String> _selectedMessageIds = Set(); // Set for storing selected message IDs
  bool _isSelectionMode = false; // Flag for selection mode

  @override
  void initState() {
    super.initState();
    _fetchReceiverDetails();
  }

  Future<void> _fetchReceiverDetails() async {
    try {
      final receiverDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (receiverDoc.exists && receiverDoc.data() != null) {
        setState(() {
          receiverData = receiverDoc.data();
        });
      } else {
        print('Receiver document does not exist or is null.');
      }
    } catch (e) {
      print('Error fetching receiver details: $e');
    }
  }

  // Show bottom sheet to choose between camera or gallery
  void _showImageSourceDialog() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Container(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.camera_alt),
                    title: Text('Take a photo'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _takePhoto();
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.photo_library),
                    title: Text('Choose from gallery'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _pickFromGallery();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  // Capture a photo using the camera
  Future<void> _takePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImages = [pickedFile];
      });
    }
  }

  // Pick images from the gallery
  Future<void> _pickFromGallery() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _selectedImages = pickedFiles;
      });
    }
  }

  // Send the selected images
  Future<void> _sendImages() async {
    if (_selectedImages != null && _selectedImages!.isNotEmpty) {
      for (var imageFile in _selectedImages!) {
        await _chatService.sendImage(widget.userId, File(imageFile.path));
      }
      setState(() {
        _selectedImages = null; // Clear after sending
      });
    }
  }

  // Send or edit a text message
  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      if (_editingMessageId != null) {
        _chatService.updateMessage(
            widget.userId, _editingMessageId!, _messageController.text);
        setState(() {
          _editingMessageId = null;
        });
      } else {
        _chatService.sendMessage(widget.userId, _messageController.text);
      }
      _messageController.clear();
    }
  }

  // Function to toggle message selection on long press
  void _toggleMessageSelection(String messageId) {
    setState(() {
      if (_selectedMessageIds.contains(messageId)) {
        _selectedMessageIds.remove(messageId);
      } else {
        _selectedMessageIds.add(messageId);
      }
      _isSelectionMode = _selectedMessageIds.isNotEmpty;
    });
  }

  // Copy selected text messages
  Future<void> _copySelectedMessages() async {
    String copiedText = '';
    for (String messageId in _selectedMessageIds) {
      final messageSnapshot = await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(widget.userId)
          .collection('messages')
          .doc(messageId)
          .get();
      final messageData = messageSnapshot.data();
      if (messageData != null && messageData['message'].isNotEmpty) {
        copiedText += messageData['message'] + '\n';
      }
    }
    if (copiedText.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: copiedText)).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Copied to clipboard")));
      });
    }
    _cancelSelection();
  }


  // Delete selected messages
  Future<void> _deleteSelectedMessages() async {
    if (_selectedMessageIds.isNotEmpty) {
      await _chatService.deleteMultipleMessages(
          widget.userId, _selectedMessageIds.toList());
      _cancelSelection();
    }
  }

  // Cancel the selection mode
  void _cancelSelection() {
    setState(() {
      _selectedMessageIds.clear();
      _isSelectionMode = false;
    });
  }

  // Build the message UI
  Widget _buildMessageItem(DocumentSnapshot messageData, bool isSender) {
    final isImage = messageData['imageUrl'] != '';
    final messageId = messageData.id;
    final isSelected = _selectedMessageIds.contains(messageId);

    return GestureDetector(
      onLongPress: () {
        _toggleMessageSelection(messageId);
      },
      child: Container(
        color: isSelected ? Colors.blue.withOpacity(0.3) : null,
        child: Align(
          alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
          child: Column(
            crossAxisAlignment:
            isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSender ? Colors.blue[200] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: isImage
                    ? Image.network(
                  messageData['imageUrl'],
                  width: 150,
                  fit: BoxFit.cover,
                )
                    : Text(
                  messageData['message'] ?? '',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              Text(
                DateFormat('hh:mm a')
                    .format(messageData['timeStamp'].toDate()),
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: receiverData == null
            ? Text('Chat')
            : Row(
          children: [
            CircleAvatar(
              backgroundImage: receiverData?['imageUrl'] != null
                  ? NetworkImage(receiverData!['imageUrl'])
                  : AssetImage('assets/default_avatar.png')
              as ImageProvider,
            ),
            SizedBox(width: 10),
            Text(receiverData?['name'] ?? 'Unknown User'),
          ],
        ),
        actions: _isSelectionMode
            ? <Widget>[
          IconButton(
            icon: Icon(Icons.copy),
            onPressed: _copySelectedMessages,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteSelectedMessages,
          ),
        ]
            : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatService.getMessagesStream(widget.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error loading messages'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No messages yet'));
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData = messages[index];
                    final isSender =
                        messageData['senderId'] ==
                            _chatService.getCurrentUser()?.uid;
                    return _buildMessageItem(messageData, isSender);
                  },
                );
              },
            ),
          ),
          if (_selectedImages != null && _selectedImages!.isNotEmpty)
            Row(
              children: _selectedImages!.map((image) {
                return Stack(
                  children: [
                    Image.file(File(image.path), width: 50, height: 50),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(
                          (_selectedImages!.indexOf(image) + 1).toString(),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.photo_camera),
                  onPressed: _showImageSourceDialog,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_selectedImages != null &&
                        _selectedImages!.isNotEmpty) {
                      _sendImages();
                    } else {
                      _sendMessage();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
