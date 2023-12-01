import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learning_once_again/components/chat_bubble.dart';
import 'package:learning_once_again/components/my_textfield.dart';
import 'package:learning_once_again/providers/user_provider.dart';
import 'package:learning_once_again/services/chat_service.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage(
      {super.key,
      required this.receiverName,
      required this.receiverUserID,
      required this.receiverAvatar});
  final String receiverName;
  final String receiverUserID;
  final String receiverAvatar;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController msgController = TextEditingController();
  late final ChatService chatService;
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void didChangeDependencies() {
    // Why am i using didChangeDependencies?
    // Because Provider is not generally used outside the build method.
    // If i write the following code in initState, when the user changes their name
    // the provider in the initState would not work (initState is only called once).
    // Hence, we use didChangeDependencies.
    chatService = ChatService(
        currentUserName: Provider.of<UserProvider>(context).name,
        currentUserAvatar: Provider.of<UserProvider>(context).avatar,
        receiverName: widget.receiverName,
        receiverAvatar: widget.receiverAvatar);
    super.didChangeDependencies();
  }

  void sendMessage() async {
    if (msgController.text.isNotEmpty) {
      await chatService.sendMessage(
          message: msgController.text, receiverId: widget.receiverUserID);
      msgController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.receiverName)),
      body: Column(
        children: [
          Expanded(child: buildMessagesList()),
          buildMsgInput(),
          const SizedBox(height: 25),
        ],
      ),
    );
  }

  Widget buildMessagesList() {
    return StreamBuilder(
      stream: chatService.getMessages(
          userId: widget.receiverUserID, otherUserId: auth.currentUser!.uid),
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
        if (snapshot.hasError) {
          return Text('Error getting user messages: $snapshot.error');
        } else if (snapshot.hasData) {
          return ListView(
            children: snapshot.data!.docs
                .map((document) => buildMessagesItem(document: document))
                .toList(),
          );
        } else {
          debugPrint('Getting user messages');
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget buildMessagesItem({required DocumentSnapshot document}) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    // Align message to the right for current user and to the left for other user
    var alignment = (data['senderId'] == auth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;
    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: (data['senderId'] == auth.currentUser!.uid)
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          mainAxisAlignment: (data['senderId'] == auth.currentUser!.uid)
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Text(data['senderEmail']),
            const SizedBox(height: 5),
            ChatBubble(message: data['message']),
          ],
        ),
      ),
    );
  }

  Widget buildMsgInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: [
          Expanded(
            child: MyTextField(
              controller: msgController,
              hintText: 'Enter message',
              obscureText: false,
            ),
          ),
          // Send button
          IconButton(
            onPressed: sendMessage,
            icon: const Icon(
              Icons.arrow_upward,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }
}
