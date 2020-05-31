import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../screens/hp_list_screen.dart';
import '../screens/client_home_screen.dart';

class CAppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: const Text('Drawer'),
            automaticallyImplyLeading: false,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.exit_to_app),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed('/');
                  Provider.of<Auth>(context, listen: false).signOut();
                },
              ),
            ],
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () =>
                Navigator.pushNamed(context, ClientHomeScreen.pageRoute),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('Profile'),
            onTap: () {},
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('Health Professionals'),
            onTap: () => Navigator.pushNamed(context, HpListScreen.pageRoute),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.content_paste),
            title: Text('Health Details'),
            onTap: () {},
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Log-Out'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
              Provider.of<Auth>(context, listen: false).signOut();
            },
          ),
        ],
      ),
    );
  }
}
