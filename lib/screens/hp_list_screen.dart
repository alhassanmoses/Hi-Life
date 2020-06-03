import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hilife/constants.dart';
import 'package:hilife/models/user.dart';
import 'package:provider/provider.dart';

import '../widgets/c_app_drawer.dart';
import '../providers/users.dart';

class HpListScreen extends StatefulWidget {
  static const pageRoute = 'hp_list_screen';
  @override
  _HpListScreenState createState() => _HpListScreenState();
}

class _HpListScreenState extends State<HpListScreen> {
  @override
  Widget build(BuildContext context) {
    List<HpUserData> users = Provider.of<Users>(context).hpUserData;
    return Scaffold(
      appBar: AppBar(
        //custom appbar to be created later for efficiency
        title: Text('Healthcare Professionals'),
      ),
      drawer: CAppDrawer(),
      body: Container(
        color: Colors.black12,
        child: ListView.builder(
          itemCount: users.length,
          itemBuilder: (ctx, i) => Card(
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 10,
            child: Container(
              height: 100,
              child: Row(
                children: <Widget>[
                  Container(
                    width: 100,
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xff00c4ac),
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: NetworkImage(users[i].pictureUrl),
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                    //image holder
                  ),
                  Container(
                    width: 160,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Rating here',
                          style: TextStyle(color: Colors.black54),
                        ),
                        Text(
                          '${users[i].fname} ${users[i].lname}',
                          softWrap: true,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          '${kProfessions[users[i].professionIndex].specialisationProfession} | ${users[i].age}',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  Container(
//                    width: 110,
                    padding: EdgeInsets.all(5),
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          height: 60,
                          child: VerticalDivider(
                            thickness: 0.5,
                            color: Colors.black,
                          ),
                        ),
                        Text('Available'),
                        Icon(
                          Icons.panorama_fish_eye,
                          color: Colors.green,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
