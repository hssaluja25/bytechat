import 'package:flutter/material.dart';
import 'package:learning_once_again/pages/chat_page.dart';

class HomeUserItem extends StatelessWidget {
  final String name, avatar, receiverId;
  const HomeUserItem(
      {super.key,
      required this.name,
      required this.avatar,
      required this.receiverId});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 5),
      title: Text(name),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(avatar),
        radius: 30,
      ),
      onTap: () {
        // Go to user's chat page
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChatPage(
                    receiverName: name,
                    receiverAvatar: avatar,
                    receiverUserID: receiverId,
                  )),
        );
      },
    );
  }
}
