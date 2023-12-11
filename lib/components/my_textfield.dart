import 'package:flutter/material.dart';
import 'package:learning_once_again/providers/user_provider.dart';
import 'package:learning_once_again/services/chat_service.dart';
import 'package:provider/provider.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextEditingController? passwordController;
  final ChatService? chatService;
  final String? receiverId;
  final bool? playSound;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.passwordController,
    this.chatService,
    this.receiverId,
    this.playSound,
  });

  @override
  Widget build(BuildContext context) {
    bool enterIsSend = Provider.of<UserProvider>(context).enterIsSend;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextFormField(
        validator: (String? value) {
          if (value == null || value.isEmpty) {
            return 'Value cannot be empty';
          } else if ((hintText == 'Password' ||
                  hintText == 'Confirm password') &&
              controller.text.length < 8) {
            return 'Password too short';
          } else if (hintText == 'Username' &&
              !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                  .hasMatch(controller.text)) {
            return 'Invalid email';
          } else if (hintText == 'Confirm password' &&
              value != passwordController?.text) {
            return 'Passwords do not match';
          }
          return null;
        },
        controller: controller,
        obscureText: obscureText,
        onFieldSubmitted: (String text) async {
          if (enterIsSend) {
            if (hintText == 'Enter message') {
              if (controller.text.isNotEmpty) {
                await chatService?.sendMessage(
                  message: controller.text,
                  receiverId: receiverId ?? '',
                  playSound: playSound ?? true,
                );
                controller.clear();
              }
            }
          }
        },
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          fillColor: Colors.grey.shade200,
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
      ),
    );
  }
}
