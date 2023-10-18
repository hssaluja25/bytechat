import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:learning_once_again/firebase_options.dart';
import 'package:learning_once_again/pages/auth_page.dart';
import 'package:learning_once_again/pages/home_page.dart';
import 'package:learning_once_again/services/auth.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  // We have created instances of FirebaseAuth and FirebaseFirestore here instead of creating them in the auth file otherwise everytime Auth is used instances of type FirebaseAuth and FirebaseFirestore would be created
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Auth(auth: _auth).user,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(useMaterial3: true),
              home: snapshot.data == null
                  ? AuthPage(auth: _auth)
                  : Home(auth: _auth),
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
        });
  }
}
