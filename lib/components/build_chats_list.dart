// Display current user's chats
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learning_once_again/components/home_user_item.dart';

class BuildChatsList extends StatefulWidget {
  final FirebaseAuth auth;
  final String uid;
  const BuildChatsList({super.key, required this.auth, required this.uid});

  @override
  State<BuildChatsList> createState() => _BuildChatsListState();
}

class _BuildChatsListState extends State<BuildChatsList> {
  late final Stream<QuerySnapshot<Object?>> _chatstream;

  @override
  void initState() {
    Query query = FirebaseFirestore.instance
        .collection('chatrooms')
        .where('participants', arrayContains: widget.uid);
    _chatstream = query.snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _chatstream,
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("Error getting user's chats: ${snapshot.error}"),
          );
        } else if (snapshot.hasData) {
          print('User has talked with ${snapshot.data!.docs.length} people');
          List<HomeUserItem> myList = [];
          for (var document in snapshot.data!.docs) {
            final data = document.data()! as Map<String, dynamic>;
            final participants = data['participants'];
            late final String receiverId;
            if (participants[0] == widget.uid) {
              receiverId = participants[1];
            } else {
              receiverId = participants[0];
            }
            final String receiverName = data[receiverId]['name'];
            final String receiverAvatar = data[receiverId]['avatar'];
            HomeUserItem person = HomeUserItem(
                name: receiverName,
                avatar: receiverAvatar,
                receiverId: receiverId);
            myList.add(person);
          }

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
                children: myList,
              ),
            ),
          );
        } else {
          debugPrint("Getting user's chats");
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
