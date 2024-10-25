import 'package:flutter/material.dart';
import '../component/my_buton.dart';
import '../component/my_textfield.dart';
import '../service/auth/auth_service.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final void Function()? onTap;

  RegisterPage({super.key, this.onTap});

  void register(BuildContext context) async {
    final _auth = AuthService();
    // Password match check
    if (_pwController.text == _confirmController.text) {
      try {
        await _auth.signUpWithEmailPassword(
          _emailController.text,
          _pwController.text,
        );
        // If successful, navigate or show success dialog
      } catch (e) {
        // Show error dialog on failure
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(e.toString()),
          ),
        );
      }
    } else {
      // Show dialog for password mismatch
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Passwords do not match'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.message,
            size: 50,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 30),
          Text(
            'Let\'s create an account for you',
            style: TextStyle(
              fontSize: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          myTextfield(
            hintText: "Email",
            obsecureText: false,
            controller: _emailController,
          ),
          const SizedBox(height: 15),
          myTextfield(
            hintText: "Password",
            obsecureText: true,
            controller: _pwController,
          ),
          const SizedBox(height: 15),
          myTextfield(
            hintText: "Confirm Password",
            obsecureText: true,
            controller: _confirmController,
          ),
          const SizedBox(height: 15),
          mybutton(
            text: "Register",
            onTap: () => register(context),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 70.0),
            child: Row(
              children: [
                Text(
                  "Already have an account? ",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    "Login now",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
