import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learning_once_again/pages/chat_page.dart';

class ChatUserItem extends StatelessWidget {
  late final Map<String, dynamic> data;
  ChatUserItem({super.key, required this.auth, required this.document}) {
    data = document.data()! as Map<String, dynamic>;
  }

  final FirebaseAuth auth;
  final DocumentSnapshot document;
  @override
  Widget build(BuildContext context) {
    // Display all users except the current user
    if (auth.currentUser!.email != data['email']) {
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 5),
        title: Text(data['name']),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(data['avatar']),
          radius: 30,
        ),
        onTap: () {
          // Go to user's chat page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverName: data['name'],
                receiverUserID: data['uid'],
                receiverAvatar: data['avatar'],
              ),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }
}
