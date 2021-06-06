import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

class CustomSplashScreen extends StatefulWidget {
  CustomSplashScreen({Key key}) : super(key: key);

  @override
  _CustomSplashScreenState createState() => _CustomSplashScreenState();
}

class _CustomSplashScreenState extends State<CustomSplashScreen> {
  final Future<FirebaseApp> _init = Firebase.initializeApp();

  void loginHandler(FlutterSecureStorage storage) async {
    final String email = await storage.read(key: "email");
    final String password = await storage.read(key: "password");
    final String isNew = await storage.read(key: "isNew");
    if (email != null && email != "" && password != null && password != "") {
      try {
        final UserCredential credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        final DocumentSnapshot<Map<String, dynamic>> doc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(credential.user.uid)
                .get();
        if (doc != null && doc["phone"] != null) {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(
              context, '/phone-verify', (_) => false);
        }
      } catch (e) {
        Navigator.popAndPushNamed(context, '/login');
      }
    } else {
      if (isNew == null || isNew == "true") {
        Navigator.popAndPushNamed(context, '/welcome');
      } else {
        Navigator.popAndPushNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final storage = Provider.of<FlutterSecureStorage>(context);
    loginHandler(storage);
    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      body: SafeArea(
          child: Stack(
        children: [
          Positioned.fill(
            child: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 200),
                      child: Image.asset('assets/images/logo.png',
                          width: MediaQuery.of(context).size.width * 0.5),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Chaty",
                            style: Theme.of(context)
                                .textTheme
                                .headline2
                                .copyWith(color: Colors.white)),
                        Text("Bee",
                            style: Theme.of(context).textTheme.headline2),
                      ],
                    )
                  ],
                ),
                CircularProgressIndicator(
                  backgroundColor: Theme.of(context).hintColor,
                )
              ],
            )),
          ),
        ],
      )),
    );
  }
}
