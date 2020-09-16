import 'package:flutter/material.dart';

import 'package:chat_app/providers/theme_provider.dart';
import 'package:chat_app/widgets/animated_toggle.dart';
import 'package:provider/provider.dart';

class ModeScreen extends StatefulWidget {
  ModeScreen({Key key}) : super(key: key);

  @override
  _ModeScreenState createState() => _ModeScreenState();
}

class _ModeScreenState extends State<ModeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    super.initState();
  }

  // function to toggle circle Animation
  changeThemeMode(bool theme) {
    if (!theme) {
      _animationController.forward(from: 0.0);
    } else {
      _animationController.reverse(from: 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    // Now have access to the provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
          child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(top: 50),
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  width: width * 0.35,
                  height: width * 0.35,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                        colors: themeProvider.themeMode().gradient,
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight),
                  ),
                ),
                Transform.translate(
                  offset: Offset(40, 0),
                  child: ScaleTransition(
                    scale: _animationController.drive(
                      Tween<double>(begin: 0.0, end: 1.0).chain(
                        CurveTween(curve: Curves.decelerate),
                      ),
                    ),
                    alignment: Alignment.topRight,
                    child: Container(
                      width: width * 0.26,
                      height: width * 0.26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: themeProvider.isLightTheme
                            ? Colors.white
                            : Color(0xFF26242e),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: height * 0.1,
            ),
            Text(
              'Choose Style',
              style:
                  TextStyle(fontSize: width * .06, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: height * 0.03,
            ),
            Container(
              width: width * 0.6,
              child: Text(
                'Pop or Subtle. Day or Night. Customize your interface',
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: height * 0.1,
            ),
            AnimatedToggle(
              values: ['Light', 'Dark'],
              onToggleCallback: (v) async {
                await themeProvider
                    .toggleThemeData(); // will notify the listners
                setState(() {});
                changeThemeMode(
                    themeProvider.isLightTheme); // just for the animation
              },
            ),
            SizedBox(
              height: height * 0.05,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                buildDot(
                  width: width * 0.022,
                  height: width * 0.022,
                  color: const Color(0xFFd9d9d9),
                ),
                buildDot(
                  width: width * 0.055,
                  height: width * 0.022,
                  color: themeProvider.isLightTheme
                      ? Color(0xFF26242e)
                      : Colors.white,
                ),
                buildDot(
                  width: width * 0.022,
                  height: width * 0.022,
                  color: const Color(0xFFd9d9d9),
                ),
              ],
            ),
          ],
        ),
      )),
    );
  }

  Container buildDot({double width, double height, Color color}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      width: width,
      height: height,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: color,
      ),
    );
  }
}
