import 'package:chatapp1/pages/login_page.dart';
import 'package:chatapp1/pages/register_page.dart';
import 'package:flutter/material.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  bool showloginpage =true;
  void togglePage(){
    setState(() {
      showloginpage =!showloginpage;
    });
  }
  @override
  Widget build(BuildContext context) {
    if (showloginpage){
      return loginpage(
          onTap: togglePage);
    }
    else{
      return RegisterPage(
        onTap: togglePage,
      );
    }
  }
}

