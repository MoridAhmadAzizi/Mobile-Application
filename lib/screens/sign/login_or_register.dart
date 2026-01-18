
import 'package:flutter/material.dart';
import 'package:wahab/screens/sign/login_page.dart';
import 'package:wahab/screens/sign/register_page.dart';
class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {

  bool showLoginpage = true;
  void togglePages (){
    setState(() {
      showLoginpage = !showLoginpage;
    });
  }
  @override
  Widget build(BuildContext context) {
    if(showLoginpage){
      return LoginPage(onTap: togglePages);
    }else{
      return RegisterPage(onTap: togglePages);
    }
  }
}

