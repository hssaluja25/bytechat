import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:learning_once_again/components/my_button.dart';
import 'package:learning_once_again/pages/home_page.dart';
import 'package:learning_once_again/services/auth.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key, required this.auth});
  final FirebaseAuth auth;
  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isEmailVerified = false;
  Timer? timer;
  bool canResendEmail = false;

  @override
  void initState() {
    isEmailVerified = widget.auth.currentUser!.emailVerified;
    if (!isEmailVerified) {
      sendVerificationEmail();
      timer = Timer.periodic(
        const Duration(seconds: 3),
        (timer) => checkVerified(),
      );
    }
    super.initState();
  }

  Future sendVerificationEmail() async {
    try {
      await Auth(auth: widget.auth)
          .verifyUser(userInfo: widget.auth.currentUser);
      setState(() {
        canResendEmail = false;
      });
      await Future.delayed(const Duration(minutes: 1));
      setState(() {
        canResendEmail = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
            const SnackBar(content: Text("Could not send verification email")));
    }
  }

  Future checkVerified() async {
    await widget.auth.currentUser!.reload();
    setState(() {
      isEmailVerified = widget.auth.currentUser!.emailVerified;
    });

    if (isEmailVerified) {
      timer?.cancel();
    }
  }

  Future resendEmail() async {
    if (canResendEmail) {
      await sendVerificationEmail();
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Email sent')));
    } else {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(const SnackBar(
            content: Text(
                'Please wait for some time before sending verification email again')));
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return isEmailVerified
        ? Home(auth: widget.auth)
        : Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 3),
                Expanded(
                  flex: 4,
                  child: Image.asset('assets/images/arroba.png'),
                ),
                const Spacer(flex: 2),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Verify your email address',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(flex: 1),
                Expanded(
                  flex: 6,
                  child: SizedBox(
                    width: size.width / 1.2,
                    child: const Text(
                      'We have just send an email verification link on your email. Please check your email.\nIf not auto redirected after verification, click on the Continue button.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                // Continue button
                Expanded(
                  flex: 3,
                  child: MyButton(
                    onTap: checkVerified,
                    textOnBtn: 'Continue',
                  ),
                ),
                const Spacer(flex: 3),
                // Resend E-Mail link
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: resendEmail,
                    child: Text(
                      'Resend email link',
                      style:
                          TextStyle(color: Colors.blue.shade400, fontSize: 20),
                    ),
                  ),
                ),
                const Spacer(flex: 1),
                // Back to login
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: widget.auth.signOut,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.arrowLeftLong,
                          color: Colors.blue.shade400,
                        ),
                        Text(
                          '  Back to login',
                          style: TextStyle(
                              color: Colors.blue.shade400, fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(flex: 6),
              ],
            ),
          );
  }
}
