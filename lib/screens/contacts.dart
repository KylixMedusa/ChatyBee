import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../widgets/Snackbar.dart';
import '../widgets/contacts_search.dart';

class ContactsList extends StatefulWidget {
  ContactsList({Key key}) : super(key: key);

  @override
  _ContactsListState createState() => _ContactsListState();
}

class _ContactsListState extends State<ContactsList> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  // Iterable<Contact> contacts = await ContactsService.getContacts(withThumbnails: false);
  ScrollController _scrollController;
  double _elevation = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = new ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    double newElevation = _scrollController.offset > 1 ? 1 : 0;
    if (_elevation != newElevation) {
      setState(() {
        _elevation = newElevation;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).hintColor,
      appBar: AppBar(
        elevation: _elevation,
        backgroundColor: Theme.of(context).hintColor,
        leading: IconButton(
            splashRadius: 24,
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context)),
        titleSpacing: 5,
        title: FittedBox(
            fit: BoxFit.scaleDown,
            child:
                Text('Contacts', style: Theme.of(context).textTheme.headline3)),
        actions: <Widget>[
          IconButton(
            splashRadius: 24,
            icon: Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () {
              showSearch(
                  context: context,
                  delegate: ContactsSearch(this.result ?? []));
            },
          ),
          // IconButton(
          //   splashRadius: 24,
          //   icon: Icon(Icons.refresh),
          //   tooltip: 'Refresh',
          //   onPressed: () {
          //     // handle the press
          //   },
          // ),
        ],
      ),
      body: Snackbar(
        child: Container(
          width: size.width,
          height: double.infinity,
          child: FutureBuilder(
              future: getContacts(),
              builder: (cntx, AsyncSnapshot<Iterable<Contact>> snapshot) {
                if (snapshot.data == null) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                List<Contact> contacts = snapshot.data.toList() ?? [];
                List<String> phones = [];
                for (Contact contact in contacts) {
                  phones.addAll(contact.phones
                      .map((phone) => normalizePhone(phone.value)));
                }
                return StreamBuilder(
                    stream: firestore.collection('users').snapshots(),
                    builder: (ctx,
                        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                            snap) {
                      if (snap.data == null) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      List<QueryDocumentSnapshot<Map<String, dynamic>>> users =
                          snap.data.docs ?? [];
                      users.removeWhere((element) => element.id == user.uid);
                      return buildList(phones, users);
                    });
              }),
        ),
      ),
    );
  }

  final User user = FirebaseAuth.instance.currentUser;

  Widget buildList(List<String> phones,
      List<QueryDocumentSnapshot<Map<String, dynamic>>> users) {
    return FutureBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
        future: shuffleBothLists(phones, users),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scrollbar(
              isAlwaysShown: false,
              radius: Radius.circular(25),
              hoverThickness: 14,
              child: ListView.builder(
                controller: _scrollController,
                physics: ClampingScrollPhysics(),
                itemCount: result.length,
                itemBuilder: (ctx, index) {
                  var contact = result[index];
                  final Widget avatar = contact["avatar"] != null
                      ? Image.network(contact["avatar"])
                      : Image.asset('assets/images/user.png');
                  return Material(
                    type: MaterialType.card,
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed('/chat', arguments: contact.id);
                      },
                      child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: ListTile(
                            dense: true,
                            horizontalTitleGap: 10,
                            minVerticalPadding: 8,
                            contentPadding: EdgeInsets.symmetric(horizontal: 0),
                            isThreeLine: true,
                            leading: CircleAvatar(
                                radius: 26,
                                child: Stack(children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        border: Border.all(color: Colors.grey)),
                                    child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: avatar),
                                  ),
                                  if (contact["online"])
                                    Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          width: 15,
                                          height: 15,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              color: Colors.green,
                                              border: Border.all(
                                                  color: Theme.of(context)
                                                      .hintColor)),
                                        ))
                                ])),
                            title: Text(contact["name"] ?? "",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5
                                    .copyWith(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w600)),
                            subtitle: Text(contact["status"] ?? "",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    .copyWith(fontWeight: FontWeight.w200)),
                          )),
                    ),
                  );
                },
              ),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> shuffleBothLists(
      List<String> phones,
      List<QueryDocumentSnapshot<Map<String, dynamic>>> users) async {
    List<QueryDocumentSnapshot<Map<String, dynamic>>> result = [];

    for (QueryDocumentSnapshot<Map<String, dynamic>> s in users) {
      if (phones.contains(s["phone"]) && !result.contains(s)) {
        result.add(s);
      }
    }

    result.sort((a, b) => a["name"].compareTo(b["name"]));

    this.result = [...result];

    return result;
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> result;

  Future<Iterable<Contact>> getContacts() async {
    PermissionStatus status = await Permission.contacts.request();
    if (status == PermissionStatus.granted ||
        status == PermissionStatus.limited) {
      return ContactsService.getContacts(withThumbnails: false);
    }
    return null;
  }

  String normalizePhone(String phone) {
    String newPhone =
        '+91${(phone.replaceAll('+91', '')).replaceAll(new RegExp(r"\D"), "")}';
    return newPhone;
  }
}
