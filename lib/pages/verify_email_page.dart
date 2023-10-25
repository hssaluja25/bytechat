import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
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
  bool fetchingComplete = false;
  Timer? timer;
  bool canResendEmail = false;

  @override
  void initState() {
    print('At the beggining, isEmailVerified=$isEmailVerified');
    initializeIsEmailVerified();
    super.initState();
  }

  Future initializeIsEmailVerified() async {
    isEmailVerified = widget.auth.currentUser!.emailVerified;
    if (isEmailVerified) {
      print('isEmailVerified = true from Firebase');
      setState(() {
        isEmailVerified = true;
        fetchingComplete = true;
      });
      // setState(() {
      //   fetchingComplete = true;
      // });
    } else {
      print('isEmailVerified = false from Firebase');
      print('now checking if the user logged in with Fb');

      final AccessToken? accessToken = await FacebookAuth.instance.accessToken;
      if (accessToken != null) {
        // If you login with Fb, isEmailVerified is set to false. This is the
        // expected behaviour. But we don't want to display this VerifyEmailPage
        // if the user logs in with Fb. So we need to set isEmailVerified to true
        // if the user has logged in with Fb
        print('isEmailVerified = true as user logged in with Fb');
        setState(() {
          isEmailVerified = true;
          fetchingComplete = true;
        });
      } else {
        print('isEmailVerified = false as user DID NOT log in with Fb');
        setState(() {
          isEmailVerified = false;
          fetchingComplete = true;
        });
      }
    }
    if (fetchingComplete) {
      print('fetchingComplete = $fetchingComplete');
      if (!isEmailVerified) {
        print('isEmailVerified is false. sending verification email');
        sendVerificationEmail();
        timer = Timer.periodic(
          const Duration(seconds: 3),
          (timer) => checkVerified(),
        );
      }
    } else {
      print('fetchingComplete = $fetchingComplete');
    }
  }

  Future sendVerificationEmail() async {
    try {
      print('sending email...');
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
    print('checking verification status...');
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
      print('user can resend email');
      await sendVerificationEmail();
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Email sent')));
    } else {
      print('user cannot resend email');
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
    final double ht = MediaQuery.of(context).size.height;
    final double wd = MediaQuery.of(context).size.width;
    return !fetchingComplete
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : isEmailVerified
            ? Home(auth: widget.auth)
            : Scaffold(
                body: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: ht * 0.12),
                      SizedBox(
                        height: ht > 800 ? ht * 0.15 : ht * 0.1,
                        child: Image.asset('assets/images/arroba.png'),
                      ),
                      SizedBox(height: ht * 0.03),
                      SizedBox(
                        height: ht * 0.06,
                        // height: ht > 800 ? ht * 0.06 : ht * 0.03,
                        child: Text(
                          'Verify your email address',
                          style: TextStyle(
                              fontSize: ht > 800 ? 24 : 21,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: ht * 0.005,
                      ),
                      SizedBox(
                        height: ht > 800 ? ht * 0.18 : ht * 0.23,
                        width: wd > 385 ? wd * 0.85648 : wd * 0.85,
                        child: Text(
                          'We have just sent an email verification link to your email. Please check your email.\nIf not auto redirected after verification, click on the Continue button.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: ht > 800 ? 20 : 16,
                          ),
                        ),
                      ),
                      // Continue button
                      SizedBox(
                        height: ht > 800 ? ht * 0.07799 : ht * 0.095,
                        child: MyButton(
                          onTap: () async {
                            print('inside continue btn handler');
                            await checkVerified();
                            if (!isEmailVerified) {
                              ScaffoldMessenger.of(context)
                                ..removeCurrentSnackBar()
                                ..showSnackBar(const SnackBar(
                                  content:
                                      Text('User has not yet been verified'),
                                ));
                            }
                          },
                          textOnBtn: 'Continue',
                        ),
                      ),
                      SizedBox(height: ht * 0.12),
                      // Resend E-Mail link
                      SizedBox(
                        height: ht * 0.03098,
                        child: GestureDetector(
                          onTap: resendEmail,
                          child: Text(
                            'Resend email link',
                            style: TextStyle(
                                color: Colors.blue.shade400,
                                fontSize: ht > 800 ? 20 : 18),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: ht * 0.025,
                      ),
                      // Back to login
                      SizedBox(
                        height: ht > 800 ? ht * 0.03098 : ht * 0.035,
                        child: GestureDetector(
                          onTap: widget.auth.signOut,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              FaIcon(FontAwesomeIcons.arrowLeftLong,
                                  color: Colors.blue.shade400),
                              Text(
                                '  Back to login',
                                style: TextStyle(
                                    color: Colors.blue.shade400,
                                    fontSize: ht > 800 ? 20 : 18),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
  }
}
