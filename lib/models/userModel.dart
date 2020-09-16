import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String email;
  String id;
  String password;
  String status;
  String userImage;
  String username;
  UserModel(
      {this.email,
      this.id,
      this.password,
      this.status,
      this.userImage,
      this.username});

  factory UserModel.fromFireStore(DocumentSnapshot doc) {
    Map data = doc.data;
    return UserModel(
      email: data['email'],
      id: data['id'],
      password: data['password'],
      status: data['status'],
      userImage: data['userImage'],
      username: data['username'],
    );
  }
}
