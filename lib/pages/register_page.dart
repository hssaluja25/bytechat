import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learning_once_again/components/my_button.dart';
import 'package:learning_once_again/components/my_textfield.dart';
import 'package:learning_once_again/components/square_tile.dart';
import 'package:learning_once_again/services/auth.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key, required this.auth, required this.toggleAuthPage});

  final Function() toggleAuthPage;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final FirebaseAuth auth;
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Form(
            key: _registerFormKey,
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 50),

                // logo
                const Icon(
                  Icons.lock,
                  size: 100,
                ),

                const SizedBox(height: 50),

                // Get started today, it's quick!
                Center(
                  child: Text(
                    "Get started today, it's quick!",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // username textfield
                MyTextField(
                  controller: usernameController,
                  hintText: 'Username',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // password textfield
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                // confirm password textfield
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm password',
                  obscureText: true,
                  passwordController: passwordController,
                ),

                const SizedBox(height: 25),

                // register button
                MyButton(
                  btnType: 'Register',
                  onTap: () async {
                    if (_registerFormKey.currentState!.validate()) {
                      // form is valid
                      try {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            });
                        await Auth(auth: auth).createAccount(
                            email: usernameController.text,
                            password: passwordController.text);
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        // Automatically the 'user' stream would detect a change in the auth state and push the home page.
                        // so we don't need to push the home page ourselves.
                      } on Exception catch (error) {
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        showDialog(
                          barrierDismissible: true,
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(
                                error.toString() ==
                                        '[firebase_auth/email-already-in-use] The email address is already in use by another account.'
                                    ? 'This account already exists'
                                    : error.toString() ==
                                            '[firebase_auth/network-request-failed] A network error (such as timeout, interrupted connection or unreachable host) has occurred.'
                                        ? 'Check your internet connection'
                                        : "Couldn't create an account. Please try again later.",
                                style: const TextStyle(fontSize: 18),
                              ),
                              actions: [
                                TextButton(
                                  child: const Text("Okay"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                )
                              ],
                            );
                          },
                        );
                      }
                    }
                  },
                ),

                const SizedBox(height: 50),

                // or continue with
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                // google + apple sign in buttons
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // google button
                    SquareTile(imagePath: 'lib/images/google.png'),

                    SizedBox(width: 25),

                    // apple button
                    SquareTile(imagePath: 'lib/images/apple.png')
                  ],
                ),

                const SizedBox(height: 50),

                // already have an account? log in
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: toggleAuthPage,
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
