import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learning_once_again/pages/chat_page.dart';
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
              } on Exception catch (error) {
                print(error);
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
      body: BuildUsersList(auth: auth),
    );
  }
}

// Display all users except the current one
class BuildUsersList extends StatelessWidget {
  final FirebaseAuth auth;
  const BuildUsersList({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error getting users list: ${snapshot.error}'),
          );
        } else if (snapshot.hasData) {
          return ListView(
            children: snapshot.data!.docs
                .map((doc) => UserItem(document: doc, auth: auth))
                .toList(),
          );
        } else {
          debugPrint('Getting users from Firebase');
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class UserItem extends StatelessWidget {
  late final Map<String, dynamic> data;
  UserItem({super.key, required this.auth, required this.document}) {
    data = document.data()! as Map<String, dynamic>;
  }

  final FirebaseAuth auth;
  final DocumentSnapshot document;
  @override
  Widget build(BuildContext context) {
    if (auth.currentUser!.email != data['email']) {
      return ListTile(
        title: Text(data['email']),
        onTap: () {
          // Go to user's chat page
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatPage(
                        receiverUserEmail: data['email'],
                        receiverUserID: data['uid'],
                      )));
        },
      );
    } else {
      return Container();
    }
  }
}
