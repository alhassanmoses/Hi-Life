import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import './client_home_screen.dart';
import '../providers/users.dart';
import './hp_home_screen.dart';

enum SignUpMode { Client, Hp }

class SignUpScreen extends StatefulWidget {
  static const pageRoute = '/auth-page-route';
  SignUpScreen(this.userData);
  final Map<String, Object> userData;
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepOrange,
                  Colors.orangeAccent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      alignment: Alignment.center,
                      height: deviceSize.height * 0.3,
                      width: deviceSize.width * 0.4,
                      margin:
                          EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
                      padding: EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Container(
                        transform: Matrix4.rotationZ(-8 * pi / 140)
                          ..translate(-4.0),
                        child: FittedBox(
                          child: Text(
                            'Hi - Life',
                            style: TextStyle(
                              fontSize: 30,
                              fontFamily: 'Pacifico',
                              fontWeight: FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(userData: widget.userData),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({Key key, this.userData}) : super(key: key);
  final Map<String, dynamic> userData;

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

  void _showErrorDialog(String message) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Row(
                children: <Widget>[
                  Icon(Icons.cancel),
                  SizedBox(
                    width: 10.0,
                  ),
                  Text('An Error Occured!'),
                ],
              ),
              content: Text(message),
              actions: <Widget>[
                FlatButton(
                  child: Text('Okay'),
                  onPressed: () => Navigator.of(ctx).pop(),
                )
              ],
            ));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() => _isLoading = true);
    try {
      final _auth = Provider.of<Auth>(context, listen: false);
      //login
      await _auth.signUp(_authData['email'], _authData['password']);
      String uid = await Future.value(_auth.userId);
      bool success = await Provider.of<Users>(context, listen: false).addUser(
        isHp: widget.userData['isHp'],
        email: _authData['email'],
        fname: widget.userData['fname'],
        lname: widget.userData['lname'],
        profession: widget.userData['profession'],
        shortDescription: widget.userData['shortDescription'],
        experience: widget.userData['experience'],
        address: widget.userData['address'],
        age: widget.userData['age'],
        sex: widget.userData['sex'],
        userId: uid,
        image: widget.userData['image'],
      );
      if (success) {
        bool _isUserHp = _auth.isHp;
        if (_isUserHp) {
          Navigator.pushReplacementNamed(context, HpHomeScreen.pageRoute);
        } else {
          Navigator.pushReplacementNamed(context, ClientHomeScreen.pageRoute);
        }
      } else {
        print('Unsuccessful upload of user Data in sign-up screen');
        throw 'Unsuccessful upload of user Data in sign-up screen';
      }
    } catch (e) {
      if (e is String) {
        _showErrorDialog(e);
      } else {
        print('complex error occured at signup_screen, _submit');
        print('this is it ${e.toString()}');
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      color: Colors.deepOrange,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: Container(
        height: 300,
        constraints: BoxConstraints(minHeight: 300),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  // ignore: missing_return
                  validator: (value) {
                    if (!RegExp(
                            r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                        .hasMatch(value)) {
                      return 'Invalid email!';
                    }
                  },
                  onSaved: (value) {
                    _authData['email'] = value.trim();
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  // ignore: missing_return
                  validator: (value) {
                    if (value.isEmpty || value.length < 5) {
                      return 'Password is too short!';
                    }
                  },
                  onSaved: (value) {
                    _authData['password'] = value.trim();
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Confirm Password'),
                  obscureText: true,
                  validator:
                      // ignore: missing_return
                      (value) {
                    if (value.trim() != _passwordController.text.trim()) {
                      return 'Passwords do not match!';
                    }
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  RaisedButton(
                    child: Text('SIGN UP'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).primaryTextTheme.button.color,
                    onPressed: _submit,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
