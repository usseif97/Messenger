import 'package:chat_app/screens/contacts_screen.dart';
import 'package:chat_app/screens/users_screen.dart';
import 'package:flutter/material.dart';

class TabScreen extends StatefulWidget {
  TabScreen({Key key}) : super(key: key);

  @override
  _TabScreenState createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  int _currentIndex = 0;
  final List<Widget> _children = [ContactsScreen(), UsersScreen()];

  void onTappedBar(int index) {
    setState(() {
      _currentIndex = index;
    });
    print('index: $_currentIndex');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTappedBar,
        type: BottomNavigationBarType.fixed,
        fixedColor: Colors.blue,
        backgroundColor: Colors.grey[200],
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            title: Text(""),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            title: Text(""),
          ),
        ],
      ),
    );
  }
}
