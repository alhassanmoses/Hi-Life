import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hilife/constants.dart';
import 'package:provider/provider.dart';

import '../widgets/hp_app_drawer.dart';

import '../widgets/cl_h_card.dart';
import '../models/user.dart';
import '../providers/auth.dart';

class HpHomeScreen extends StatefulWidget {
  static const pageRoute = '/hp_home_screen';

  @override
  _HpHomeScreenState createState() => _HpHomeScreenState();
}

class _HpHomeScreenState extends State<HpHomeScreen> {
  Widget loading() {
    return Container(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget error() {
    return Container(child: Text('An error occurred, please reload...'));
  }

  @override
  Widget build(BuildContext context) {
    HpUserData currentUser =
        Provider.of<Auth>(context, listen: false).currentHpData;
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      drawer: HpAppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        elevation: 0,
        title: Text('Home'),
      ),
      body: Container(
        color: Colors.black26,
        child: Column(
          children: <Widget>[
            Container(
              height: screenSize.height * 0.5,
              child: Stack(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    height: screenSize.height * 0.5,
                    child: CustomPaint(
                      painter: PaintSlope(),
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          FutureBuilder<DocumentSnapshot>(
                              future: Firestore.instance
                                  .collection('HpUserData')
                                  .document(currentUser.userId)
                                  .collection('RatingData')
                                  .document('Rating')
                                  .get(),
                              builder: (context, snapshot) {
                                if (snapshot.error != null) {
                                  return Container(
                                    child: Center(
                                      child: Text(
                                          'Sorry, an error occurred, please reload'),
                                    ),
                                  );
                                }

                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.all(8),
                                      width: 150,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        color: Colors.black12.withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                              currentUser.pictureUrl),
                                          fit: BoxFit.scaleDown,
                                        ),
                                      ),
                                      //image holder
                                    ),
                                    (snapshot.connectionState ==
                                            ConnectionState.waiting)
                                        ? CircularProgressIndicator()
                                        : snapshot.data.exists
                                            ? Row(
                                                children: <Widget>[
                                                  snapshot.data['rated'] == 0
                                                      ? Icon(Icons.star_border)
                                                      : snapshot
                                                                      .data[
                                                                  'rated'] <=
                                                              3
                                                          ? Icon(
                                                              Icons.star_border)
                                                          : Icon(Icons.star),
                                                  RichText(
                                                    text: TextSpan(
                                                        text: snapshot
                                                            .data['rated']
                                                            .toString(),
                                                        style: TextStyle(
                                                            color: Colors.blue),
                                                        children: <TextSpan>[
                                                          TextSpan(
                                                              text:
                                                                  '(${snapshot.data['reviewers']} reviewers)')
                                                        ]),
                                                  ),
                                                ],
                                              )
                                            : Row(
                                                children: <Widget>[
                                                  Icon(Icons.star_border),
                                                  Text('New'),
                                                ],
                                              )
                                  ],
                                );
                              }),
                          Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '${currentUser.fname} ${currentUser.lname}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  kProfessions[currentUser.professionIndex]
                                      .specialisationProfession,
                                  style: TextStyle(color: Colors.black38),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text('Clients served'),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      width: screenSize.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Card(
                            color: Colors.green.withOpacity(0.7),
                            elevation: 8,
                            child: Container(
                              height: 140,
                              width: 120,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Icon(Icons.event_note),
                                  Text('Appointments'),
                                  Text('X available'),
                                ],
                              ),
                            ),
                          ),
                          Card(
                            color: Colors.green.withOpacity(0.7),
                            elevation: 8,
                            child: Container(
                              height: 140,
                              width: 120,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Icon(Icons.people),
                                  Text('Clients'),
                                  Text('X available'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                  stream: Firestore.instance
                      .collection('HpUserData')
                      .document(currentUser.userId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return loading();
                    } else {
                      if (snapshot.error != null) {
                        return error();
                      } else if (snapshot.data.data['consulted'] == null) {
                        return Container(
                            child: Text('You have 0 online consultations'));
                      } else {
                        return Container(
                          width: screenSize.width * 0.9,
                          child: ListView.builder(
                            itemCount: snapshot.data.data['consulted'].length,
                            itemBuilder: (ctx, i) => Container(
                              child: ClHCard(
                                snapshot.data.data['consulted'][i],
                                currentUser,
                              ),
                            ),
                          ),
                        );
                      }
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

class PaintSlope extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.green[800];
    paint.style = PaintingStyle.fill;

    var path = Path();

    path.moveTo(0, size.height * 0.5);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height * 0.5);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
