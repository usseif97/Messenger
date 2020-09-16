import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  String message;
  String send;
  String date;
  ChatModel({this.message, this.send, this.date});

  factory ChatModel.fromFireStore(DocumentSnapshot doc) {
    Map data = doc.data;
    return ChatModel(
        message: data['message'], send: data['send'], date: data['date']);
  }
}
