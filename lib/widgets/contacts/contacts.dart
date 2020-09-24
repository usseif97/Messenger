import 'package:chat_app/models/contactModel.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';

class Contacts extends StatelessWidget {
  final String userid;
  final List<ContactModel> contactsList;

  Contacts(this.userid, this.contactsList);

  void selectContact(BuildContext ctx, ContactModel contact) {
    Navigator.of(ctx).pushNamed(
      '/chat',
      arguments: {
        'contact': contact,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print('userid: $userid');
    return contactsList.length == 0
        ? Center(
            child: Text(
              'No Friends',
            ),
          )
        : ListView.builder(
            key: new Key(randomString(20)), //new
            itemCount: contactsList.length,
            itemBuilder: (ctx, index) =>
                chatListitem(index, contactsList, context));
  }

  Stack chatListitem(int i, List<ContactModel> documents, BuildContext ctx) {
    return Stack(
      children: <Widget>[
        GestureDetector(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(documents[i].userImage),
                radius: 30,
              ),
              title: Text(
                documents[i].username,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Container(
                width: 20,
                child: Text(
                  documents[i].chat,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          onTap: () => selectContact(ctx, documents[i]),
        ),
        /*Positioned(
          bottom: 8,
          left: 55,
          child: StreamBuilder(
            stream: Firestore.instance // snapshot, whenever Data changes
                .collection('users')
                .snapshots(),
            builder: (ctx, streamSnapshot) {
              // streamSnapshot is recieved Data
              if (streamSnapshot.connectionState == ConnectionState.waiting) {
                // waiting for Data
                return Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    //color: Colors.grey,
                    shape: BoxShape.circle,
                    border: Border.all(width: 3, color: Colors.white),
                  ),
                );
              }
              final docs = streamSnapshot.data.documents;
              return Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: docs[i]['status'] == 'offline'
                      ? Colors.grey
                      : Color(0xFF66BB6A),
                  shape: BoxShape.circle,
                  border: Border.all(width: 3, color: Colors.white),
                ),
              );
            },
          ),
        ),*/
      ],
    );
  }
}
