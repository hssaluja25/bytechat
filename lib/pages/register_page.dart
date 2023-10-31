import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learning_once_again/components/my_button.dart';
import 'package:learning_once_again/components/my_textfield.dart';
import 'package:learning_once_again/components/square_tile.dart';
import 'package:learning_once_again/services/auth.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({super.key, required this.auth, required this.toggleAuthPage});
  final Function() toggleAuthPage;
  final FirebaseAuth auth;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool registrationHappening = false;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    double ht = MediaQuery.of(context).size.height;
    double wd = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Form(
          key: _registerFormKey,
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: ht > 800 ? ht * 0.0534188 : ht * 0.05),

                  // logo
                  SizedBox(
                    height: ht > 800 ? ht * 0.1068376 : ht * 0.1,
                    width: wd > 385 ? ht * 0.1068376 : ht * 0.1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.asset(
                        'assets/images/512.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  SizedBox(height: ht * 0.0534188),

                  // Get started today, it's quick!
                  SizedBox(
                    height: ht > 800 ? ht * 0.024573 : ht * 0.031,
                    child: Center(
                      child: Text(
                        "Get started today, it's quick!",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: ht * 0.02671),

                  // username textfield
                  SizedBox(
                    height: ht * 0.068376,
                    child: MyTextField(
                      controller: usernameController,
                      hintText: 'Username',
                      obscureText: false,
                    ),
                  ),

                  SizedBox(height: ht * 0.01068),

                  // password textfield
                  SizedBox(
                    height: ht * 0.068376,
                    child: MyTextField(
                      controller: passwordController,
                      hintText: 'Password',
                      obscureText: true,
                    ),
                  ),

                  SizedBox(height: ht * 0.01068),

                  // confirm password textfield
                  SizedBox(
                    height: ht * 0.068376,
                    child: MyTextField(
                      controller: confirmPasswordController,
                      hintText: 'Confirm password',
                      obscureText: true,
                      passwordController: passwordController,
                    ),
                  ),

                  SizedBox(height: ht > 800 ? ht * 0.02671 : ht * 0.02),

                  // register button
                  SizedBox(
                    height: ht > 800 ? ht * 0.07799 : ht * 0.11,
                    child: MyButton(
                      textOnBtn: 'Register',
                      onTap: () async {
                        if (_registerFormKey.currentState!.validate()) {
                          // form is valid
                          try {
                            setState(() {
                              print(
                                  'registering with email and pwd in register_page.dart');
                              registrationHappening = true;
                            });

                            await Auth(auth: widget.auth).createAccount(
                                email: usernameController.text,
                                password: passwordController.text);
                            // Automatically the 'user' stream would detect a change in the auth state and push the home page.
                            // so we don't need to push the home page ourselves.
                          } on Exception catch (error) {
                            setState(() {
                              print('registering error on register_page.dart');
                              registrationHappening = false;
                            });
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
                  ),

                  SizedBox(height: ht > 800 ? ht * 0.0534188 : ht * 0.05),

                  // or continue with
                  SizedBox(
                    height: ht > 800 ? ht * 0.021367 : ht * 0.025,
                    child: Padding(
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
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
                  ),

                  SizedBox(height: ht * 0.0534188),

                  // google + facebook sign in buttons
                  SizedBox(
                    height: ht * 0.08761,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // google button
                        GestureDetector(
                          onTap: () async {
                            setState(() {
                              print(
                                  'logging in with google in register_page.dart');
                              registrationHappening = true;
                            });
                            try {
                              await GoogleAuth().signInWithGoogle();
                            } catch (e) {
                              setState(() {
                                print(
                                    'login with google cancelled in register_page.dart');
                                registrationHappening = false;
                              });

                              ScaffoldMessenger.of(context)
                                ..removeCurrentSnackBar()
                                ..showSnackBar(SnackBar(
                                    content: Text(e.toString().startsWith(
                                            'PlatformException(network_error')
                                        ? 'Check your internet connection'
                                        : 'Google sign in cancelled')));
                            }
                          },
                          child: const SquareTile(
                              imagePath: 'lib/images/google.png'),
                        ),

                        const SizedBox(width: 25),

                        // facebook button
                        GestureDetector(
                          onTap: () async {
                            try {
                              await FbAuth().signInWithFacebook();
                            } catch (e) {
                              print(e);
                              ScaffoldMessenger.of(context)
                                ..removeCurrentSnackBar()
                                ..showSnackBar(SnackBar(
                                    duration: const Duration(seconds: 6),
                                    content: Text(e.toString().startsWith(
                                            '[firebase_auth/account-exists-with-different-credential] An account already exists')
                                        ? 'You have previously logged in with either Google or email. Please finish logging in using that method to continue to the app.'
                                        : 'Something went wrong')));
                            }
                          },
                          child: const SquareTile(
                              imagePath: 'lib/images/facebook.png'),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: ht * 0.0534188),

                  // already have an account? log in
                  SizedBox(
                    height: ht > 800 ? ht * 0.021367 : ht * 0.029,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: widget.toggleAuthPage,
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // SizedBox(height: ht * 0.1132479),
                ],
              ),
              if (registrationHappening)
                const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}
