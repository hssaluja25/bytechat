import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:learning_once_again/components/build_chats_list.dart';
import 'package:learning_once_again/pages/account_page.dart';
import 'package:learning_once_again/pages/select_contact.dart';
import 'package:learning_once_again/providers/user_provider.dart';
import 'package:learning_once_again/services/auth.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.auth, required this.uid});
  final FirebaseAuth auth;
  // Required for getting user info from Firestore
  final String uid;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool unreadChats = true;

  @override
  void initState() {
    // We are not using FutureBuilder to make the call to Firestore because
    // if we do so then when we set the name we got from Firestore in our
    // UserProvider, we get an error: Flutter setState() or markNeedsBuild()
    // called during build
    final docUser =
        FirebaseFirestore.instance.collection('users').doc(widget.uid);
    () async {
      DocumentSnapshot snapshot = await docUser.get();
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        // Setting the name in provider
        Provider.of<UserProvider>(context, listen: false).name = data['name'];
        // Setting the status in provider
        Provider.of<UserProvider>(context, listen: false).status =
            data['status'];
        // Setting the avatar in provider
        Provider.of<UserProvider>(context, listen: false).avatar =
            data['avatar'];
      } else {
        debugPrint(
            "This should never happen. There is no corresponding Firestore doc for this user. Hence, can't read username, status and avatar");
      }
    }();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String crtUserName = Provider.of<UserProvider>(context).name;
    String crtUserStatus = Provider.of<UserProvider>(context).status;
    String crtUserAvatar = Provider.of<UserProvider>(context).avatar;
    double ht = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFDCDCDF),
              Color(0xFFa5a5a5),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Space at the top
            SizedBox(height: ht * 0.080128),
            // user avatar, name, stauts, search and more settings
            Row(
              children: [
                // Avatar
                Container(
                  margin: const EdgeInsets.only(left: 35),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AccountInfo(
                            uid: widget.uid,
                          ),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                        crtUserAvatar.isEmpty
                            ? 'https://firebasestorage.googleapis.com/v0/b/learing-auth-mkay.appspot.com/o/images%2Fprofile_pictures%2Fdefault.png?alt=media&token=9771cf0b-9fa3-4b87-bb2b-21013636a2a5'
                            : crtUserAvatar,
                      ),
                      radius: 50,
                    ),
                  ),
                ),
                // Name and status in a column
                Container(
                  margin: const EdgeInsets.only(left: 30),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AccountInfo(uid: widget.uid),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 150),
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text(
                              crtUserName.isEmpty ? 'username' : crtUserName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          crtUserStatus.isEmpty
                              ? 'Hey there! 👋'
                              : crtUserStatus,
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                // Search btn
                IconButton(
                  icon: const Icon(
                    Icons.search,
                    size: 35,
                  ),
                  onPressed: () {},
                ),
                // More options
                PopupMenuButton(
                  iconSize: 35,
                  offset: const Offset(0, 45),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  itemBuilder: (BuildContext context) {
                    return const [
                      PopupMenuItem(
                        value: 'profile',
                        child: ListTile(
                          leading: FaIcon(
                            FontAwesomeIcons.solidUser,
                            size: 20,
                          ),
                          title: Text('Preferences'),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'logout',
                        child: ListTile(
                          leading: Icon(Icons.logout),
                          title: Text('Logout'),
                        ),
                      ),
                    ];
                  },
                  onSelected: (String newValue) async {
                    print('User selected $newValue');
                    if (newValue == 'logout') {
                      print("Inside logout");
                      try {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            });
                        await Auth(auth: widget.auth).signOut();
                        // To remove CPI
                        if (!context.mounted) return;
                        Navigator.pop(context);
                      } on Exception catch (error) {
                        print(error);
                        // Remove CPI
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        showDialog(
                          barrierDismissible: true,
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: const Text(
                                "Couldn't log out. Please try again later.",
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
                          },
                        );
                      }
                    } else if (newValue == 'profile') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AccountInfo(uid: widget.uid),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            // Space below account info
            SizedBox(height: ht * 0.0213675),
            // Chat heading and number of unread chats
            Row(
              children: [
                const SizedBox(width: 25),
                const Text(
                  'Chat',
                  style: TextStyle(
                    fontSize: 42,
                    fontFamily: 'lazare',
                  ),
                  textAlign: TextAlign.left,
                ),
                if (unreadChats)
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    padding: const EdgeInsets.all(9),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const Text(
                      '7',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
              ],
            ),
            // Show the chats
            BuildChatsList(auth: widget.auth, uid: widget.uid),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF4064fc),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SelectContact(auth: widget.auth)),
          );
        },
        icon: const FaIcon(
          FontAwesomeIcons.commentDots,
          color: Colors.white,
        ),
        label: const Text(
          'New chat',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
