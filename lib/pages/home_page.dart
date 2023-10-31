import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:learning_once_again/components/build_users_list.dart';
import 'package:learning_once_again/pages/account_page.dart';
import 'package:learning_once_again/pages/select_contact.dart';
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
                          'Current User',
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
