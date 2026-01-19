import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:wahab/screens/sign/auth_service.dart';
import 'package:wahab/screens/sign/my_button.dart';
import 'package:wahab/screens/sign/my_text_field.dart';
import 'package:wahab/screens/sign/squre_tile.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void signUserIn() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent user from dismissing by tapping outside
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: usernameController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Close loading dialog
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // Close loading dialog first
      Navigator.pop(context);

      // Show error message
      String errorMessage;

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No User found with this Email';
          break;
        case 'wrong-password':
          errorMessage = 'Password is incorrect';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email';
          break;
        case 'user-disabled':
          errorMessage = 'This Account has been disabled';
          break;
        case 'too-many-requests':
          errorMessage = 'Many attempts , try later';
          break;
        default:
          errorMessage = 'error: ${e.message}';
      }

      showErrorMassage(errorMessage);
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);

      // Show generic error
      showErrorMassage('ops:something happended:$e');
    }
  }

  void showErrorMassage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: AlertDialog(
            backgroundColor: Colors.deepPurple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Text(
              message,
              style: TextStyle(color: Colors.white, fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                Icon(Icons.lock, size: 100),
                SizedBox(height: 50),
                Text(
                  'Welcome Back you have been missed',
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),
                SizedBox(height: 25),
                MyTextField(
                  obsucreText: false,
                  hintText: 'Enter your username',
                  controller: usernameController,
                ),
                SizedBox(height: 10),
                MyTextField(
                  obsucreText: true,
                  hintText: 'Enter your password',
                  controller: passwordController,
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Forgot the password?',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 25),
                MyButton(
                  onTap: signUserIn,
                  button: 'Sign In',
                ),
                SizedBox(height: 50),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(thickness: 0.5, color: Colors.grey[400]),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or Continue with',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      Expanded(
                        child: Divider(thickness: 0.5, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SqureTile(
                      icon: Logo(
                        Logos.apple,
                        size: 28,
                      ),
                      onTap: () {},
                      text: 'Sign In With your Apple ID',
                    ),
                    const SizedBox(height: 10),
                    SqureTile(
                      icon: Logo(Logos.google, size: 28),
                      onTap: () => AuthService().signInWithGoogle(),
                      text: 'Sign In With your Google Account',
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a member yet?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Register Now',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
