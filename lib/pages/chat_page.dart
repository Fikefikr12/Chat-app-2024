import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';  // ADD this import to resolve the error
import '../component/chat_buble.dart';  // Assuming this is the widget for the message bubble
import '../component/my_textfield.dart';  // Assuming this is your custom text field
import '../service/auth/auth_service.dart';
import '../service/chat/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;

  ChatPage({
    super.key,
    required this.receiverEmail,
    required this.receiverID,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // Text controller
  final TextEditingController _messageController = TextEditingController();

  // Chat and Auth service instances
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  // Focus node to track the text field focus
  FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Add listener to the focus node
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        // Delay to ensure keyboard is shown before scrolling
        Future.delayed(Duration(milliseconds: 500), () => scrollDown());
      }
    });

    // Scroll down after a delay once the widget is built
    Future.delayed(Duration(milliseconds: 500), () => scrollDown());
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // Scroll controller to manage ListView scrolling
  final ScrollController _scrollController = ScrollController();

  // Scroll down to the bottom of the message list
  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  // Send message method
  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(widget.receiverID, _messageController.text);

      // Clear the message input field after sending
      _messageController.clear();
    }

    scrollDown();
  }

  // Build the chat page UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverEmail),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Display all messages
          Expanded(
            child: _buildMessageList(),
          ),
          // User input field
          _buildUserInput(),
        ],
      ),
    );
  }

  // Build message list
  Widget _buildMessageList() {
    String senderID = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: _chatService.getMessages(widget.receiverID, senderID),
      builder: (context, snapshot) {
        // Handle errors
        if (snapshot.hasError) {
          return const Text("Error");
        }

        // Show loading spinner while data is being fetched
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        // Display the list of messages
        if (snapshot.hasData) {
          var messages = snapshot.data!.docs;

          return ListView.builder(
            controller: _scrollController,  // Use the ScrollController
            itemCount: messages.length,
            itemBuilder: (context, index) {
              return _buildMessageItem(messages[index]);
            },
          );
        }

        // If no data is present
        return Center(child: Text("No messages yet"));
      },
    );
  }

  // Build each message item
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Get current user ID
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;  // This now works

    // Check if the message is from the current user
    bool isCurrentUser = data['senderId'] == currentUserId;

    // Align message to the right if sender, otherwise left
    return Container(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: isCurrentUser ? Colors.green : Colors.grey[300],  // Green for sender, grey for receiver
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: isCurrentUser ? Radius.circular(12) : Radius.zero,
            bottomRight: isCurrentUser ? Radius.zero : Radius.circular(12),
          ),
        ),
        child: Text(
          data['message'],
          style: TextStyle(
            color: isCurrentUser ? Colors.white : Colors.black,  // White text for sender, black for receiver
          ),
        ),
      ),
    );
  }

  // Build the user input field
  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0),
      child: Row(
        children: [
          // Text field for message input
          Expanded(
            child: myTextfield(
              hintText: "Type a message",
              obsecureText: false,
              controller: _messageController,
              focusNode: myFocusNode,
            ),
          ),
          // Send button
          Container(
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            margin: EdgeInsets.only(right: 25),
            child: IconButton(
              onPressed: sendMessage,
              icon: Icon(
                Icons.arrow_upward,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
