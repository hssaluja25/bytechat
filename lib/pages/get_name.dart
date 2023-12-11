import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:learning_once_again/components/my_textfield.dart';
import 'package:learning_once_again/pages/home_page.dart';
import 'package:learning_once_again/providers/chat_provider.dart';
import 'package:learning_once_again/providers/user_provider.dart';
import 'package:provider/provider.dart';

class GetName extends StatefulWidget {
  const GetName(
      {super.key,
      required this.name,
      required this.auth,
      required this.email,
      required this.uid});
  final String name;
  final String email;
  final String uid;
  final FirebaseAuth auth;

  @override
  State<GetName> createState() => _GetNameState();
}

class _GetNameState extends State<GetName> {
  final TextEditingController nameController = TextEditingController();
  bool gottenName = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final Future fetchUserDoc;
  late final DocumentReference userRef;
  String downloadUrl = '';

  @override
  void initState() {
    super.initState();
    userRef = _firestore.collection('users').doc(widget.uid);
    fetchUserDoc = userRef.get();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchUserDoc,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          // Will this work? if we use setState inside build?
          if (snapshot.data.exists) {
            gottenName = true;
          }
          return gottenName
              ? ChangeNotifierProvider(
                  create: (context) => ChatProvider(),
                  child: Home(auth: widget.auth, uid: widget.uid),
                )
              : Scaffold(
                  appBar: AppBar(
                    title: const Text('About You'),
                    actions: [
                      InkWell(
                        onTap: () {
                          userRef.set({
                            'uid': widget.uid,
                            'email': widget.email,
                            'name': nameController.text,
                            'status': 'Hey there! 👋',
                            'avatar': downloadUrl.isEmpty
                                ? 'https://firebasestorage.googleapis.com/v0/b/learing-auth-mkay.appspot.com/o/images%2Fprofile_pictures%2Fdefault.png?alt=media&token=9771cf0b-9fa3-4b87-bb2b-21013636a2a5'
                                : downloadUrl,
                            'conversationTone': true,
                            'enterIsSend': false,
                          });
                          setState(() {
                            gottenName = true;
                          });
                        },
                        child: const SizedBox(
                          height: 50,
                          width: 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(
                                FontAwesomeIcons.check,
                                size: 18,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Done',
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  body: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 15),
                            child: const Text(
                              'Name',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          Expanded(
                            child: MyTextField(
                              controller: nameController,
                              hintText: widget.name,
                              obscureText: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 50),
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 15),
                            child: const Text(
                              'Avatar',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          const SizedBox(width: 100),
                          GestureDetector(
                            onTap: () async {
                              final result = await FilePicker.platform
                                  .pickFiles(type: FileType.image);
                              if (result == null) {
                                // No file selected; do nothing
                              } else {
                                print('user has picked file');
                                final storage = FirebaseStorage.instance.ref();
                                final images = storage.child("images");
                                final profiles =
                                    images.child("profile_pictures");

                                // Show the processing snackbar for a long time and after the process is complete, remove the snackbar
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor:
                                        Color.fromARGB(255, 226, 1, 87),
                                    content: Text('Processing'),
                                    duration: Duration(minutes: 5),
                                  ),
                                );
                                final file = result.files.first;
                                final userProfile = profiles.child(widget.uid);
                                final localFilePath = file.path;
                                final uploadFile = File(localFilePath ?? '');
                                // Upload to firebase storage and get the URL for the file
                                await userProfile.putFile(uploadFile);
                                final String myDownloadUrl =
                                    await userProfile.getDownloadURL();
                                print(myDownloadUrl);
                                setState(() {
                                  downloadUrl = myDownloadUrl;
                                });
                                // change the avatar
                                Provider.of<UserProvider>(context,
                                        listen: false)
                                    .avatar = downloadUrl;
                                ScaffoldMessenger.of(context)
                                    .removeCurrentSnackBar();
                              }
                            },
                            child: downloadUrl.isEmpty
                                ? const CircleAvatar(
                                    backgroundImage: AssetImage(
                                        'assets/images/blank_avatar.png'),
                                    radius: 70,
                                  )
                                : CircleAvatar(
                                    backgroundImage: NetworkImage(downloadUrl),
                                    radius: 70,
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
        } else if (snapshot.hasError) {
          debugPrint(
              'There was an error looking for user doc. This is unusual.');
          return const Scaffold(
            body: Center(
              child: Text('An error occured.'),
            ),
          );
        } else {
          debugPrint('Fetching user doc');
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
