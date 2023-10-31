// Display all users except the current one
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learning_once_again/components/user_item.dart';

class BuildUsersList extends StatefulWidget {
  final FirebaseAuth auth;
  const BuildUsersList({super.key, required this.auth});

  @override
  State<BuildUsersList> createState() => _BuildUsersListState();
}

class _BuildUsersListState extends State<BuildUsersList> {
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('users').snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error getting users list: ${snapshot.error}'),
          );
        } else if (snapshot.hasData) {
          return Expanded(
            child: Container(
              padding: const EdgeInsets.only(top: 15),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35)),
              ),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: snapshot.data!.docs
                    .map((doc) => UserItem(document: doc, auth: widget.auth))
                    .toList(),
              ),
            ),
          );
        } else {
          debugPrint('Getting users from Firebase');
          return Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35)),
              ),
            ),
          );
        }
      },
    );
  }
}
