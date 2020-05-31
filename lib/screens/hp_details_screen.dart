import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../screens/chat_screen.dart';
import '../providers/auth.dart';
import '../widgets/loading.dart';

class HpDetailsScreen extends StatelessWidget {
  static const pageRoute = '/hp_details_screen';
  final HpUserData hp;
  HpDetailsScreen(this.hp);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Column(
            children: <Widget>[
              Flexible(
                child: Stack(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(15, 0, 15, 25),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                            Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0, 1],
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20.0),
                              bottomRight: Radius.circular(20.0)),
                          image: DecorationImage(
                            image: NetworkImage(
                              hp.pictureUrl,
                            ),
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: IconButton(
                        color: Colors.blueAccent,
                        icon: Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    )
                  ],
                ),
              ),
              Flexible(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(
                        '${hp.fname} ${hp.lname}',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        hp.profession,
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.black38,
                        ),
                      ),
                      Text(hp.shortDescription),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          BuildViewAddress(hp.address),
                          SizedBox(
                            width: 30,
                          ),
                          Flexible(
                            child: Card(
                              color: Colors.orangeAccent,
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.chat,
                                  size: 25,
                                ),
                                onPressed: () {
                                  CUserData cl =
                                      Provider.of<Auth>(context, listen: false)
                                          .currentClData;

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                        peerName: '${hp.fname} ${hp.lname}',
                                        currentName: '${cl.fname} ${cl.lname}',
                                        currentAvatar: cl.pictureUrl,
                                        isHp: false,
                                        peerId: hp.userId,
                                        peerAvatar: hp.pictureUrl,
                                        currentId: cl.userId,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      FutureBuilder(
                        future: Firestore.instance
                            .collection('HpUserData')
                            .document(hp.userId)
                            .get(),
                        builder: (ctx, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Loading(),
                                Loading(),
                                Loading(),
                              ],
                            );
                          } else {
                            if (snap.error == null ? true : false) {
                              bool noRating = false;
                              bool hasConsulted = false;
                              int numConsulted = 0;
                              if (snap.data['rating'] == null) {
                                noRating = true;
                              }
                              if (snap.data['consulted'] == null) {
                                hasConsulted = false;
                              } else {
                                hasConsulted = true;
                                snap.data['consulted'].forEach((value) {
                                  numConsulted += 1;
                                });
                              }
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Card(
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      height: 100,
                                      width: 100,
                                      color: Colors.greenAccent,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          Text(
                                            hasConsulted
                                                ? '$numConsulted'
                                                : '0',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text('Patient(s)')
                                        ],
                                      ),
                                    ),
                                  ),
                                  Card(
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      height: 100,
                                      width: 100,
                                      color: Colors.lightBlueAccent,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          Text(
                                            '${hp.experience} Years',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text('Experience')
                                        ],
                                      ),
                                    ),
                                  ),
                                  Card(
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      height: 100,
                                      width: 100,
                                      color: Colors.orangeAccent,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Icon(
                                                Icons.star,
                                                color: Colors.yellow,
                                              ),
                                              Text(
                                                noRating
                                                    ? '0'
                                                    : '${snap.data['rating']['rated']}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(noRating
                                              ? '0 Reviewer(s)'
                                              : '${snap.data['rating']['reviewers']} Reviewer(s)'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Loading(),
                                  Loading(),
                                  Loading(),
                                ],
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BuildViewAddress extends StatefulWidget {
  final String address;
  const BuildViewAddress(
    this.address, {
    Key key,
  }) : super(key: key);

  @override
  _BuildViewAddressState createState() => _BuildViewAddressState();
}

class _BuildViewAddressState extends State<BuildViewAddress> {
  bool viewAddress = false;

  void showAddress() {
    //address viewed +1 for this hp
    //future update for address viewed count
    setState(() {
      viewAddress = !viewAddress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      color: Colors.orangeAccent,
      child: viewAddress ? Text(widget.address) : Text('View working address'),
      onPressed: () {
        showAddress();
      },
    );
  }
}
