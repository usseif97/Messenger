import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  final void Function(File pickedImage) imagePickHandler;

  UserImagePicker(this.imagePickHandler);

  @override
  _UserImagePickerState createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File _pickedImage;
  final picker = ImagePicker();

  void _pickImage() async {
    final pickedImageFile = await picker.getImage(
      source: ImageSource.gallery,
      imageQuality: 30,
    );
    setState(() {
      _pickedImage = File(pickedImageFile.path);
    });
    widget.imagePickHandler(File(pickedImageFile.path));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CircleAvatar(
          radius: 40,
          backgroundImage: _pickedImage != null
              ? FileImage(_pickedImage)
              : AssetImage('assets/images/user.jpg'),
        ),
        FlatButton.icon(
          onPressed: _pickImage,
          textColor: Colors.blue,
          icon: Icon(Icons.image),
          label: Text('Add Image'),
        ),
      ],
    );
  }
}
