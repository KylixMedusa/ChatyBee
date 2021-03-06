import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../widgets/rounded_button.dart';
import '../widgets/Snackbar.dart';

class Welcome extends StatefulWidget {
  const Welcome({Key key}) : super(key: key);

  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  void _init() async {
    final storage = Provider.of<FlutterSecureStorage>(context, listen: false);
    await storage.write(key: "isNew", value: 'true');
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    _init();
    return Scaffold(
      backgroundColor: Theme.of(context).hintColor,
      body: Snackbar(
        child: Container(
          height: size.height,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned(
                top: 0,
                left: 0,
                child: Image.asset(
                  "assets/images/main_top.png",
                  width: size.width * 0.3,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Image.asset(
                  "assets/images/main_bottom.png",
                  width: size.width * 0.2,
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "WELCOME",
                        style: Theme.of(context).textTheme.headline2,
                      ),
                      SizedBox(height: size.height * 0.05),
                      Image.asset(
                        "assets/images/chat.png",
                        height: size.height * 0.45,
                      ),
                      SizedBox(height: size.height * 0.05),
                      RoundedButton(
                        text: "LOGIN",
                        press: () {
                          Navigator.pushNamed(context, "/login");
                        },
                      ),
                      RoundedButton(
                        text: "SIGN UP",
                        color: Theme.of(context).focusColor,
                        textColor: Colors.black,
                        press: () {
                          Navigator.pushNamed(context, "/register");
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
