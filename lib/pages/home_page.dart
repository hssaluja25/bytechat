import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learning_once_again/services/auth.dart';

class Home extends StatelessWidget {
  const Home({super.key, required this.auth});
  final FirebaseAuth auth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                showDialog(
                    context: context,
                    builder: (context) {
                      return const Center(child: CircularProgressIndicator());
                    });
                await Auth(auth: auth).signOut();
                if (!context.mounted) return;
                Navigator.pop(context);
              } on Exception catch (_) {
                if (!context.mounted) return;
                Navigator.pop(context);
                showDialog(
                  barrierDismissible: true,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: const Text(
                        "Couldn't log out. Please try again later.",
                        style: TextStyle(fontSize: 18),
                      ),
                      actions: [
                        TextButton(
                          child: const Text('Okay'),
                          onPressed: () {
                            if (!context.mounted) return;
                            Navigator.pop(context);
                          },
                        )
                      ],
                    );
                  },
                );
              }
            },
          )
        ],
      ),
      body: const Center(
        child: Text("You are logged in, what more do you want?"),
      ),
    );
  }
}
