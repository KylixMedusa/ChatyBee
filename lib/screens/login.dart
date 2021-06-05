import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/rounded_button.dart';
import '../widgets/rounded_input_field.dart';
import '../provider/snackbarStore.dart';
import '../widgets/Snackbar.dart';

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  void login(SnackbarStore snackbarStore) async {
    if (_formKey.currentState.validate()) {
      snackbarStore.add(SnackbarType(
        message: "Logging In!!!",
        showProgressIndicator: true,
        margin: EdgeInsets.all(10),
        borderRadius: 4,
        duration: null,
        isDismissible: false,
      ));
      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        snackbarStore.remove();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          snackbarStore.add(SnackbarType(
            message: "Invalid email!!!",
            margin: EdgeInsets.all(10),
            borderRadius: 4,
            duration: Duration(seconds: 2),
            isDismissible: true,
          ));
        } else if (e.code == 'wrong-password') {
          snackbarStore.add(SnackbarType(
            message: "Wrong password!!!",
            margin: EdgeInsets.all(10),
            borderRadius: 4,
            duration: Duration(seconds: 2),
            isDismissible: true,
          ));
        } else {
          snackbarStore.add(SnackbarType(
            message: "Internal error..Retry!!!",
            margin: EdgeInsets.all(10),
            borderRadius: 4,
            duration: Duration(seconds: 2),
            isDismissible: true,
          ));
        }
      }
    }
  }

  String email, password;
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    SnackbarStore snackbarStore = Provider.of<SnackbarStore>(context);
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
                  width: size.width * 0.35,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Image.asset(
                  "assets/images/login_bottom.png",
                  width: size.width * 0.4,
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "LOGIN",
                        style: Theme.of(context).textTheme.headline2,
                      ),
                      SizedBox(height: size.height * 0.03),
                      Image.asset(
                        "assets/images/login.png",
                        height: size.height * 0.3,
                      ),
                      SizedBox(height: size.height * 0.03),
                      Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RoundedEmailField(
                              hintText: "Your Email*",
                              onChanged: (value) {
                                setState(() {
                                  email = value;
                                });
                              },
                            ),
                            RoundedPasswordField(
                              onChanged: (value) {
                                setState(() {
                                  password = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: size.height * 0.03),
                      RoundedButton(
                        text: "LOGIN",
                        press: () {
                          this.login(snackbarStore);
                        },
                      ),
                      SizedBox(height: size.height * 0.03),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("Don’t have an Account ?",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5
                                  .copyWith(
                                      color: Theme.of(context).accentColor)),
                          Padding(padding: EdgeInsets.only(left: 10)),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            child: Text(
                              "Sign Up",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5
                                  .copyWith(
                                      color: Theme.of(context).accentColor,
                                      fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                      // SizedBox(height: size.height * 0.01),
                      // ConstrainedBox(
                      //   constraints: BoxConstraints(
                      //     maxWidth: 350,
                      //   ),
                      //   child: Container(
                      //     width: size.width * 0.8,
                      //     child: Column(
                      //       children: [
                      //         Row(
                      //             mainAxisSize: MainAxisSize.min,
                      //             children: <Widget>[
                      //               Expanded(child: Divider()),
                      //               Padding(
                      //                   padding:
                      //                       EdgeInsets.symmetric(horizontal: 10),
                      //                   child: Text("or")),
                      //               Expanded(child: Divider()),
                      //             ]),
                      //         SizedBox(height: size.height * 0.02),
                      //         Row(
                      //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //           children: [
                      //             ClipRRect(
                      //               borderRadius:
                      //                   BorderRadius.all(Radius.circular(100)),
                      //               child: Material(
                      //                 child: Ink(
                      //                   decoration: ShapeDecoration(
                      //                     color: Color.fromRGBO(27, 118, 244, 1),
                      //                     shape: CircleBorder(),
                      //                   ),
                      //                   child: IconButton(
                      //                       color: Theme.of(context).primaryColor,
                      //                       icon: FaIcon(
                      //                           FontAwesomeIcons.facebookF),
                      //                       onPressed: () {}),
                      //                 ),
                      //               ),
                      //             ),
                      //             ClipRRect(
                      //               borderRadius:
                      //                   BorderRadius.all(Radius.circular(100)),
                      //               child: Material(
                      //                 child: Ink(
                      //                   decoration: ShapeDecoration(
                      //                     color: Color.fromRGBO(219, 74, 57, 1),
                      //                     shape: CircleBorder(),
                      //                   ),
                      //                   child: IconButton(
                      //                       color: Theme.of(context).primaryColor,
                      //                       icon: FaIcon(
                      //                           FontAwesomeIcons.googlePlusG),
                      //                       onPressed: () {}),
                      //                 ),
                      //               ),
                      //             ),
                      //             ClipRRect(
                      //               borderRadius:
                      //                   BorderRadius.all(Radius.circular(100)),
                      //               child: Material(
                      //                 child: Ink(
                      //                   decoration: ShapeDecoration(
                      //                     color: Color.fromRGBO(0, 0, 0, 1),
                      //                     shape: CircleBorder(),
                      //                   ),
                      //                   child: IconButton(
                      //                       color: Theme.of(context).primaryColor,
                      //                       icon: FaIcon(FontAwesomeIcons.apple),
                      //                       onPressed: () {}),
                      //                 ),
                      //               ),
                      //             )
                      //           ],
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
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
