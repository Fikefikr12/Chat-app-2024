import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chatapp1/pages/home_page.dart';

import 'login_or_register.dart'; // No extra space
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return   Scaffold(
      body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges()
          ,builder: (context,snapshot){
        // user loged in
        if(snapshot.hasData){
          return  HomePage();
        }
        else {
          return const LoginOrRegister();
        }
      }
      ),
    );
  }
}
