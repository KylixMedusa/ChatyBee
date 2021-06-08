import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatroomsSearch extends SearchDelegate<dynamic> {
  ChatroomsSearch();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final User user = FirebaseAuth.instance.currentUser;

  @override
  ThemeData appBarTheme(BuildContext context) {
    assert(context != null);
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    assert(theme != null);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        elevation: 1,
        brightness: colorScheme.brightness,
        backgroundColor: colorScheme.brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.white,
        iconTheme: theme.primaryIconTheme.copyWith(color: Colors.grey),
        textTheme: theme.textTheme,
      ),
      inputDecorationTheme: searchFieldDecorationTheme ??
          InputDecorationTheme(
            hintStyle: searchFieldStyle ?? theme.inputDecorationTheme.hintStyle,
            border: InputBorder.none,
          ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Clear',
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Theme.of(context).hintColor,
        child: buildList(context));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Theme.of(context).hintColor,
        child: buildList(context));
  }

  List<DocumentSnapshot<Map<String, dynamic>>> contacts;

  loadData(StateSetter setState) async {
    if (contacts == null) {
      List<QueryDocumentSnapshot<Map<String, dynamic>>> connections =
          (await firestore
                      .collection('users')
                      .doc(user.uid)
                      .collection('connections')
                      .get())
                  .docs ??
              [];
      List<DocumentSnapshot<Map<String, dynamic>>> users = [];
      for (var connection in connections) {
        DocumentSnapshot<Map<String, dynamic>> user =
            await firestore.collection('users').doc(connection.id).get();
        users.add(user);
      }

      setState(() {
        contacts = [...users];
      });
    }
  }

  Widget buildList(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      loadData(setState);
      if (contacts == null)
        return Center(
          child: CircularProgressIndicator(),
        );
      List<DocumentSnapshot<Map<String, dynamic>>> result = queryFilter();
      return ListView.builder(
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
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(color: Colors.grey)),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
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
                                            color:
                                                Theme.of(context).hintColor)),
                                  ))
                          ])),
                      title: Text(contact["name"] ?? "",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.headline5.copyWith(
                              fontSize: 18.0, fontWeight: FontWeight.w600)),
                      subtitle: Row(children: [
                        Expanded(
                            child: StreamBuilder(
                                stream: firestore
                                    .collection('message')
                                    .doc(getChatroomId(contact.id))
                                    .collection('messages')
                                    .orderBy('time', descending: true)
                                    .limit(1)
                                    .snapshots(),
                                builder:
                                    (ctx2, AsyncSnapshot<QuerySnapshot> snap) {
                                  if (snap.connectionState ==
                                          ConnectionState.waiting &&
                                      !snap.hasData) {
                                    return Container();
                                  }
                                  final _chats = snap.data?.docs ?? [];
                                  final chat =
                                      _chats.length > 0 ? _chats[0] : null;
                                  var content = "";
                                  if (chat != null && chat["type"] == "text")
                                    content = chat["text"];
                                  else if (chat != null &&
                                      chat["type"] == "file")
                                    content = 'File:${chat["file"]["name"]}';
                                  else
                                    content = "";
                                  return Text(content,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .copyWith(
                                              fontWeight: FontWeight.w200));
                                })),
                        StreamBuilder(
                            stream: firestore
                                .collection('message')
                                .doc(getChatroomId(contact.id))
                                .collection('messages')
                                .where('senderId', isNotEqualTo: user.uid)
                                .where('seen', isEqualTo: false)
                                .snapshots(),
                            builder: (ctx2, AsyncSnapshot<QuerySnapshot> snap) {
                              if (snap.connectionState ==
                                      ConnectionState.waiting &&
                                  !snap.hasData) {
                                return Text("");
                              }
                              final _chats = snap.data?.docs ?? [];
                              final length = _chats.length ?? 0;
                              return length > 0
                                  ? ConstrainedBox(
                                      constraints: BoxConstraints(minWidth: 20),
                                      child: Container(
                                          height: 20,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              color:
                                                  Theme.of(context).accentColor,
                                              borderRadius:
                                                  BorderRadius.circular(100)),
                                          child: Text(length.toString(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2
                                                  .copyWith(
                                                      color: Theme.of(context)
                                                          .primaryColor))),
                                    )
                                  : Container();
                            })
                      ]),
                    )),
              ),
            );
          });
    });
  }

  List<DocumentSnapshot<Map<String, dynamic>>> queryFilter() {
    if (query == null || query == "") {
      return contacts;
    }
    var newContacts = [...contacts];
    newContacts.retainWhere((element) =>
        element["name"].toLowerCase().contains(query.toLowerCase()));
    return newContacts;
  }

  String getChatroomId(String id) {
    if (user.uid.compareTo(id) < 0) {
      return '${user.uid}_$id';
    } else {
      return '${id}_${user.uid}';
    }
  }
}
