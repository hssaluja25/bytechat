import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:learning_once_again/components/my_textfield.dart';
import 'package:learning_once_again/pages/home_page.dart';

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
              ? Home(auth: widget.auth, uid: widget.uid)
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
