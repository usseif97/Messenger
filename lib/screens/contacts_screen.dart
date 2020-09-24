import 'package:chat_app/models/contactModel.dart';
import 'package:chat_app/providers/theme_provider.dart';
import 'package:chat_app/widgets/contacts/contacts.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ContactsScreen extends StatefulWidget {
  ContactsScreen({Key key}) : super(key: key);

  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final _auth = FirebaseAuth.instance;
  dynamic _userImage;
  String userID = '';
  bool finished = false;
  bool _disposed = false;

  List<ContactModel> contactsList = [];
  dynamic currentUserInfo;

  ThemeProvider themeProvider;

  @override
  void initState() {
    super.initState();
    _getData();
    _contactsList();
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
          /*setState(() {
            currentUserInfo = result.data;
          });*/
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

  void _contactsList() async {
    print('_mastersList Function');

    /*setState(() {
      finished = false;
    });*/
    finished = false;

    QuerySnapshot querySnapshot =
        await Firestore.instance.collection("contacts").getDocuments();

    List listOfMasters = querySnapshot.documents;

    //print('listOfMasters.length: ${listOfMasters.length}');

    for (int i = 0; i < listOfMasters.length; i++) {
      if (listOfMasters[i].documentID.toString() == userID) {
        Firestore.instance
            .collection("contacts")
            .document(listOfMasters[i].documentID.toString())
            .collection("friends")
            .orderBy('date', descending: true)
            .snapshots()
            .listen(_createListofcontacts);
      }
    }
  }

  void _createListofcontacts(QuerySnapshot snapshot) async {
    var docs = snapshot.documents;
    if (!_disposed) {
      setState(() {
        contactsList.clear();
      });
    }
    for (var Doc in docs) {
      contactsList.add(ContactModel.fromFireStore(Doc));
    }
    print('contactsList.length: ${contactsList.length}');
    if (!_disposed) {
      setState(() {
        finished = true;
      });
    }
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
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey[300],
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(25),
                ),
              ),
              child: TextField(
                decoration: InputDecoration(
                  prefix: Icon(
                    Icons.search,
                  ),
                  hintText: 'Search',
                  border: InputBorder.none,
                ),
              ),
            ),
            Container(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 8,
                itemBuilder: (ctx, index) => buildStory(),
              ),
            ),
            Expanded(
              child: Contacts(userID, finished == true ? contactsList : []),
            ),
          ],
        ),
      ),
    );
  }

  Container buildStory() {
    return Container(
      width: 80,
      height: 100,
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          CircleAvatar(
            backgroundColor: Colors.grey[100],
            child: Icon(
              Icons.add,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            "Your Story",
          )
        ],
      ),
    );
  }
}
