import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../component/my_drawer.dart';
import '../component/user_tiel.dart';
import '../service/auth/auth_service.dart';
import '../service/chat/chat_service.dart';
import 'chat_page.dart';
class HomePage extends StatelessWidget {
  HomePage({super.key});

  final  ChatService _chatService = ChatService();
  final AuthService _authService =AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),
      drawer: MyDrawer(),
      body: _buildUserList(),
    );
  }
  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUsersStream(),
      builder: (context,snapshot){
        // error
        if(snapshot.hasError){
          return Text("Error");
        }

        // loading
        if(snapshot.connectionState ==ConnectionState.waiting){
          return Text(" Loading...");
        }

        return ListView(
          children:snapshot.data!
              .map<Widget>((userData)=>_buildUserListItem(userData,context)).toList(),
        );

      },
    );
  }
  // build individual list tile for user
  Widget _buildUserListItem(
      Map<String ,dynamic> userData, BuildContext context){
    if(userData["email"] != _authService.getCurrentUser()!.email){
      return UserTile(
          text:userData["email"],
          onTap:(){
            Navigator.push(context,
                MaterialPageRoute
                  (builder: (context)=>ChatPage(
                  receiverEmail: userData["email"],
                  receiverID: userData['uid'],
                )));
          }
      );
    }
    else{
      return Container();
    }
  }


}
// C:\flutter\src\flutter\bin\cache\dart-sdk
