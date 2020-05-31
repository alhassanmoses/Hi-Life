import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      drawer: HpAppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Home'),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.all(8),
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.black12.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(100),
                        image: DecorationImage(
                          image: NetworkImage(currentUser.pictureUrl),
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                      //image holder
                    ),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.star,
                          size: 30,
                          color: Colors.pink,
                        ),
                        Text(
                          '4.13',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
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
                        currentUser.profession,
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
            Divider(
              color: Colors.grey,
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
                        List<String> ids = [];

                        for (String consultationId
                            in snapshot.data.data['consulted']) {
                          ids.add(consultationId);
                        }

                        return Container(
                          width: screenWidth * 0.9,
                          child: ListView.builder(
                            itemCount: ids.length,
                            itemBuilder: (ctx, i) => Container(
                              child: ClHCard(
                                ids[i],
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
