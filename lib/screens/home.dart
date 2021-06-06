import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../widgets/Snackbar.dart';
import '../widgets/profile_pic_view.dart';

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final User user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setOnlineStatus(true);
    });
  }

  @override
  void dispose() {
    super.dispose();
    setOnlineStatus(false);
  }

  setOnlineStatus(bool val) {
    DocumentReference doc = firestore.collection('users').doc(user.uid);
    doc.set(<String, dynamic>{'online': val}, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).hintColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: StreamBuilder(
            stream: firestore.collection('users').doc(user.uid).snapshots(),
            builder: (ctx,
                AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                    snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.data == null ||
                  snapshot.data["avatar"] == null) {
                return ProfilePicView(
                  picture: Image.asset('assets/images/user.png'),
                );
              }
              return ProfilePicView(
                  picture: Image.network(snapshot.data["avatar"]));
            }),
        titleSpacing: 5,
        title: FittedBox(
            fit: BoxFit.scaleDown,
            child:
                Text('Messages', style: Theme.of(context).textTheme.headline3)),
      ),
      body: Snackbar(
        child: Container(
          width: size.width,
          height: double.infinity,
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  width: size.width * 0.9,
                  alignment: Alignment.center,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(29),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        backgroundColor: Theme.of(context).focusColor,
                      ),
                      onPressed: () {},
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search,
                            color: Colors.black,
                            size: 20,
                          ),
                          Padding(padding: EdgeInsets.only(left: 10)),
                          Text(
                            'Search',
                            style: Theme.of(context).textTheme.headline5,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                generateList()
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).accentColor,
        child: Icon(Icons.message),
        onPressed: () {
          Navigator.pushNamed(context, '/contacts');
        },
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(25),
                bottomLeft: Radius.circular(100),
                topRight: Radius.circular(100),
                topLeft: Radius.circular(100))),
      ),
    );
  }

  Widget generateList() {
    return StreamBuilder(
        stream: firestore
            .collection('users')
            .doc(user.uid)
            .collection('connections')
            .snapshots(),
        builder:
            (ctx, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final _chatrooms = snapshot.data?.docs ?? [];
          final ids = _chatrooms.map((e) => e.id).toSet();
          _chatrooms.retainWhere((x) => ids.remove(x.id));
          _chatrooms.sort((i, j) {
            return DateTime.parse(j["updatedAt"].toString())
                .difference(DateTime.parse(i["updatedAt"].toString()))
                .inMilliseconds;
          });
          return _chatrooms.length > 0
              ? ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                  itemCount: _chatrooms.length,
                  itemBuilder: (ctx, index) {
                    final chatroom = _chatrooms[index];
                    return buildListTile(chatroom);
                  },
                )
              : Center(
                  child: ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      Center(
                          child: Text("No chats found",
                              style: Theme.of(context).textTheme.headline5))
                    ],
                  ),
                );
        });
  }

  String format(String date) {
    var dateTime = DateTime.parse(date);
    var differnce = dateTime.difference(DateTime.now()).inDays.abs();
    bool daySame = dateTime.day == DateTime.now().day;
    if (differnce == 0 && daySame) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (differnce == 1 || (differnce == 0 && !daySame)) {
      return 'Yesterday';
    }
    return DateFormat('dd MMMM, yyyy').format(dateTime);
  }

  String getChatroomId(String id) {
    if (user.uid.compareTo(id) < 0) {
      return '${user.uid}_$id';
    } else {
      return '${id}_${user.uid}';
    }
  }

  Widget buildListTile(QueryDocumentSnapshot<Map<String, dynamic>> chatroom) {
    return StreamBuilder(
        stream: firestore.collection('users').doc(chatroom.id).snapshots(),
        builder: (ctx,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          final Widget avatar =
              snapshot.data != null && snapshot.data["avatar"] != null
                  ? Image.network(snapshot.data["avatar"])
                  : Image.asset('assets/images/user.png');
          final String name =
              snapshot.data != null && snapshot.data["name"] != null
                  ? snapshot.data["name"]
                  : "Loading...";
          final bool online =
              snapshot.data != null && snapshot.data["online"] != null
                  ? snapshot.data["online"]
                  : false;
          return Material(
            type: MaterialType.card,
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context)
                    .pushNamed('/chat', arguments: chatroom.id);
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
                          if (online)
                            Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 15,
                                  height: 15,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      color: Colors.green,
                                      border: Border.all(
                                          color: Theme.of(context).hintColor)),
                                ))
                        ])),
                    title: Row(children: [
                      Expanded(
                          child: Text(name,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5
                                  .copyWith(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600))),
                      Text(format(chatroom["updatedAt"].toString()),
                          style: Theme.of(context).textTheme.bodyText2),
                    ]),
                    subtitle: Row(children: [
                      Expanded(
                          child: StreamBuilder(
                              stream: firestore
                                  .collection('message')
                                  .doc(getChatroomId(chatroom.id))
                                  .collection('messages')
                                  .orderBy('time', descending: true)
                                  .limit(1)
                                  .snapshots(),
                              builder:
                                  (ctx2, AsyncSnapshot<QuerySnapshot> snap) {
                                if (snap.connectionState ==
                                    ConnectionState.waiting) {
                                  return Container();
                                }
                                final _chats = snap.data?.docs ?? [];
                                final chat =
                                    _chats.length > 0 ? _chats[0] : null;
                                var content = "";
                                if (chat != null && chat["type"] == "text")
                                  content = chat["text"];
                                else if (chat != null && chat["type"] == "file")
                                  content = 'File:${chat["file"]["name"]}';
                                else
                                  content = "";
                                return Text(content,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        .copyWith(fontWeight: FontWeight.w200));
                              })),
                      StreamBuilder(
                          stream: firestore
                              .collection('message')
                              .doc(getChatroomId(chatroom.id))
                              .collection('messages')
                              .where('senderId', isNotEqualTo: user.uid)
                              .where('seen', isEqualTo: false)
                              .snapshots(),
                          builder: (ctx2, AsyncSnapshot<QuerySnapshot> snap) {
                            if (snap.connectionState ==
                                ConnectionState.waiting) {
                              return Text("");
                            }
                            final _chats = snap.data?.docs ?? [];
                            final length = _chats.length ?? 0;
                            return length > 0
                                ? ConstrainedBox(
                                    constraints: BoxConstraints(minWidth: 20),
                                    child: Container(
                                        height: 20,
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 5),
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
  }
}
