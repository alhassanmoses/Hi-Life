import 'package:flutter/material.dart';

import '../models/user.dart';
import '../screens/hp_details_screen.dart';

class HpHCard extends StatelessWidget {
  final HpUserData hp;

  HpHCard(this.hp);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 5.0,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Flexible(
              flex: 4,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(
                    hp.pictureUrl,
                    fit: BoxFit.scaleDown,
                  ),
                ),
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FittedBox(
                    child: Text(
                  '${hp.fname} ${hp.lname}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                )),
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FittedBox(
                      child: Text(
                        hp.profession,
                        style: TextStyle(fontSize: 12.0),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                      child: VerticalDivider(
                        color: Colors.black,
                      ),
                    ),
                    FittedBox(
                      child: Text(
                        hp.age.toString(),
                        style: TextStyle(fontSize: 12.0),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HpDetailsScreen(hp),
          ),
        );
      },
    );
  }
}
