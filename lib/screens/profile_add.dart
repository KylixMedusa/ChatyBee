import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../widgets/app_bar.dart';
import '../widgets/rounded_button.dart';
import '../widgets/Snackbar.dart';
import '../widgets/rounded_input_field.dart';
import '../provider/snackbarStore.dart';

class ProfileAdd extends StatefulWidget {
  ProfileAdd({Key key}) : super(key: key);

  @override
  _ProfileAddState createState() => _ProfileAddState();
}

class _ProfileAddState extends State<ProfileAdd> {
  openCamera() async {
    var image = await ImagePicker().getImage(source: ImageSource.camera);
    cropImage(image);
  }

  openGallery() async {
    var image = await ImagePicker().getImage(source: ImageSource.gallery);
    cropImage(image);
  }

  Future cropImage(PickedFile image) async {
    File croppedFile = await ImageCropper.cropImage(
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      sourcePath: image.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      maxWidth: 512,
      maxHeight: 512,
    );
    setState(() {
      pickedFile = croppedFile;
    });
  }

  update(SnackbarStore snackbarStore) async {
    if (_formKey.currentState.validate()) {
      snackbarStore.add(SnackbarType(
        message: "Creating your profile!!!",
        showProgressIndicator: true,
        margin: EdgeInsets.all(10),
        borderRadius: 4,
        duration: null,
        isDismissible: false,
      ));
      String fileName = pickedFile.path.split('/').last;
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('uploads/$fileName');
      try {
        await firebaseStorageRef.putFile(pickedFile);

        await firestore.collection('users').doc(user.uid).set({
          'avatar': firebaseStorageRef.getDownloadURL(),
          'name': _values["name"],
          'status': _values["status"],
          'online': true
        }, SetOptions(merge: true));
        snackbarStore.remove();
      } on FirebaseException catch (_) {
        snackbarStore.add(SnackbarType(
          message: "Picture couldn't be uploaded..Retry!!!",
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

  File pickedFile;

  Map<String, String> _values = {"name": "", "status": ""};

  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    SnackbarStore snackbarStore = Provider.of<SnackbarStore>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).hintColor,
      appBar: CustomAppBar(
          title: "Profile",
          onBackPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.popAndPushNamed(context, '/register');
          }),
      body: Snackbar(
        child: Column(
          children: [
            Expanded(
              child: ListView(children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 170,
                  child: Stack(
                    children: [
                      Positioned.fill(
                          bottom: 10,
                          child: Center(
                            child: Card(
                                elevation: 6,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100.0)),
                                child: Padding(
                                  padding: const EdgeInsets.all(1.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100.0),
                                    child: pickedFile != null
                                        ? Image.file(new File(pickedFile.path),
                                            fit: BoxFit.contain, width: 150)
                                        : Image.asset("assets/images/user.png",
                                            fit: BoxFit.contain, width: 150),
                                  ),
                                )),
                          )),
                      Positioned(
                          bottom: 20,
                          right: MediaQuery.of(context).size.width / 2 - 100,
                          child: PopupMenuButton(
                              elevation: 6,
                              tooltip: "Edit",
                              child: Material(
                                type: MaterialType.circle,
                                color: Theme.of(context).accentColor,
                                child: IconButton(
                                  icon: Icon(Icons.edit, color: Colors.white),
                                  onPressed: null,
                                ),
                              ),
                              onSelected: (val) async {
                                switch (val) {
                                  case 1:
                                    openGallery();
                                    break;
                                  case 2:
                                    openCamera();
                                    break;
                                }
                              },
                              itemBuilder: (context) => [
                                    PopupMenuItem(
                                        value: 1,
                                        child: Text('Select from Gallery',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline5)),
                                    PopupMenuItem(
                                        value: 2,
                                        child: Text('Capture Image',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline5)),
                                  ]))
                    ],
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 20)),
                Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFieldContainer(
                          child: TextFormField(
                            initialValue: _values["name"],
                            onChanged: (String val) {
                              setState(() {
                                _values["name"] = val;
                              });
                            },
                            maxLines: null,
                            maxLength: 25,
                            cursorColor: Theme.of(context).accentColor,
                            enableSuggestions: true,
                            style: Theme.of(context).textTheme.headline5,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (String val) => val.length > 0
                                ? val.length > 25
                                    ? "Name should have less than 25 characters"
                                    : null
                                : "Name should not be empty",
                            decoration: InputDecoration(
                              counterText: "",
                              errorStyle: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  .copyWith(color: Colors.red),
                              icon: Icon(
                                Icons.person,
                                color: Theme.of(context).accentColor,
                              ),
                              hintText: "Name*",
                              hintStyle: Theme.of(context).textTheme.bodyText2,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        TextFieldContainer(
                          child: TextFormField(
                            initialValue: _values["status"],
                            onChanged: (String val) {
                              setState(() {
                                _values["status"] = val;
                              });
                            },
                            maxLines: null,
                            maxLength: 150,
                            cursorColor: Theme.of(context).accentColor,
                            enableSuggestions: true,
                            style: Theme.of(context).textTheme.headline5,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (String val) => val.length > 0
                                ? val.length > 150
                                    ? "Status should have less than 150 characters"
                                    : null
                                : "Status should not be empty",
                            decoration: InputDecoration(
                              counterText: "",
                              errorStyle: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  .copyWith(color: Colors.red),
                              icon: Icon(
                                Icons.message,
                                color: Theme.of(context).accentColor,
                              ),
                              hintText: "Status*",
                              hintStyle: Theme.of(context).textTheme.bodyText2,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
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
                    text: "Create",
                    press: () => update(snackbarStore),
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
