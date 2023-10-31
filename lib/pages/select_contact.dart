import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learning_once_again/components/build_users_list.dart';

class SelectContact extends StatelessWidget {
  const SelectContact({super.key, required this.auth});
  final FirebaseAuth auth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Contact')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contacts on ByteChat',
            style: TextStyle(fontSize: 12),
          ),
          BuildUsersList(auth: auth),
        ],
      ),
    );
  }
}
