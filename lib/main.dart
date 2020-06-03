import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/auth_screen.dart';
import './providers/auth.dart';
import './screens/client_home_screen.dart';
import './screens/welcome_screen.dart';
import './utilities/custom_route.dart';
import './screens/user_details_collect_screen.dart';
import './providers/users.dart';
import './screens/hp_list_screen.dart';
import './screens/hp_home_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Auth(),
        ),
        ChangeNotifierProvider(
          create: (_) => Users(),
        ),
      ],
      child: MaterialApp(
        title: 'Hi-Life',
        theme: ThemeData(
          primarySwatch: Colors.orange,
          accentColor: Colors.deepOrangeAccent,
          fontFamily: 'Lato',
          pageTransitionsTheme: PageTransitionsTheme(
            builders: {
              TargetPlatform.android: CustomPageTransitionBuilder(),
            },
          ),
        ),
        home: WelcomeScreen(),
        routes: {
          AuthScreen.pageRoute: (ctx) => AuthScreen(),
          ClientHomeScreen.pageRoute: (ctx) => ClientHomeScreen(),
          WelcomeScreen.pageRoute: (ctx) => WelcomeScreen(),
          UserDetailsScreen.pageRoute: (ctx) => UserDetailsScreen(),
          HpListScreen.pageRoute: (ctx) => HpListScreen(),
          HpHomeScreen.pageRoute: (ctx) => HpHomeScreen(),
        },
      ),
    );
  }
}
