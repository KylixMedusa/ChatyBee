import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import './provider/snackbarStore.dart';
import 'animations/fadeRoute.dart';
import 'screens/chat.dart';
import 'screens/connectivity_wrapper.dart';
import 'screens/contacts.dart';
import 'screens/home.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/settings.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome.dart';
import 'screens/phone_verify.dart';
import 'theme/theme.dart';
import 'animations/slideRoute.dart';
import 'screens/profile_add.dart';
import 'theme/themeModel.dart';

final SnackbarStore snackbarStore = SnackbarStore();
final FlutterSecureStorage storage = FlutterSecureStorage();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true);
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
            create: (_) => snackbarStore,
          ),
          Provider<FlutterSecureStorage>(
            create: (_) => storage,
          ),
        ],
        child: ChangeNotifierProvider<ThemeModel>(
          create: (_) => ThemeModel(storage),
          child: Consumer<ThemeModel>(builder: (_, model, __) {
            return MaterialApp(
              theme: kLightTheme,
              darkTheme: kDarkTheme,
              debugShowCheckedModeBanner: false,
              themeMode: model.mode,
              home: CustomSplashScreen(),
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
                  case '/phone-verify':
                    return SlideRightRoute(page: PhoneVerify());
                    break;
                  case '/contacts':
                    return SlideTopRoute(page: ContactsList());
                    break;
                  case '/home':
                    return FadeRoute(page: Home());
                    break;
                  case '/settings':
                    return FadeRoute(page: Settings());
                    break;
                  case '/welcome':
                    return FadeRoute(page: Welcome());
                    break;
                  case '/chat':
                    final String id = settings.arguments;
                    return SlideRightRoute(
                        page: ChatPage(
                      recieverId: id,
                    ));
                    break;
                  default:
                    return MaterialPageRoute(builder: (ctx) => Welcome());
                }
              },
            );
          }),
        ),
      ),
    );
  }
}

//flutter packages pub run build_runner build
