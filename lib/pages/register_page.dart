import 'package:flutter/material.dart';
import '../component/my_buton.dart';
import '../component/my_textfield.dart';
import '../service/auth/auth_service.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController _emailController=TextEditingController();
  final TextEditingController _pwController=TextEditingController();
  final TextEditingController _confirmcontroller=TextEditingController();
  final void Function()? onTap;
  RegisterPage({super.key, this.onTap});

  void register(BuildContext context) async{
    final _auth = AuthService();
    // password match creat user
    if(_pwController.text == _confirmcontroller.text){
      try{
        await _auth.signUpWithEmailPassword(
            _emailController.text,
            _pwController.text);
      }
      catch(e){
        showDialog(context: context,
          builder: (context) =>AlertDialog(
            title: Text(e.toString()),),);
      }}

    // password doesn't match -> tell to fix
    else{
      showDialog(context: context,
        builder: (context) =>AlertDialog(
          title: Text('password donot match'),),);
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor:   Theme.of(context).colorScheme.background,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.message,
            size: 50,
            color: Theme.of(context).colorScheme.primary,),
          SizedBox(height: 30,),
          Text('Lets create an account for you',
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
          SizedBox(height: 15,),
          myTextfield(
            obsecureText: true,
            hintText: "Password",
            controller: _pwController,
          ),
          SizedBox(height: 15,),
          myTextfield(
            obsecureText: true,
            hintText: "confirm password",
            controller: _confirmcontroller,
          ),
          SizedBox(height: 15,),
          mybutton(text: "Register",
            onTap: ()=>register(context),),
          SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 70.0),
            child: Row(
              children: [
                Text("Already have an account ? ",style: TextStyle(
                    color: Theme.of(context).colorScheme.primary
                ),),

                GestureDetector(
                  onTap: onTap,
                  child: Text("Login now  ",
                    style: TextStyle(
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
