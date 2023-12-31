import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learning_once_again/models/message.dart';
import 'package:audioplayers/audioplayers.dart';

// Used for sending and reading messages
class ChatService extends ChangeNotifier {
  final String currentUserAvatar, currentUserName, receiverAvatar, receiverName;
  ChatService({
    required this.currentUserAvatar,
    required this.currentUserName,
    required this.receiverAvatar,
    required this.receiverName,
  });
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Send message
  Future<void> sendMessage(
      {required String receiverId,
      required String message,
      required bool playSound}) async {
    if (playSound) {
      final player = AudioPlayer();
      await player.play(AssetSource('audio/msg-sent.mp3'));
    }

    // get current user info
    final String currentUserId = auth.currentUser!.uid;
    final String currentUserEmail = auth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    // create a new msg
    Message newmsg = Message(
        senderId: currentUserId,
        senderEmail: currentUserEmail,
        receiverId: receiverId,
        message: message,
        timestamp: timestamp);

    // construct chat room id from current user and receiver user (sorted to ensure uniqueness)
    List<String> ids = [currentUserId, receiverId];
    // So that chat room id remains the same for the same 2 people
    ids.sort();
    String chatRoomId = ids.join("_");

    // add msg to db
    await firestore
        .collection('chatrooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newmsg.toMap());
    await firestore.collection('chatrooms').doc(chatRoomId).set({
      'participants': ids,
      currentUserId: {
        'name': currentUserName,
        'avatar': currentUserAvatar,
      },
      receiverId: {
        'name': receiverName,
        'avatar': receiverAvatar,
      },
      'timestamp': timestamp,
    });
  }

  // Get all messages between 2 users
  Stream<QuerySnapshot> getMessages(
      {required String userId, required String otherUserId}) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomID = ids.join("_");
    return firestore
        .collection('chatrooms')
        .doc(chatRoomID)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
