import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:learning_once_again/firebase_options.dart';
import 'package:learning_once_again/pages/auth_page.dart';
import 'package:learning_once_again/pages/verify_email_page.dart';
import 'package:learning_once_again/providers/user_provider.dart';
import 'package:learning_once_again/services/auth.dart';
import 'package:provider/provider.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  // We have created instances of FirebaseAuth and FirebaseFirestore here instead of creating them in the auth file otherwise everytime Auth is used instances of type FirebaseAuth and FirebaseFirestore would be created
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => UserProvider(),
      child: StreamBuilder(
          stream: Auth(auth: _auth).user,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: ThemeData(useMaterial3: true),
                home: snapshot.data == null
                    ? AuthPage(auth: _auth)
                    : VerifyEmailPage(
                        auth: _auth,
                        name: snapshot.data?.displayName ?? 'Your name',
                        email: snapshot.data?.email ??
                            'email not set. this should never happen as when snapshot.data is null, AuthPage should be displayed',
                        uid: snapshot.data?.uid ??
                            'uid not set. this should never happen as when snapshot.data is null, AuthPage should be displayed',
                      ),
              );
            } else if (snapshot.hasError) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: ThemeData(useMaterial3: true),
                home: const Center(
                  child: Text('Error authenticating'),
                ),
              );
            } else {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: ThemeData(useMaterial3: true),
                home: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          }),
    );
  }
}
