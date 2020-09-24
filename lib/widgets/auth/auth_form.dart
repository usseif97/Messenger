import 'package:chat_app/widgets/pickers/user_image_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class AuthForm extends StatefulWidget {
  final void Function(
    String email,
    String username,
    String password,
    File image,
    bool isLogin,
    BuildContext ctx,
  ) submitHandler;

  final bool isLoading;

  AuthForm(this.submitHandler, this.isLoading);

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();

  var _isLogin = true;
  var _userName = '';
  var _emailAdress = '';
  var _password = '';
  File _userImageFile;

  void _pickedImage(File image) {
    _userImageFile = image;
  }

  void _showErrorDiaolg(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occured !!'),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text('Ok'),
            onPressed: Navigator.of(ctx).pop,
          ),
        ],
      ),
    );
  }

  void _submit() {
    final isValid = _formKey.currentState
        .validate(); // validate(), will call all validators of the form
    FocusScope.of(context)
        .unfocus(); // Close the keyBoard after submission, Remove the Focus from the keyBoard

    if (_userImageFile == null && !_isLogin) {
      _showErrorDiaolg('You must add user image !!');
      return;
    }

    if (isValid) {
      _formKey.currentState.save(); // save(), will call all save of the form
      widget.submitHandler(
        _emailAdress.trim(),
        _userName.trim(),
        _password.trim(),
        _userImageFile,
        _isLogin,
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Now have access to the provider
    //final themeProvider = Provider.of<ThemeProvider>(context);

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/back.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: <Widget>[
            // Messenger Logo
            Container(
              margin: EdgeInsets.symmetric(vertical: 20),
              height: height * 0.3,
              width: width * 0.5,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/messenger.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              height: height * 0.5,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(20),
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                color: Colors.white70,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (!_isLogin) UserImagePicker(_pickedImage),
                      // Email Address
                      TextFormField(
                        key: ValueKey('email'),
                        validator: (value) {
                          if (value.isEmpty || !value.contains('@')) {
                            return 'Please Enter a Valid Email Adress';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Email Address',
                          hintStyle: TextStyle(color: Colors.black),
                        ),
                        onSaved: (value) {
                          // No Need fo setState, because there's no impact on UI
                          _emailAdress = value;
                        },
                        style: TextStyle(color: Colors.black),
                      ),
                      // UserName
                      if (!_isLogin)
                        TextFormField(
                          key: ValueKey('username'),
                          validator: (value) {
                            if (value.isEmpty || value.length < 4) {
                              return 'Please Enter a Valid Username';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Username',
                            hintStyle: TextStyle(color: Colors.black),
                          ),
                          onSaved: (value) {
                            _userName = value;
                          },
                          style: TextStyle(color: Colors.black),
                        ),
                      // Password
                      TextFormField(
                        key: ValueKey('password'),
                        validator: (value) {
                          if (value.isEmpty || value.length < 8) {
                            return 'Please Enter at least 8 chatacters';
                          }
                          return null;
                        },
                        obscureText: true, // hide the password
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(color: Colors.black),
                        ),
                        onSaved: (value) {
                          _password = value;
                        },
                        style: TextStyle(color: Colors.black),
                      ),
                      SizedBox(height: 30),
                      if (widget.isLoading)
                        CircularProgressIndicator(),
                      if (!widget.isLoading)
                        RaisedButton(
                          onPressed: _submit,
                          child: Text(_isLogin ? 'Login' : 'Signup'),
                          color: Colors.blue,
                        ),
                      if (!widget.isLoading)
                        FlatButton(
                          child: Text(
                            _isLogin
                                ? 'Create new Account'
                                : 'I arleady have an Account',
                            style: TextStyle(fontSize: 15),
                          ),
                          textColor: Colors.blue,
                          onPressed: () {
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
