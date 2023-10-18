import 'package:firebase_auth/firebase_auth.dart';

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
    await auth.signOut();
  }

  Future<void> forgotPassword({required String email}) async {
    await auth.sendPasswordResetEmail(email: email);
  }
}
