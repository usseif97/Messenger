import 'package:cloud_firestore/cloud_firestore.dart';

class ContactModel {
  String username;
  String email;
  String id;
  String userImage;
  String status;
  String chat;
  String date;
  ContactModel(
      {this.username,
      this.email,
      this.id,
      this.userImage,
      this.status,
      this.chat,
      this.date});

  factory ContactModel.fromFireStore(DocumentSnapshot doc) {
    Map data = doc.data;
    return ContactModel(
        username: data['username'],
        email: data['email'],
        id: data['id'],
        userImage: data['userImage'],
        status: data['status'],
        chat: data['chat'],
        date: data['date']);
  }
}
