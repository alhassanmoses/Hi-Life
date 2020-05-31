import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hilife/screens/client_home_screen.dart';
import 'package:provider/provider.dart';

import './auth_screen.dart';
import './user_details_screen_collect.dart';
import '../providers/auth.dart';
import './hp_home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  static const pageRoute = '/welcome-screen';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.orange[700],
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: Icon(
          Icons.home,
          color: Colors.teal,
        ),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 200,
              width: 200,
              child: Image.asset(
                'assets/images/stethoscope.png',
              ),
            ),
            Text(
              'Hi-Life',
              style: TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Pacifico'),
            ),
            Text(
              'Welcome',
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Source Sans Pro',
                  letterSpacing: 2),
            ),
            SizedBox(
              height: 20.0,
              width: 150.0,
              child: Divider(
                color: Colors.orange[100],
              ),
            ),
            LogInButton(
              deviceSize: deviceSize,
            ),
            Container(
              margin: EdgeInsets.fromLTRB(deviceSize.width * 0.5, 2, 2, 2),
              child: RichText(
                text: TextSpan(
                  text: 'New...?',
                  style: TextStyle(
                    color: Colors.teal[900],
                    fontFamily: 'Source Sans Pro',
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: ' Sign Up',
                      style: TextStyle(
                          color: Colors.lightBlueAccent,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Source Sans Pro'),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => Navigator.pushNamed(
                            context, UserDetailsScreen.pageRoute),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LogInButton extends StatefulWidget {
  const LogInButton({
    Key key,
    @required this.deviceSize,
  }) : super(key: key);

  final Size deviceSize;

  @override
  _LogInButtonState createState() => _LogInButtonState();
}

class _LogInButtonState extends State<LogInButton> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
          widget.deviceSize.width * 0.5, widget.deviceSize.height * 0.18, 2, 2),
      width: 300.0,
      child: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Card(
              color: Colors.orange,
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(1),
                child: ListTile(
                  leading: Icon(
                    Icons.account_circle,
                    color: Colors.teal,
                    size: 40.0,
                  ),
                  title: Text(
                    'Log In',
                    style: TextStyle(
                        color: Colors.teal[900],
                        fontFamily: 'Source Sans Pro',
                        fontSize: 20.0),
                  ),
                  subtitle: Text(
                    'Member...?',
                    style: TextStyle(
                        color: Colors.teal[900],
                        fontFamily: 'Source Sans Pro',
                        fontSize: 12.0),
                  ),
                  onTap: () async {
                    setState(() {
                      _isLoading = true;
                    });
                    final auth = Provider.of<Auth>(context, listen: false);
                    final stop = await auth.autoLogin();
                    if (!stop) {
                      Navigator.pushNamed(context, AuthScreen.pageRoute);
                    } else if (auth.isAuth == null) {
                      Navigator.pushNamed(context, AuthScreen.pageRoute);
                    } else if (auth.isAuth) {
                      bool isUserHp = auth.isHp;
//                      print('is user hp $isUserHp');
                      if (isUserHp) {
                        Navigator.pushNamed(context, HpHomeScreen.pageRoute);
                      } else {
                        Navigator.pushNamed(
                            context, ClientHomeScreen.pageRoute);
                      }
                    } else {
                      Navigator.pushNamed(context, AuthScreen.pageRoute);
                    }
                    setState(() {
                      _isLoading = false;
                    });
                  },
                ),
              ),
            ),
    );
  }
}
