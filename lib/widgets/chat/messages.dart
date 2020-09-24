import 'package:chat_app/models/chatModel.dart';
import 'package:chat_app/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class Messages extends StatelessWidget {
  final List<ChatModel> chatsList;
  final String friendImage;

  const Messages(this.chatsList, this.friendImage);

  //final ThemeProvider themeProvider = null;

  @override
  Widget build(BuildContext context) {
    return chatsList.length == 0
        ? Center(
            child: Text(
              'No Messages',
              style: TextStyle(color: Colors.transparent),
              //style: TextStyle(color: Colors.black),
            ),
          )
        : ListView.builder(
            key: new Key(randomString(20)), //new
            itemCount: chatsList.length,
            reverse: true,
            itemBuilder: (ctx, index) =>
                messageBubbleItem(index, chatsList, context));
  }

  Widget messageListItem(int i, List<ChatModel> documents, BuildContext ctx) {
    return Container(
      child: Text(
        documents[i].message,
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  Row messageBubbleItem(int i, List<ChatModel> documents, BuildContext ctx) {
    return Row(
      mainAxisAlignment: documents[i].send == '1'
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: <Widget>[
        documents[i].send == '0'
            ? Container(
                margin: const EdgeInsets.all(5),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(friendImage),
                ),
              )
            : Text(
                '.',
                style: TextStyle(color: Colors.transparent),
              ),
        Container(
          decoration: BoxDecoration(
            color: documents[i].send == '1' ? Colors.blue : Colors.grey,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: documents[i].send == '1'
                  ? Radius.circular(12)
                  : Radius.circular(0),
              bottomRight: documents[i].send == '1'
                  ? Radius.circular(0)
                  : Radius.circular(12),
            ),
          ),
          width: 140,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Text(
            documents[i].message,
            style: TextStyle(
                color: documents[i].send == '1' ? Colors.white : Colors.black),
          ),
        ),
      ],
    );
  }
}
