import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:learning_once_again/pages/account_page.dart';
import 'package:learning_once_again/pages/select_contact.dart';
import 'package:learning_once_again/pages/chat_page.dart';
import 'package:learning_once_again/services/auth.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.auth});
  final FirebaseAuth auth;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool unreadChats = true;
  @override
  Widget build(BuildContext context) {
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
                Container(
                  margin: const EdgeInsets.only(left: 35),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AccountInfo(),
                        ),
                      );
                    },
                    child: const CircleAvatar(
                      backgroundImage: AssetImage('assets/images/me.jpg'),
                      radius: 50,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 30),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AccountInfo(),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        const Text(
                          'Harpreet',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '💼 At work',
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
                IconButton(
                  icon: const Icon(
                    Icons.search,
                    size: 35,
                  ),
                  onPressed: () {},
                ),
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
                          title: Text('Account'),
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
                          builder: (context) => const AccountInfo(),
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
                      '34',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
              ],
            ),
            // Show the chats
            BuildUsersList(auth: widget.auth),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF4064fc),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SelectContact()),
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

// Display all users except the current one
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

class UserItem extends StatelessWidget {
  late final Map<String, dynamic> data;
  UserItem({super.key, required this.auth, required this.document}) {
    data = document.data()! as Map<String, dynamic>;
  }

  final FirebaseAuth auth;
  final DocumentSnapshot document;
  @override
  Widget build(BuildContext context) {
    if (auth.currentUser!.email != data['email']) {
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 5),
        title: Text(data['name']),
        leading: const CircleAvatar(
          backgroundImage: AssetImage('assets/images/me.jpg'),
          radius: 30,
        ),
        onTap: () {
          // Go to user's chat page
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatPage(
                      receiverName: data['name'],
                      receiverUserID: data['uid'],
                    )),
          );
        },
      );
    } else {
      return Container();
    }
  }
}
