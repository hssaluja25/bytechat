import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:learning_once_again/providers/user_provider.dart';
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

  bool conversationTones = true;
  bool msgNotifications = true;
  // Select notification sound
  String? notificationTone;

  @override
  Widget build(BuildContext context) {
    double ht = MediaQuery.of(context).size.height;
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
                margin: const EdgeInsets.only(top: 50),
                child: Column(
                  children: [
                    // Avatar
                    GestureDetector(
                      onTap: () async {
                        final result = await FilePicker.platform
                            .pickFiles(type: FileType.image);
                        if (result == null) {
                          // No file selected
                        } else {
                          print(result);
                        }
                      },
                      child: CircleAvatar(
                        backgroundImage:
                            const AssetImage('assets/images/me.jpg'),
                        radius: 70,
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
                                    final doc = FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(widget.uid);
                                    Provider.of<UserProvider>(context,
                                            listen: false)
                                        .name = _nameController.text;
                                    await doc.update({
                                      'name': _nameController.text,
                                    });
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
                              style: const TextStyle(
                                fontSize: 25,
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
                                    decoration: const InputDecoration(
                                      hintText: '💼 At work',
                                      focusedBorder: UnderlineInputBorder(),
                                      enabledBorder: UnderlineInputBorder(),
                                    ),
                                    cursorColor: Colors.black,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
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
                          : const Text(
                              '💼 At work',
                              style: TextStyle(
                                  fontSize: 20, fontFamily: 'latoreg'),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Notifications Card
          Positioned(
            height: ht * 0.39,
            left: 40,
            top: 300,
            right: 40,
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
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          conversationTones = !conversationTones;
                        });
                      },
                      child: ListTile(
                        title: const Text(
                          'Conversation Tones',
                          style: TextStyle(
                            fontSize: 19,
                            fontFamily: 'latoreg',
                          ),
                        ),
                        subtitle: const Text(
                          'Play sounds for incoming and outgoing messages.',
                          style: TextStyle(fontSize: 12),
                        ),
                        trailing: CupertinoSwitch(
                          value: conversationTones,
                          onChanged: (newVal) {
                            setState(() {
                              conversationTones = newVal;
                            });
                          },
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          msgNotifications = !msgNotifications;
                        });
                      },
                      child: ListTile(
                        title: const Text(
                          'Message Notifications',
                          style: TextStyle(
                            fontSize: 19,
                            fontFamily: 'latoreg',
                          ),
                        ),
                        subtitle: const Text(
                          'Get notified when new messages arrive.',
                          style: TextStyle(fontSize: 12),
                        ),
                        trailing: CupertinoSwitch(
                          value: msgNotifications,
                          onChanged: (newVal) {
                            setState(() {
                              msgNotifications = newVal;
                            });
                          },
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Notification Tone'),
                                titleTextStyle: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                                content: StatefulBuilder(
                                  builder: (BuildContext context,
                                      StateSetter setState) {
                                    return SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          RadioListTile(
                                            title:
                                                const Text('Default Ringtone'),
                                            value: 'default',
                                            groupValue: notificationTone,
                                            onChanged: (newValue) {
                                              setState(() {
                                                notificationTone =
                                                    newValue ?? '';
                                              });
                                            },
                                          ),
                                          RadioListTile(
                                            title: const Text('None'),
                                            value: 'none',
                                            groupValue: notificationTone,
                                            onChanged: (newVal) {
                                              setState(() {
                                                notificationTone = newVal ?? '';
                                              });
                                            },
                                          ),
                                          RadioListTile(
                                            title: const Text('Argon'),
                                            value: 'argon',
                                            groupValue: notificationTone,
                                            onChanged: (newV) {
                                              setState(() {
                                                notificationTone = newV ?? '';
                                              });
                                            },
                                          ),
                                          RadioListTile(
                                            title: const Text('Attentive'),
                                            value: 'attentive',
                                            groupValue: notificationTone,
                                            onChanged: (newV) {
                                              setState(() {
                                                notificationTone = newV ?? '';
                                              });
                                            },
                                          ),
                                          RadioListTile(
                                            title: const Text('BeepBeep'),
                                            value: 'beepbeep',
                                            groupValue: notificationTone,
                                            onChanged: (newV) {
                                              setState(() {
                                                notificationTone = newV ?? '';
                                              });
                                            },
                                          ),
                                          RadioListTile(
                                            title: const Text('bird'),
                                            value: 'bird',
                                            groupValue: notificationTone,
                                            onChanged: (newV) {
                                              setState(() {
                                                notificationTone = newV ?? '';
                                              });
                                            },
                                          ),
                                          RadioListTile(
                                            title: const Text('buzzer'),
                                            value: 'buzzer',
                                            groupValue: notificationTone,
                                            onChanged: (newV) {
                                              setState(() {
                                                notificationTone = newV ?? '';
                                              });
                                            },
                                          ),
                                          RadioListTile(
                                            title: const Text('carbon'),
                                            value: 'carbon',
                                            groupValue: notificationTone,
                                            onChanged: (newV) {
                                              setState(() {
                                                notificationTone = newV ?? '';
                                              });
                                            },
                                          ),
                                          RadioListTile(
                                            title: const Text('Chime'),
                                            value: 'chime',
                                            groupValue: notificationTone,
                                            onChanged: (newV) {
                                              setState(() {
                                                notificationTone = newV ?? '';
                                              });
                                            },
                                          ),
                                          RadioListTile(
                                            title: const Text('Clear'),
                                            value: 'clear',
                                            groupValue: notificationTone,
                                            onChanged: (newV) {
                                              setState(() {
                                                notificationTone = newV ?? '';
                                              });
                                            },
                                          ),
                                          RadioListTile(
                                            title: const Text('Element'),
                                            value: 'element',
                                            groupValue: notificationTone,
                                            onChanged: (newV) {
                                              setState(() {
                                                notificationTone = newV ?? '';
                                              });
                                            },
                                          ),
                                          RadioListTile(
                                            title: const Text('Helium'),
                                            value: 'helium',
                                            groupValue: notificationTone,
                                            onChanged: (newV) {
                                              setState(() {
                                                notificationTone = newV ?? '';
                                              });
                                            },
                                          ),
                                          RadioListTile(
                                            title: const Text('Hello'),
                                            value: 'hello',
                                            groupValue: notificationTone,
                                            onChanged: (newV) {
                                              setState(() {
                                                notificationTone = newV ?? '';
                                              });
                                            },
                                          ),
                                          RadioListTile(
                                            title: const Text('Ivory'),
                                            value: 'ivory',
                                            groupValue: notificationTone,
                                            onChanged: (newV) {
                                              setState(() {
                                                notificationTone = newV ?? '';
                                              });
                                            },
                                          ),
                                          RadioListTile(
                                            title: const Text('Krypton'),
                                            value: 'Krypton',
                                            groupValue: notificationTone,
                                            onChanged: (newV) {
                                              setState(() {
                                                notificationTone = newV ?? '';
                                              });
                                            },
                                          ),
                                          RadioListTile(
                                            title: const Text('Natural'),
                                            value: 'natural',
                                            groupValue: notificationTone,
                                            onChanged: (newV) {
                                              setState(() {
                                                notificationTone = newV ?? '';
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('OK'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              );
                            });
                      },
                      child: const ListTile(
                        title: Text(
                          'Notification Sound',
                          style: TextStyle(
                            fontSize: 19,
                            fontFamily: 'latoreg',
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final feedbackUri = Uri.parse(
                            'mailto:hssaluja2508@gmail.com?subject=ByteChat Feeback');
                        launchUrl(feedbackUri);
                      },
                      child: const ListTile(
                        title: Text(
                          'Give Feedback',
                          style: TextStyle(
                            fontSize: 19,
                            fontFamily: 'latoreg',
                          ),
                        ),
                        subtitle: Text(
                          'Share your thoughts and help us improve!',
                          style: TextStyle(fontSize: 12),
                        ),
                        trailing: FaIcon(FontAwesomeIcons.rightFromBracket),
                        // trailing: Icon(Icons.outbond_outlined),
                      ),
                    ),
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
                      child: const ListTile(
                        title: Text(
                          'About App',
                          style: TextStyle(
                            fontSize: 19,
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
            bottom: 40,
            left: 38,
            right: 38,
            child: Column(
              children: [
                const Text(
                  'Invite a Friend',
                  style: TextStyle(fontSize: 27, fontFamily: 'latoreg'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
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
                      child: const CircleAvatar(
                        backgroundImage: AssetImage(
                          'assets/images/profile4.jpg',
                        ),
                        radius: 35,
                      ),
                    ),
                    const SizedBox(width: 10),
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
                      child: const CircleAvatar(
                        backgroundImage: AssetImage(
                          'assets/images/profile.avif',
                        ),
                        radius: 35,
                      ),
                    ),
                    const SizedBox(width: 10),
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
                      child: const CircleAvatar(
                        backgroundImage: AssetImage(
                          'assets/images/profile3.jpg',
                        ),
                        radius: 35,
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
                      child: const Text('Invite Now'),
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
