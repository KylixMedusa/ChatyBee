import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../widgets/app_bar.dart';
import '../theme/themeModel.dart';
import '../animations/PhotoHero.dart';

class Settings extends StatefulWidget {
  Settings({Key key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final User user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    final storage = Provider.of<FlutterSecureStorage>(context);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).hintColor,
      appBar: CustomAppBar(
        title: 'Me',
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
        children: [
          Container(
            padding: EdgeInsets.only(bottom: 20),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                border: Border(
                    bottom: Theme.of(context).brightness == Brightness.dark
                        ? BorderSide(color: Colors.grey[900])
                        : BorderSide(color: Colors.grey[300]))),
            child: StreamBuilder(
                stream: firestore.collection('users').doc(user.uid).snapshots(),
                builder: (ctx,
                    AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                        snapshot) {
                  final Widget avatar =
                      snapshot.data != null && snapshot.data["avatar"] != null
                          ? Image.network(snapshot.data["avatar"],
                              fit: BoxFit.contain, width: 150)
                          : Image.asset('assets/images/user.png',
                              fit: BoxFit.contain, width: 150);
                  final String name =
                      snapshot.data != null && snapshot.data["name"] != null
                          ? snapshot.data["name"]
                          : "Loading...";
                  String status =
                      snapshot.data != null && snapshot.data["status"] != null
                          ? snapshot.data["status"]
                          : '';
                  return Column(
                    children: [
                      Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100.0)),
                        child: PhotoHero(
                          onTap: () {},
                          page: 'home',
                          child: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100.0),
                              child: avatar,
                            ),
                          ),
                        ),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: size.width * 0.8),
                        child: Text(name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headline2),
                      ),
                      Padding(padding: EdgeInsets.only(top: 5)),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: size.width * 0.6),
                        child: Text(status,
                            style: Theme.of(context).textTheme.bodyText2),
                      ),
                    ],
                  );
                }),
          ),
          Padding(padding: EdgeInsets.only(top: 10)),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[800],
              child: FaIcon(FontAwesomeIcons.solidMoon, color: Colors.white),
            ),
            title:
                Text('Dark Mode', style: Theme.of(context).textTheme.headline5),
            trailing: Consumer<ThemeModel>(builder: (_, model, __) {
              return Switch(
                activeColor: Theme.of(context).accentColor,
                onChanged: (bool value) {
                  model.toggleMode(value ? ThemeMode.dark : ThemeMode.light);
                  storage.write(key: 'dark', value: value ? 'true' : null);
                },
                value: model.mode == ThemeMode.dark ? true : false,
              );
            }),
          ),
        ],
      ),
    );
  }
}
