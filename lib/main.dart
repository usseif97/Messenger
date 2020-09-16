import 'package:chat_app/screens/tab_screen.dart';
import 'package:chat_app/screens/users_screen.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/providers/theme_provider.dart';
import 'package:chat_app/screens/auth_screen.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './screens/chat_screen.dart';
import './screens/contacts_screen.dart';
import './screens/mode_Screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumemtDirectory =
      await pathProvider.getApplicationDocumentsDirectory();

  Hive.init(appDocumemtDirectory.path);

  final settings = await Hive.openBox('settings');
  bool isLightTheme = settings.get('isLightTheme') ?? false;

  runApp(
    ChangeNotifierProvider(
      create: (_) => // create Provider
          ThemeProvider(isLightTheme: isLightTheme),
      child: AppStart(),
    ),
  );
}

class AppStart extends StatelessWidget {
  const AppStart({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider =
        Provider.of<ThemeProvider>(context); // Consume Provider
    return MyApp(
      themeProvider: themeProvider,
    );
  }
}

class MyApp extends StatefulWidget with WidgetsBindingObserver {
  final ThemeProvider themeProvider;
  const MyApp({Key key, @required this.themeProvider}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Messenger',
      theme: widget.themeProvider.themeData(context),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (ctx, userSnapShot) {
          if (userSnapShot.hasData) {
            // Firebase checks has a Token or not
            return TabScreen();
          }
          return AuthScreen();
        },
      ),
      routes: {
        '/auth': (ctx) => AuthScreen(),
        '/tab': (ctx) => TabScreen(),
        '/contacts': (ctx) => ContactsScreen(),
        '/users': (ctx) => UsersScreen(),
        '/chat': (ctx) => ChatScreen(),
        '/mode': (ctx) => ModeScreen(),
      },
    );
  }
}
