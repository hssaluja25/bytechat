import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learning_once_again/pages/login_page.dart';
import 'package:learning_once_again/pages/register_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, required this.auth});
  final FirebaseAuth auth;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // Initially show the login page
  bool displayLoginPage = true;

  void togglePage() {
    setState(() {
      displayLoginPage = !displayLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    // No scaffold as both the login and registration page have scaffold
    return displayLoginPage
        ? LoginPage(
            auth: widget.auth,
            toggleAuthPage: togglePage,
          )
        : RegisterPage(
            auth: widget.auth,
            toggleAuthPage: togglePage,
          );
  }
}
