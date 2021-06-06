import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '../widgets/app_bar.dart';
import '../widgets/rounded_button.dart';
import '../widgets/Snackbar.dart';
import '../widgets/rounded_input_field.dart';
import '../provider/snackbarStore.dart';

class PhoneVerify extends StatefulWidget {
  PhoneVerify({Key key}) : super(key: key);

  @override
  _PhoneVerifyState createState() => _PhoneVerifyState();
}

class _PhoneVerifyState extends State<PhoneVerify> {
  verifyPhone(SnackbarStore snackbarStore) async {
    if (_formKey.currentState.validate()) {
      snackbarStore.add(SnackbarType(
        message: "Adding your phone number!!!",
        showProgressIndicator: true,
        margin: EdgeInsets.all(10),
        borderRadius: 4,
        duration: null,
        isDismissible: false,
      ));
      try {
        await firestore
            .collection('users')
            .doc(user.uid)
            .set({'phone': '+91${_controller.text}'}, SetOptions(merge: true));
        snackbarStore.remove();
        Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
      } on FirebaseException catch (_) {
        snackbarStore.add(SnackbarType(
          message: "Failed..Retry!!!",
          margin: EdgeInsets.all(10),
          borderRadius: 4,
          duration: Duration(seconds: 2),
          isDismissible: true,
        ));
      }
    }
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final User user = FirebaseAuth.instance.currentUser;
  TextEditingController _controller = new TextEditingController();
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    SnackbarStore snackbarStore = Provider.of<SnackbarStore>(context);
    final storage = Provider.of<FlutterSecureStorage>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).hintColor,
      appBar: CustomAppBar(
          title: "Add Phone",
          onBackPressed: () async {
            await FirebaseAuth.instance.signOut();
            await storage.delete(key: 'email');
            await storage.delete(key: 'password');
            Navigator.popAndPushNamed(context, '/register');
          }),
      body: Snackbar(
        child: Column(
          children: [
            Expanded(
              child: ListView(children: [
                Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFieldContainer(
                          child: TextFormField(
                            controller: _controller,
                            maxLines: 1,
                            maxLength: 10,
                            cursorColor: Theme.of(context).accentColor,
                            enableSuggestions: true,
                            style: Theme.of(context).textTheme.headline5,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            keyboardType: TextInputType.phone,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            validator: (String val) => val.length > 0
                                ? val.length < 10
                                    ? "Phone should have 10 digits"
                                    : null
                                : "Phone should not be empty",
                            decoration: InputDecoration(
                              counterText: "",
                              errorStyle: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  .copyWith(color: Colors.red),
                              icon: CircleAvatar(
                                backgroundColor: Colors.transparent,
                                child: Text("+91",
                                    style:
                                        Theme.of(context).textTheme.headline5),
                              ),
                              hintText: "Mobile No*",
                              hintStyle: Theme.of(context).textTheme.bodyText2,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                              "**Provide your phone number and an OTP will be send to your phone to verify your phone number.",
                              style: Theme.of(context).textTheme.bodyText2),
                        )
                      ],
                    ))
              ]),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
              child: Row(
                children: [
                  Expanded(
                      child: RoundedButton(
                    text: "Add Phone Number",
                    press: () => verifyPhone(snackbarStore),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
