import 'dart:io';
import 'dart:math';

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

//        leading: Icon(Icons.home),
        title: Text('Home'),
      ),
      drawer: CAppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Users>(context, listen: false).fetchUsers(false),
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
              final hp = Provider.of<Users>(context, listen: false).hpUserData;
              return Container(
                color: Colors.black12,
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
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.fromLTRB(15, 15, 2, 15),
                            child: Text(
                              'Categories',
                              style: TextStyle(
                                fontSize: 18.0,
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          Container(
                            height: 200.0,
                            child: GridView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: kSpecialist.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 6 / 7,
                                crossAxisSpacing: 10.0,
                              ),
                              itemBuilder: (ctx, i) => CategoryItemCard(
                                kSpecialist[i],
                                random.nextInt(8) + 1,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Flexible(
                      child: Container(
                        width: double.infinity,
                        height: 90,
                        margin: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.circular(30.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.reply),
                                  color: Colors.teal,
                                  iconSize: 30.0,
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                              title: Text(
                                                'Close App',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              content: Text('Do you accept?'),
                                              elevation: 10,
                                              backgroundColor: Colors.white,
                                              actions: <Widget>[
                                                FlatButton(
                                                  child: Text(
                                                    'No',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                ),
                                                FlatButton(
                                                  child: Text(
                                                    'Yes',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
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
                                Text('Exit'),
                              ],
                            ),
                            SizedBox(
                              height: 30,
                              child: VerticalDivider(
                                color: Colors.black,
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.access_time),
                                  color: Colors.teal,
                                  iconSize: 30.0,
                                  onPressed: () {},
                                ),
                                Text('Appointments'),
                              ],
                            ),
                            SizedBox(
                              height: 30,
                              child: VerticalDivider(
                                color: Colors.black,
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.account_circle),
                                  color: Colors.teal,
                                  iconSize: 30.0,
                                  onPressed: () {},
                                ),
                                Text('Account'),
                              ],
                            ),
                            SizedBox(
                              height: 30,
                              child: VerticalDivider(
                                color: Colors.black,
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.menu),
                                  color: Colors.teal,
                                  iconSize: 30.0,
                                  onPressed: () {},
                                ),
                                Text('Menu'),
                              ],
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
        },
      ),
    );
  }
}
