import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learning_once_again/components/my_button.dart';
import 'package:learning_once_again/components/my_textfield.dart';
import 'package:learning_once_again/components/square_tile.dart';
import 'package:learning_once_again/services/auth.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key, required this.auth, required this.toggleAuthPage});

  final Function() toggleAuthPage;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth auth;
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Form(
            key: _loginFormKey,
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

                // welcome back, you've been missed!
                Center(
                  child: Text(
                    'Welcome back you\'ve been missed!',
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

                // forgot password?
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          try {
                            await Auth(auth: auth)
                                .forgotPassword(email: usernameController.text);
                            ScaffoldMessenger.of(context)
                              ..removeCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content:
                                      const Text('Password reset email sent'),
                                  duration: const Duration(seconds: 3),
                                  action: SnackBarAction(
                                      label: 'Okay',
                                      onPressed: () {
                                        ScaffoldMessenger.of(context)
                                            .removeCurrentSnackBar();
                                      }),
                                ),
                              );
                          } on Exception catch (error) {
                            ScaffoldMessenger.of(context)
                              ..removeCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: error.toString() ==
                                              '[firebase_auth/invalid-email] The email address is badly formatted.' ||
                                          error.toString() ==
                                              '[firebase_auth/channel-error] Unable to establish connection on channel.'
                                      ? const Text('Invalid email')
                                      : const Text('Something went wrong...'),
                                  duration: const Duration(seconds: 3),
                                  action: SnackBarAction(
                                      label: 'Okay',
                                      onPressed: () {
                                        ScaffoldMessenger.of(context)
                                            .removeCurrentSnackBar();
                                      }),
                                ),
                              );
                          }
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // sign in button
                MyButton(
                  btnType: 'Login',
                  onTap: () async {
                    if (_loginFormKey.currentState!.validate()) {
                      // form is valid
                      try {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            });
                        await Auth(auth: auth).signIn(
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
                                        '[firebase_auth/network-request-failed] A network error (such as timeout, interrupted connection or unreachable host) has occurred.'
                                    ? 'Check your internet connection'
                                    : "Invalid login credentials",
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

                // not a member? register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a member?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: toggleAuthPage,
                      child: const Text(
                        'Register now',
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
