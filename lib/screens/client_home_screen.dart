import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/c_app_drawer.dart';
import '../providers/users.dart';
import '../widgets/hp_h_card.dart';
import '../constants.dart';
import '../widgets/category_item_card.dart';

class ClientHomeScreen extends StatefulWidget {
  static const pageRoute = '/client-home-screen';
  @override
  _ClientHomeScreenState createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  Random random = Random();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

//        leading: Icon(Icons.home),
        title: Text('Home'),
      ),
      drawer: CAppDrawer(),
      body: Stack(
        children: <Widget>[
          Container(
            height: size.height,
            width: size.width,
            child: CustomPaint(
              painter: PaintBottomCurvedSlope(),
            ),
          ),
          FutureBuilder(
            future:
                Provider.of<Users>(context, listen: false).fetchUsers(false),
            builder: (ctx, hpDataSnapshot) {
              if (hpDataSnapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  color: Colors.black38,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else {
                if (hpDataSnapshot.error != null) {
                  print(
                      'Error occurred in client home screen ${hpDataSnapshot.error} ');
                  return Center(
                    child: Text('An error occurred, please reload'),
                  );
                } else {
                  final hp =
                      Provider.of<Users>(context, listen: false).hpUserData;
                  return Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: 250,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: hp.length,
                            itemBuilder: (ctx, i) => Container(
                              height: 210.0,
                              width: 160.0,
                              margin: EdgeInsets.symmetric(
                                  vertical: 2.5, horizontal: 2.0),
                              child: HpHCard(
                                hp[i],
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.fromLTRB(15, 15, 2, 15),
                                child: Text(
                                  'Categories:',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontFamily: 'VarelaRound',
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Expanded(
//                            height: 200.0,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: kSpecialisations.length,
                                  itemBuilder: (ctx, i) => CategoryItemCard(
                                    kSpecialisations[i]
                                        .specialisationProfession,
                                    random.nextInt(8) + 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                            child: Container(
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Card(),
                              ),
                            ],
                          ),
                        )),
                        Flexible(
                          fit: FlexFit.tight,
                          flex: 0,
                          child: Container(
                            width: double.infinity,
                            height: 70,
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30.0)),
                            child: Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(bottom: 5),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        IconButton(
                                          icon: Icon(Icons.reply),
                                          color: primaryColor,
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder: (_) => AlertDialog(
                                                      title: Text(
                                                        'Close App',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      content: Text(
                                                          'Do you accept?'),
                                                      elevation: 10,
                                                      backgroundColor:
                                                          Colors.white,
                                                      actions: <Widget>[
                                                        FlatButton(
                                                          child: Text(
                                                            'No',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(),
                                                        ),
                                                        FlatButton(
                                                          child: Text(
                                                            'Yes',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                          onPressed: () {
                                                            exit(0);
                                                          },
                                                        )
                                                      ],
                                                    ),
                                                barrierDismissible: false);
                                          },
                                        ),
                                        Text(
                                          'Exit',
                                          style: kClientBottomBarTextStyle,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 30,
                                    child: VerticalDivider(
                                      color: Colors.black,
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(bottom: 5),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        IconButton(
                                          icon: Icon(Icons.access_time),
                                          color: primaryColor,
                                          onPressed: () {},
                                        ),
                                        Text(
                                          'Appointments',
                                          style: kClientBottomBarTextStyle,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 30,
                                    child: VerticalDivider(
                                      color: Colors.black,
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(bottom: 5),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        IconButton(
                                          icon: Icon(Icons.account_circle),
                                          color: primaryColor,
                                          onPressed: () {},
                                        ),
                                        Text(
                                          'Account',
                                          style: kClientBottomBarTextStyle,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 30,
                                    child: VerticalDivider(
                                      color: Colors.black,
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(bottom: 5),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        IconButton(
                                          icon: Icon(Icons.menu),
                                          color: primaryColor,
                                          onPressed: () {},
                                        ),
                                        Text(
                                          'Menu',
                                          style: kClientBottomBarTextStyle,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class PaintBottomCurvedSlope extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.green[800];
    paint.style = PaintingStyle.fill;

    var path = Path();

    path.moveTo(0, size.height * 0.9167);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.875,
        size.width * 0.5, size.height * 0.9167);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.9584,
        size.width * 1.0, size.height * 0.9167);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
