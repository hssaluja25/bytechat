import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Provide authentication stream
class Auth {
  final FirebaseAuth auth;
  Auth({required this.auth});

  Stream<User?> get user => auth.authStateChanges();

  Future<void> createAccount(
      {required String email, required String password}) async {
    await auth.createUserWithEmailAndPassword(
        email: email.trim(), password: password.trim());
  }

  Future<void> signIn({required String email, required String password}) async {
    await auth.signInWithEmailAndPassword(
        email: email.trim(), password: password.trim());
  }

  Future<void> signOut() async {
    if (await GoogleSignIn().isSignedIn()) {
      await GoogleSignIn().disconnect();
    }
    await auth.signOut();
  }

  Future<void> forgotPassword({required String email}) async {
    await auth.sendPasswordResetEmail(email: email);
  }

  Future<void> verifyUser({required User? userInfo}) async {
    // final crtUser = FirebaseAuth.instance.currentUser;
    // final actionCodeSettings = ActionCodeSettings(
    //   url: "http://www.example.com/verify?email=${crtUser?.email}",
    //   androidPackageName: "com.example.android",
    // );
    // await userInfo?.sendEmailVerification(actionCodeSettings);
    await userInfo?.sendEmailVerification();
  }
}

class GoogleAuth {
  Future signInWithGoogle() async {
    // Begin interactive process
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    // obtain auth details from request
    final GoogleSignInAuthentication gAuth = await gUser!.authentication;

    // create a new credential from user
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    // now sign in
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
