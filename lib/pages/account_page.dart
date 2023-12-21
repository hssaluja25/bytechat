import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:learning_once_again/providers/user_provider.dart';
import 'package:learning_once_again/services/local_auth_api.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountInfo extends StatefulWidget {
  const AccountInfo({super.key, required this.uid});
  final String uid;

  @override
  State<AccountInfo> createState() => _AccountInfoState();
}

class _AccountInfoState extends State<AccountInfo> {
  final nameFocusNode = FocusNode();
  final statusFocusNode = FocusNode();
  bool showStatusTextField = false;
  bool showNameTextField = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();

  // Select notification sound
  String? notificationTone;

  @override
  Widget build(BuildContext context) {
    double ht = MediaQuery.of(context).size.height;
    double wd = MediaQuery.of(context).size.width;
    bool conversationTones = Provider.of<UserProvider>(context).play;
    bool enterIsSend = Provider.of<UserProvider>(context).enterIsSend;
    bool authenticate = Provider.of<UserProvider>(context).authenticate;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
        backgroundColor: const Color(0xFF4064fc),
        title: const Text(
          'Preferences',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          // The white section at the very bottom
          Container(color: const Color(0xFFf8f4fc)),
          // The blue section containing avatar, name and status
          Container(
            height: ht * 0.4,
            decoration: const BoxDecoration(
              color: Color(0xFF4064fc),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Center(
              child: Container(
                margin: ht > 850
                    ? const EdgeInsets.only(top: 50)
                    : const EdgeInsets.only(top: 25),
                child: Column(
                  children: [
                    // Avatar
                    Hero(
                      tag: 'profile',
                      child: GestureDetector(
                        onTap: () async {
                          final storage = FirebaseStorage.instance.ref();
                          final images = storage.child("images");
                          final profiles = images.child("profile_pictures");

                          final result = await FilePicker.platform
                              .pickFiles(type: FileType.image);
                          if (result == null) {
                            // No file selected; do nothing
                          } else {
                            print('user has picked file');
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
                            final String downloadUrl =
                                await userProfile.getDownloadURL();
                            print(downloadUrl);
                            // change the avatar
                            Provider.of<UserProvider>(context, listen: false)
                                .avatar = downloadUrl;
                            // change the avatar on firestore
                            final docUser = FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.uid);
                            await docUser.update({'avatar': downloadUrl});
                            ScaffoldMessenger.of(context)
                                .removeCurrentSnackBar();
                          }
                        },
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                              Provider.of<UserProvider>(context).avatar),
                          radius: ht > 850 ? 70 : 60,
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color.fromARGB(255, 226, 1, 87),
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Some Padding
                    const SizedBox(height: 10),
                    // Name
                    GestureDetector(
                      onTap: () {
                        nameFocusNode.requestFocus();
                        setState(() {
                          showNameTextField = true;
                        });
                      },
                      child: showNameTextField
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: TextField(
                                    controller: _nameController,
                                    focusNode: nameFocusNode,
                                    cursorHeight: 30,
                                    decoration: InputDecoration(
                                      hintText:
                                          Provider.of<UserProvider>(context)
                                              .name,
                                      focusedBorder:
                                          const UnderlineInputBorder(),
                                      enabledBorder:
                                          const UnderlineInputBorder(),
                                    ),
                                    cursorColor: Colors.black,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    debugPrint(
                                        'Inside the code to change the username');
                                    // If user didn't type anything, don't do anything
                                    if (_nameController.text.isNotEmpty) {
                                      final doc = FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(widget.uid);
                                      Provider.of<UserProvider>(context,
                                              listen: false)
                                          .name = _nameController.text;
                                      await doc.update({
                                        'name': _nameController.text,
                                      });
                                    }
                                    setState(() {
                                      showNameTextField = false;
                                    });
                                  },
                                  icon: const FaIcon(
                                    FontAwesomeIcons.check,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              Provider.of<UserProvider>(context).name,
                              style: TextStyle(
                                fontSize: ht > 850 ? 25 : 20,
                                fontFamily: 'latoreg',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    // Status
                    GestureDetector(
                      onTap: () {
                        statusFocusNode.requestFocus();
                        setState(() {
                          showStatusTextField = true;
                        });
                      },
                      child: showStatusTextField
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: TextField(
                                    controller: _statusController,
                                    focusNode: statusFocusNode,
                                    cursorHeight: 30,
                                    decoration: InputDecoration(
                                      hintText:
                                          Provider.of<UserProvider>(context)
                                              .status,
                                      focusedBorder:
                                          const UnderlineInputBorder(),
                                      enabledBorder:
                                          const UnderlineInputBorder(),
                                    ),
                                    cursorColor: Colors.black,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    debugPrint(
                                        'Inside the code to change the status');
                                    // If user didn't type anything, don't do anything
                                    if (_statusController.text.isNotEmpty) {
                                      final doc = FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(widget.uid);
                                      Provider.of<UserProvider>(context,
                                              listen: false)
                                          .status = _statusController.text;
                                      await doc.update({
                                        'status': _statusController.text,
                                      });
                                    }
                                    setState(() {
                                      showStatusTextField = false;
                                    });
                                  },
                                  icon: const FaIcon(
                                    FontAwesomeIcons.check,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              Provider.of<UserProvider>(context).status,
                              style: TextStyle(
                                fontSize: ht > 850 ? 20 : 15,
                                fontFamily: 'latoreg',
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Notifications Card
          Positioned(
            height: ht > 850 ? ht * 0.39 : ht * 0.43,
            left: wd > 400 ? 40 : 30,
            top: ht > 850 ? 300 : 235,
            right: wd > 400 ? 40 : 30,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
                borderRadius: BorderRadius.circular(50),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: [
                    // Conversation Tones
                    GestureDetector(
                      onTap: () async {
                        final docUser = FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.uid);
                        // Not using await here as it improves performance
                        docUser.update({
                          'conversationTone': !conversationTones,
                        });
                        Provider.of<UserProvider>(context, listen: false).play =
                            !conversationTones;
                      },
                      child: ListTile(
                        title: Text(
                          'Conversation Tones',
                          style: TextStyle(
                            fontSize: ht > 850 ? 19 : 15,
                            fontFamily: 'latoreg',
                          ),
                        ),
                        subtitle: const Text(
                          'Play sounds for incoming and outgoing messages.',
                          style: TextStyle(fontSize: 12),
                        ),
                        trailing: CupertinoSwitch(
                          value: conversationTones,
                          onChanged: (newVal) async {
                            debugPrint('Inside cupertino switch handler');
                            Provider.of<UserProvider>(context, listen: false)
                                .play = newVal;
                            final docUser = FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.uid);
                            await docUser.update({
                              'conversationTone': newVal,
                            });
                          },
                        ),
                      ),
                    ),
                    // Enter is Send
                    GestureDetector(
                      onTap: () {
                        final docUser = FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.uid);
                        // Not using await here as it improves performance
                        docUser.update({
                          'enterIsSend': !enterIsSend,
                        });
                        Provider.of<UserProvider>(context, listen: false)
                            .enterIsSend = !enterIsSend;
                      },
                      child: ListTile(
                        title: Text(
                          'Enter is send',
                          style: TextStyle(
                            fontSize: ht > 850 ? 19 : 15,
                            fontFamily: 'latoreg',
                          ),
                        ),
                        subtitle: const Text(
                          'Enter key will send your message',
                          style: TextStyle(fontSize: 12),
                        ),
                        trailing: CupertinoSwitch(
                          value: enterIsSend,
                          onChanged: (newVal) async {
                            debugPrint(
                                "Inside enter is send's cupertino switch handler");
                            debugPrint('User has selected $newVal');
                            Provider.of<UserProvider>(context, listen: false)
                                .enterIsSend = newVal;
                            final docUser = FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.uid);
                            await docUser.update({
                              'enterIsSend': newVal,
                            });
                          },
                        ),
                      ),
                    ),
                    // Authentication lock
                    GestureDetector(
                      onTap: () async {
                        // Update only on successful authentication
                        bool deviceSupported =
                            await LocalAuthApi.isDeviceSupported();
                        if (deviceSupported) {
                          bool autheticated = await LocalAuthApi.authenticate();
                          if (autheticated) {
                            final docUser = FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.uid);
                            docUser.update({
                              'authenticate': !authenticate,
                            });
                            Provider.of<UserProvider>(context, listen: false)
                                .authenticate = !authenticate;
                          }
                        } else {
                          showDialog(
                              barrierDismissible: true,
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text(
                                    'Set Up Authentication',
                                    style: TextStyle(fontSize: 22),
                                  ),
                                  content: const Text(
                                    "To use this feature, you'll need to set up your fingerprint or device password on your device first.",
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
                              });
                        }
                      },
                      child: ListTile(
                        title: Text(
                          'Authentication Lock',
                          style: TextStyle(
                            fontSize: ht > 850 ? 19 : 15,
                            fontFamily: 'latoreg',
                          ),
                        ),
                        subtitle: const Text(
                          'Use fingerprint or device password to open ByteChat',
                          style: TextStyle(fontSize: 12),
                        ),
                        trailing: CupertinoSwitch(
                          value: authenticate,
                          onChanged: (newVal) async {
                            debugPrint('Inside authentication lock switch');

                            // Update only on successful authentication
                            bool deviceSupported =
                                await LocalAuthApi.isDeviceSupported();
                            if (deviceSupported) {
                              bool autheticated =
                                  await LocalAuthApi.authenticate();
                              if (autheticated) {
                                debugPrint('User has selected $newVal');
                                Provider.of<UserProvider>(context,
                                        listen: false)
                                    .authenticate = newVal;
                                final docUser = FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(widget.uid);
                                await docUser.update({
                                  'authenticate': newVal,
                                });
                              }
                            } else {
                              showDialog(
                                  barrierDismissible: true,
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text(
                                        'Set Up Authentication',
                                        style: TextStyle(fontSize: 22),
                                      ),
                                      content: const Text(
                                        "To use this feature, you'll need to set up your fingerprint or device password on your device first.",
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
                                  });
                            }
                          },
                        ),
                      ),
                    ),

                    // Notification Sound
                    // GestureDetector(
                    //   onTap: () {
                    //     showDialog(
                    //         context: context,
                    //         builder: (BuildContext context) {
                    //           return AlertDialog(
                    //             title: const Text('Notification Tone'),
                    //             titleTextStyle: const TextStyle(
                    //               fontSize: 18,
                    //               color: Colors.black,
                    //             ),
                    //             content: StatefulBuilder(
                    //               builder: (BuildContext context,
                    //                   StateSetter setState) {
                    //                 return SingleChildScrollView(
                    //                   child: Column(
                    //                     children: [
                    //                       RadioListTile(
                    //                         title:
                    //                             const Text('Default Ringtone'),
                    //                         value: 'default',
                    //                         groupValue: notificationTone,
                    //                         onChanged: (newValue) {
                    //                           setState(() {
                    //                             notificationTone =
                    //                                 newValue ?? '';
                    //                           });
                    //                         },
                    //                       ),
                    //                       RadioListTile(
                    //                         title: const Text('None'),
                    //                         value: 'none',
                    //                         groupValue: notificationTone,
                    //                         onChanged: (newVal) {
                    //                           setState(() {
                    //                             notificationTone = newVal ?? '';
                    //                           });
                    //                         },
                    //                       ),
                    //                       RadioListTile(
                    //                         title: const Text('Argon'),
                    //                         value: 'argon',
                    //                         groupValue: notificationTone,
                    //                         onChanged: (newV) {
                    //                           setState(() {
                    //                             notificationTone = newV ?? '';
                    //                           });
                    //                         },
                    //                       ),
                    //                       RadioListTile(
                    //                         title: const Text('Attentive'),
                    //                         value: 'attentive',
                    //                         groupValue: notificationTone,
                    //                         onChanged: (newV) {
                    //                           setState(() {
                    //                             notificationTone = newV ?? '';
                    //                           });
                    //                         },
                    //                       ),
                    //                       RadioListTile(
                    //                         title: const Text('BeepBeep'),
                    //                         value: 'beepbeep',
                    //                         groupValue: notificationTone,
                    //                         onChanged: (newV) {
                    //                           setState(() {
                    //                             notificationTone = newV ?? '';
                    //                           });
                    //                         },
                    //                       ),
                    //                       RadioListTile(
                    //                         title: const Text('bird'),
                    //                         value: 'bird',
                    //                         groupValue: notificationTone,
                    //                         onChanged: (newV) {
                    //                           setState(() {
                    //                             notificationTone = newV ?? '';
                    //                           });
                    //                         },
                    //                       ),
                    //                       RadioListTile(
                    //                         title: const Text('buzzer'),
                    //                         value: 'buzzer',
                    //                         groupValue: notificationTone,
                    //                         onChanged: (newV) {
                    //                           setState(() {
                    //                             notificationTone = newV ?? '';
                    //                           });
                    //                         },
                    //                       ),
                    //                       RadioListTile(
                    //                         title: const Text('carbon'),
                    //                         value: 'carbon',
                    //                         groupValue: notificationTone,
                    //                         onChanged: (newV) {
                    //                           setState(() {
                    //                             notificationTone = newV ?? '';
                    //                           });
                    //                         },
                    //                       ),
                    //                       RadioListTile(
                    //                         title: const Text('Chime'),
                    //                         value: 'chime',
                    //                         groupValue: notificationTone,
                    //                         onChanged: (newV) {
                    //                           setState(() {
                    //                             notificationTone = newV ?? '';
                    //                           });
                    //                         },
                    //                       ),
                    //                       RadioListTile(
                    //                         title: const Text('Clear'),
                    //                         value: 'clear',
                    //                         groupValue: notificationTone,
                    //                         onChanged: (newV) {
                    //                           setState(() {
                    //                             notificationTone = newV ?? '';
                    //                           });
                    //                         },
                    //                       ),
                    //                       RadioListTile(
                    //                         title: const Text('Element'),
                    //                         value: 'element',
                    //                         groupValue: notificationTone,
                    //                         onChanged: (newV) {
                    //                           setState(() {
                    //                             notificationTone = newV ?? '';
                    //                           });
                    //                         },
                    //                       ),
                    //                       RadioListTile(
                    //                         title: const Text('Helium'),
                    //                         value: 'helium',
                    //                         groupValue: notificationTone,
                    //                         onChanged: (newV) {
                    //                           setState(() {
                    //                             notificationTone = newV ?? '';
                    //                           });
                    //                         },
                    //                       ),
                    //                       RadioListTile(
                    //                         title: const Text('Hello'),
                    //                         value: 'hello',
                    //                         groupValue: notificationTone,
                    //                         onChanged: (newV) {
                    //                           setState(() {
                    //                             notificationTone = newV ?? '';
                    //                           });
                    //                         },
                    //                       ),
                    //                       RadioListTile(
                    //                         title: const Text('Ivory'),
                    //                         value: 'ivory',
                    //                         groupValue: notificationTone,
                    //                         onChanged: (newV) {
                    //                           setState(() {
                    //                             notificationTone = newV ?? '';
                    //                           });
                    //                         },
                    //                       ),
                    //                       RadioListTile(
                    //                         title: const Text('Krypton'),
                    //                         value: 'Krypton',
                    //                         groupValue: notificationTone,
                    //                         onChanged: (newV) {
                    //                           setState(() {
                    //                             notificationTone = newV ?? '';
                    //                           });
                    //                         },
                    //                       ),
                    //                       RadioListTile(
                    //                         title: const Text('Natural'),
                    //                         value: 'natural',
                    //                         groupValue: notificationTone,
                    //                         onChanged: (newV) {
                    //                           setState(() {
                    //                             notificationTone = newV ?? '';
                    //                           });
                    //                         },
                    //                       ),
                    //                     ],
                    //                   ),
                    //                 );
                    //               },
                    //             ),
                    //             actions: [
                    //               TextButton(
                    //                 child: const Text('Cancel'),
                    //                 onPressed: () {
                    //                   Navigator.pop(context);
                    //                 },
                    //               ),
                    //               TextButton(
                    //                 child: const Text('OK'),
                    //                 onPressed: () {
                    //                   Navigator.pop(context);
                    //                 },
                    //               ),
                    //             ],
                    //           );
                    //         });
                    //   },
                    //   child: ListTile(
                    //     title: Text(
                    //       'Notification Sound',
                    //       style: TextStyle(
                    //         fontSize: ht > 850 ? 19 : 15,
                    //         fontFamily: 'latoreg',
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // Feedback
                    GestureDetector(
                      onTap: () async {
                        final feedbackUri = Uri.parse(
                            'mailto:hssaluja2508@gmail.com?subject=ByteChat Feeback');
                        launchUrl(feedbackUri);
                      },
                      child: ListTile(
                        title: Text(
                          'Give Feedback',
                          style: TextStyle(
                            fontSize: ht > 850 ? 19 : 15,
                            fontFamily: 'latoreg',
                          ),
                        ),
                        subtitle: const Text(
                          'Share your thoughts and help us improve!',
                          style: TextStyle(fontSize: 12),
                        ),
                        trailing:
                            const FaIcon(FontAwesomeIcons.rightFromBracket),
                      ),
                    ),
                    // About app
                    GestureDetector(
                      onTap: () {
                        showLicensePage(
                          context: context,
                          applicationName: "ByteChat",
                          applicationIcon: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.asset(
                              'assets/images/512.png',
                              height: 75,
                              width: 75,
                            ),
                          ),
                        );
                      },
                      child: ListTile(
                        title: Text(
                          'About App',
                          style: TextStyle(
                            fontSize: ht > 850 ? 19 : 15,
                            fontFamily: 'latoreg',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Invite a Friend
          Positioned(
            bottom: ht > 850 ? 40 : 20,
            left: 38,
            right: 38,
            child: Column(
              children: [
                Text(
                  'Invite a Friend',
                  style: TextStyle(
                    fontSize: ht > 850 ? 27 : 19,
                    fontFamily: 'latoreg',
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // First Person photo
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        backgroundImage: const AssetImage(
                          'assets/images/profile4.jpg',
                        ),
                        radius: ht > 850 ? 35 : 30,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Second Person photo
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        backgroundImage: const AssetImage(
                          'assets/images/profile.jpg',
                        ),
                        radius: ht > 850 ? 35 : 30,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Third person photo
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        backgroundImage: const AssetImage(
                          'assets/images/profile3.jpg',
                        ),
                        radius: ht > 850 ? 35 : 30,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        Share.share(
                          "Let's chat on ByteChat! It's a fast, simple, and secure app we can use to message each other for free. Get it at https://bytechat.com/download",
                          subject: "Let's chat on ByteChat!",
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        elevation: 4,
                      ),
                      child: Text(
                        'Invite Now',
                        style: TextStyle(
                          fontSize: wd > 400 ? 14 : 10,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
