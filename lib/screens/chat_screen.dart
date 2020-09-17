import 'dart:ui';

import 'package:chat_app/models/chatModel.dart';
import 'package:chat_app/models/contactModel.dart';
import 'package:chat_app/widgets/chat/messages.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({Key key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  String userID = '';

  var _loadedInitData = false;
  bool _disposed = false;
  bool finished = false;
  //bool isInitialized = false;
  var routeArgs;

  List<ChatModel> chatList = [];

  final textController = TextEditingController();

  @override
  void didChangeDependencies() {
    // Called when the widget that belong to the State is fully initailzed so ModalRoute can be used on it,
    // Also run before Build() and After initState()
    if (!_loadedInitData) {
      routeArgs = ModalRoute.of(context).settings.arguments
          as Map<String, ContactModel>;
      _chatList();
      _loadedInitData = true;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    _disposed = true;
    textController.dispose();
    super.dispose();
  }

  void _sendMessage(String message) async {
    print('send Message');
    final FirebaseUser user = await _auth.currentUser();
    String uid = user.uid;

    if (message.trim().isEmpty) {
      return;
    }

    // Current User send to Friend
    try {
      await Firestore.instance
          .collection('chat')
          .document(uid)
          .setData({'exist': 'yes'});
    } catch (error) {
      print(error.toString());
    }
    try {
      await Firestore.instance
          .collection('chat')
          .document(uid)
          .collection('friends')
          .document(routeArgs['contact'].id)
          .setData({'exist': 'yes'});
    } catch (error) {
      print(error.toString());
    }
    try {
      await Firestore.instance
          .collection('chat')
          .document(uid)
          .collection('friends')
          .document(routeArgs['contact'].id)
          .collection('messages')
          .add({
        'message': message.trim(),
        'send': '1', // 1: send by me
        'date': DateTime.now().toString(),
      });
    } catch (error) {
      print(error.toString());
    }

    // Friend recieve from Current User
    try {
      await Firestore.instance
          .collection('chat')
          .document(routeArgs['contact'].id)
          .setData({'exist': 'yes'});
    } catch (error) {
      print(error.toString());
    }
    try {
      await Firestore.instance
          .collection('chat')
          .document(routeArgs['contact'].id)
          .collection('friends')
          .document(uid)
          .setData({'exist': 'yes'});
    } catch (error) {
      print(error.toString());
    }
    try {
      await Firestore.instance
          .collection('chat')
          .document(routeArgs['contact'].id)
          .collection('friends')
          .document(uid)
          .collection('messages')
          .add({
        'message': message,
        'send': '0', // 0: send by friend
        'date': DateTime.now().toString(),
      });
    } catch (error) {
      print(error.toString());
    }

    // Update Contacts Screen Info
    try {
      await Firestore.instance
          .collection('contacts')
          .document(uid)
          .collection('friends')
          .document(routeArgs['contact'].id)
          .updateData({
        'date': DateTime.now().toString(),
        'chat': message,
      });
      print('done');
    } catch (e) {
      print(e.toString());
    }
    try {
      await Firestore.instance
          .collection('contacts')
          .document(routeArgs['contact'].id)
          .collection('friends')
          .document(uid)
          .updateData({
        'date': DateTime.now().toString(),
        'chat': message,
      });
      print('done');
    } catch (e) {
      print(e.toString());
    }

    textController.clear();
    _chatList();
  }

  void _chatList() async {
    print('_mastersList Function');

    final FirebaseUser user = await _auth.currentUser();
    String uid = user.uid;

    setState(() {
      finished = false;
      chatList = [];
    });

    QuerySnapshot querySnapshot =
        await Firestore.instance.collection("chat").getDocuments();

    List listOfMasters = querySnapshot.documents;

    for (int i = 0; i < listOfMasters.length; i++) {
      if (listOfMasters[i].documentID.toString() == uid) {
        /*Firestore.instance
            .collection("chat")
            .document(listOfMasters[i].documentID.toString())
            .collection("friends")
            .snapshots()
            .listen(_createListofchats);*/

        QuerySnapshot querySnapshotOfFriends = await Firestore.instance
            .collection("chat")
            .document(uid)
            .collection('friends')
            .getDocuments();

        List listOfMastersOfFriends = querySnapshotOfFriends.documents;

        for (int j = 0; j < listOfMastersOfFriends.length; j++) {
          if (listOfMastersOfFriends[j].documentID.toString() ==
              routeArgs['contact'].id) {
            Firestore.instance
                .collection("chat")
                .document(listOfMasters[i].documentID.toString())
                .collection("friends")
                .document(listOfMastersOfFriends[j].documentID.toString())
                .collection('messages')
                .orderBy('date', descending: true)
                .snapshots()
                .listen(_createListofchats);
          }
        }
      }
    }
  }

  void _createListofchats(QuerySnapshot snapshot) async {
    var docs = snapshot.documents;
    for (var Doc in docs) {
      chatList.add(ChatModel.fromFireStore(Doc));
    }
    print('chatList.length: ${chatList.length}');
    if (!_disposed) {
      setState(() {
        finished = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Text(
          routeArgs['contact'].username,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          Container(
            child: Icon(
              Icons.phone,
            ),
            margin: const EdgeInsets.all(8),
          ),
          Container(
            child: Icon(
              Icons.color_lens,
            ),
            margin: const EdgeInsets.all(8),
          ),
        ],
        leading: Container(
          margin: const EdgeInsets.all(5),
          child: CircleAvatar(
            backgroundImage: NetworkImage(routeArgs['contact'].userImage),
          ),
        ),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Messages(finished == true ? chatList : [],
                  routeArgs['contact'].userImage),
            ),
            bottomBar(),
          ],
        ),
      ),
    );
  }

  Container bottomBar() {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.sentiment_satisfied),
            color: Colors.blue,
            onPressed: () => _sendMessage(textController.text),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xffF4F5FA),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                decoration: InputDecoration.collapsed(
                  hintText: "Aa",
                  hintStyle: TextStyle(color: Colors.black),
                ),
                style: TextStyle(color: Colors.black),
                controller: textController,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            color: Colors.blue,
            onPressed: () => _sendMessage(textController.text),
          ),
        ],
      ),
    );
  }
}
