
import 'package:flutter/material.dart';
import '../component/my_buton.dart';
import '../component/my_textfield.dart';
import '../service/auth/auth_service.dart';
class loginpage extends StatelessWidget {
  final TextEditingController _emailController=TextEditingController();
  final TextEditingController _passwordController=TextEditingController();
  final void Function()? onTap;
  void login (BuildContext context) async{
    final auth =AuthService();
    try{
      await auth.signInWithEmailPassword(
          _emailController.text,
          _passwordController.text);
    }
    catch(e){
      showDialog(context: context,
          builder: (context)=>AlertDialog(title: Text(e.toString()),));
    }
  }
  loginpage({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return   Scaffold(
      backgroundColor:   Theme.of(context).colorScheme.background,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.message,
            size: 50,
            color: Theme.of(context).colorScheme.primary,),
          SizedBox(height: 30,),
          Text('Welcome o the login screen',
            style: TextStyle(
              fontSize: 20,
              color: Theme.of(context).colorScheme.primary,
            ),),
          SizedBox(height: 10,),
          myTextfield(
            hintText: "Email",
            obsecureText: false,
            controller: _emailController,
          ),
          SizedBox(height: 20,),
          myTextfield(
            obsecureText: true,
            hintText: "Password",
            controller: _passwordController,
          ),
          SizedBox(height: 20,),
          mybutton(text: "Login",
            onTap: () =>login(context),),
          SizedBox(height: 20,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 70.0),
            child: Row(
              children: [
                Text("Not a member ? ",style: TextStyle(
                    color: Theme.of(context).colorScheme.primary
                ),),

                GestureDetector(
                  onTap: onTap,
                  child: Text("Register now ? "
                    ,style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold
                    ),),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

