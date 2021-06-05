import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './provider/snackbarStore.dart';
import 'screens/connectivity_wrapper.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/welcome.dart';
import 'theme/theme.dart';
import 'animations/slideRoute.dart';
import 'screens/profile_add.dart';

final SnackbarStore snackbarStore = SnackbarStore();

void main() async {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityWrapper(
      child: MultiProvider(
        providers: [
          Provider<SnackbarStore>(
            create: (_) => SnackbarStore(),
          ),
        ],
        child: MaterialApp(
          theme: kLightTheme,
          debugShowCheckedModeBanner: false,
          home: Welcome(),
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/login':
                return SlideRightRoute(page: Login());
                break;
              case '/register':
                return SlideRightRoute(page: Register());
                break;
              case '/profile-add':
                return SlideRightRoute(page: ProfileAdd());
                break;
              default:
                return MaterialPageRoute(builder: (ctx) => Welcome());
            }
          },
        ),
      ),
    );
  }
}

//flutter packages pub run build_runner build
