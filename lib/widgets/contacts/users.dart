import 'package:chat_app/models/userModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Users extends StatefulWidget {
  final String userid;
  Users(this.userid);
  @override
  _UsersState createState() => _UsersState();
}

class _UsersState extends State<Users> {
  final _auth = FirebaseAuth.instance;
  bool _disposed = false;

  List<String> friendsIDs = [];
  bool finished = false;

  dynamic currentUserInfo;
  List<UserModel> usersList = [];

  @override
  void initState() {
    super.initState();
    _getFriends(); // Get the current user info then Render my Friends
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void addFriend(int index, final doc) async {
    print('Add Friend');

    // Me Add Friend
    try {
      await Firestore.instance
          .collection('contacts')
          .document(widget.userid)
          .setData({'exist': 'yes'});
    } catch (error) {
      print(error.toString());
    }
    try {
      await Firestore.instance
          .collection('contacts')
          .document(widget.userid)
          .collection('friends')
          .document(doc[index]['id'])
          .setData({
        'username': doc[index]['username'],
        'email': doc[index]['email'],
        'id': doc[index]['id'],
        'userImage': doc[index]['userImage'],
        'status': doc[index]['status'],
        'chat': 'Say Hii',
        'date': DateTime.now().toString(),
      });
    } catch (error) {
      print(error.toString());
    }

    // Friend Accept me
    try {
      await Firestore.instance
          .collection('contacts')
          .document(doc[index]['id'])
          .setData({'exist': 'yes'});
    } catch (error) {
      print(error.toString());
    }
    try {
      await Firestore.instance
          .collection('contacts')
          .document(doc[index]['id'])
          .collection('friends')
          .document(widget.userid)
          .setData({
        'username': currentUserInfo['username'],
        'email': currentUserInfo['email'],
        'id': currentUserInfo['id'],
        'userImage': currentUserInfo['userImage'],
        'status': currentUserInfo['status'],
        'chat': 'Say Hii',
        'date': DateTime.now().toString(),
      });

      // Current User Chats to Friend
      try {
        await Firestore.instance
            .collection('chat')
            .document(widget.userid)
            .setData({'exist': 'yes'});
      } catch (error) {
        print(error.toString());
      }
      try {
        await Firestore.instance
            .collection('chat')
            .document(widget.userid)
            .collection('friends')
            .document(doc[index]['id'])
            .setData({'exist': 'yes'});
      } catch (error) {
        print(error.toString());
      }

      // Friend chats Current User
      try {
        await Firestore.instance
            .collection('chat')
            .document(doc[index]['id'])
            .setData({'exist': 'yes'});
      } catch (error) {
        print(error.toString());
      }
      try {
        await Firestore.instance
            .collection('chat')
            .document(doc[index]['id'])
            .collection('friends')
            .document(widget.userid)
            .setData({'exist': 'yes'});
      } catch (error) {
        print(error.toString());
      }

      _getFriends();
    } catch (error) {
      print(error.toString());
    }
  }

  bool checkFriend(String id) {
    for (int i = 0; i < friendsIDs.length; i++) {
      if (id == friendsIDs[i]) {
        return true;
      }
    }
    return false;
  }

  void _getFriends() async {
    print('_mastersList Function');

    final FirebaseUser user = await _auth.currentUser();
    String uid = user.uid;

    /*setState(() {
      finished = false;
    });*/
    finished = false;

    await Firestore.instance
        .collection('users')
        .getDocuments()
        .then((querySnapShot) {
      querySnapShot.documents.forEach((result) {
        print('uid: $uid');
        if (result.data['id'] == uid && uid != null) {
          print(result.data);
          setState(() {
            currentUserInfo = result.data;
          });
        }
        //print(result.data);
      });
    });

    QuerySnapshot querySnapshot = await Firestore.instance
        .collection("contacts")
        .document(uid)
        .collection('friends')
        .getDocuments();

    List listOfIDs = querySnapshot.documents;
    List<String> iDs = ['0'];

    for (int i = 0; i < listOfIDs.length; i++) {
      iDs.add(listOfIDs[i].documentID.toString());
    }
    print('iDs: $iDs');

    if (!_disposed) {
      setState(() {
        friendsIDs = iDs;
        finished = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance // snapshot, whenever Data changes
          .collection('users')
          .snapshots(),
      builder: (ctx, streamSnapshot) {
        // streamSnapshot is recieved Data
        if (streamSnapshot.connectionState == ConnectionState.waiting) {
          // waiting for Data
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final documents = streamSnapshot.data.documents;
        print('userid: ${widget.userid}');
        return ListView.builder(
          key: new Key(randomString(20)), //new
          itemCount: documents.length,
          itemBuilder: (ctx, index) => documents[index]['id'] != widget.userid
              ? chatListitem(index, documents)
              : Text(
                  '..',
                  style: TextStyle(color: Colors.transparent),
                ),
        );
      },
    );
  }

  Container chatListitem(int i, final documents) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(documents[i]['userImage']),
            radius: 30,
          ),
          title: Text(
            documents[i]['username'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
          trailing: finished == true
              ? checkFriend(documents[i]['id']) == true
                  ? Icon(
                      Icons.person_pin,
                    )
                  : GestureDetector(
                      child: Icon(
                        Icons.person_add,
                      ),
                      onTap: () {
                        addFriend(i, documents);
                      },
                    )
              : Icon(Icons.av_timer)),
    );
  }
}
