import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';
import '../widgets/loading.dart';
import '../screens/chat_screen.dart';

class ClHCard extends StatefulWidget {
  final String consultationId;
  final HpUserData currentUser;

  const ClHCard(
    this.consultationId,
    this.currentUser, {
    Key key,
  }) : super(key: key);

  @override
  _ClHCardState createState() => _ClHCardState();
}

class _ClHCardState extends State<ClHCard> {
  @override
  Widget build(BuildContext context) {
    String clientID =
        widget.consultationId.substring(0, widget.consultationId.indexOf('_'));
    return FutureBuilder(
      future:
          Firestore.instance.collection('CUserData').document(clientID).get(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Loading();
        } else {
          if (snap.error != null) {
            return Container(
              child: Center(
                child: Text('Error, please reload'),
              ),
            );
          } else {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 5,
              color: Colors.white10,
              child: Container(
                height: 80,
                child: Row(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        margin: EdgeInsets.all(5),
                        child: Image.network(
                          snap.data['pictureUrl'],
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('${snap.data['fname']} ${snap.data['lname']}')
                      ],
                    ),
                    Spacer(),
                    Container(
                      margin: EdgeInsets.all(10),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.all(0),
                        icon: Icon(Icons.message),
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (ctx) => ChatScreen(
                                      currentName:
                                          '${widget.currentUser.fname} ${widget.currentUser.lname}',
                                      peerName:
                                          '${snap.data['fname']} ${snap.data['lname']}',
                                      currentAvatar:
                                          widget.currentUser.pictureUrl,
                                      peerAvatar: snap.data['pictureUrl'],
                                      peerId: snap.data['userId'],
                                      isHp: true,
                                      currentId: widget.currentUser.userId,
                                    ))),
                      ),
                    )
                  ],
                ),
              ),
            );
          }
        }
      },
    );
  }
}
