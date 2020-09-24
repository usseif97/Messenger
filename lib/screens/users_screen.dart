import 'package:chat_app/widgets/contacts/users.dart';
import 'package:chat_app/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UsersScreen extends StatefulWidget {
  UsersScreen();

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _auth = FirebaseAuth.instance;
  dynamic _userImage;
  String userID = '';
  bool _disposed = false;

  ThemeProvider themeProvider;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  // Called when this object is removed from the tree permanently.
  // The framework calls this method when this State object will never build again.
  // After the framework calls dispose
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _getData() async {
    final FirebaseUser user = await _auth.currentUser();
    String uid = user.uid;
    if (!_disposed) {
      setState(() {
        userID = uid;
      });
    }
    print('userID: $userID');
    await Firestore.instance
        .collection('users')
        .getDocuments()
        .then((querySnapShot) {
      querySnapShot.documents.forEach((result) {
        print('uid: $uid');
        if (result.data['id'] == uid && uid != null) {
          print(result.data);
          if (!_disposed) {
            setState(() {
              _userImage = result.data['userImage'];
            });
          }
        }
        //print(result.data);
      });
    });
  }

  void _logOut() async {
    //final FirebaseUser user = await _auth.currentUser();
    //String uid = user.uid;
    print('uid: $userID');
    try {
      await Firestore.instance
          .collection('users')
          .document(userID)
          .updateData({'status': 'offline'});
      print('done');
    } catch (e) {
      print(e.toString());
    }
  }

  void selectMode(BuildContext ctx) {
    Navigator.of(ctx).pushNamed('/mode');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(),
        title: Text(
          'Chats',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 35,
          ),
        ),
        actions: <Widget>[
          Container(
            child: Icon(
              Icons.camera_alt,
            ),
            margin: const EdgeInsets.all(8),
          ),
          GestureDetector(
            child: Container(
              child: Icon(
                Icons.edit,
              ),
              margin: const EdgeInsets.all(8),
            ),
            onTap: () => selectMode(context),
          ),
          GestureDetector(
            child: Container(
              child: Icon(
                Icons.exit_to_app,
              ),
              margin: const EdgeInsets.all(8),
            ),
            onTap: () {
              _logOut();
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
        leading: Container(
          margin: const EdgeInsets.all(5),
          child: CircleAvatar(
            backgroundImage: _userImage == null
                ? AssetImage('assets/images/user.jpg')
                : NetworkImage(_userImage),
          ),
        ),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Users(userID),
            ),
          ],
        ),
      ),
    );
  }
}
