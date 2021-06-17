import 'package:chatybee/provider/snackbarStore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../widgets/Snackbar.dart';
import '../widgets/chatrooms_search.dart';
import '../widgets/profile_pic_view.dart';

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final User user = FirebaseAuth.instance.currentUser;
  ScrollController _scrollController;
  double _elevation = 0;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        setOnlineStatus(true);
        break;
      case AppLifecycleState.inactive:
        setOnlineStatus(false);
        break;
      case AppLifecycleState.paused:
        setOnlineStatus(false);
        break;
      case AppLifecycleState.detached:
        setOnlineStatus(false);
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    setOnlineStatus(true);
    WidgetsBinding.instance.addObserver(this);
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
  void dispose() {
    setOnlineStatus(false);
    WidgetsBinding.instance.removeObserver(this);
    _scrollController?.removeListener(_scrollListener);
    _scrollController?.dispose();
    super.dispose();
  }

  setOnlineStatus(bool val) {
    DocumentReference doc = firestore.collection('users').doc(user.uid);
    doc.set(<String, dynamic>{'online': val}, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        if (_selected.length > 0) {
          setState(() {
            _selected = [];
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).hintColor,
        appBar: _selected.length > 0
            ? generateAppBar()
            : AppBar(
                elevation: _elevation,
                backgroundColor: Theme.of(context).hintColor,
                leading: StreamBuilder(
                    stream:
                        firestore.collection('users').doc(user.uid).snapshots(),
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
                    child: Text('Messages',
                        style: Theme.of(context).textTheme.headline3)),
              ),
        body: Snackbar(
          child: Container(
            width: size.width,
            height: double.infinity,
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              controller: _scrollController,
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
                          padding: EdgeInsets.symmetric(
                              vertical: 16, horizontal: 20),
                          backgroundColor: Theme.of(context).focusColor,
                        ),
                        onPressed: () {
                          showSearch(
                              context: context, delegate: ChatroomsSearch());
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
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
          tooltip: 'Contacts',
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
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final _chatrooms = snapshot.data?.docs ?? [];
          final ids = _chatrooms.map((e) => e.id).toSet();
          _chatrooms.retainWhere((x) => ids.remove(x.id));
          final _updatedChatrooms = filter(_chatrooms);
          return _updatedChatrooms.length > 0
              ? ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                  itemCount: _updatedChatrooms.length,
                  itemBuilder: (ctx, index) {
                    final chatroom = _updatedChatrooms[index];
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

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _selected = [];

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
                  var newSelected = [..._selected];
                  var ids = newSelected.map((e) => e.id).toList();
                  if (_selected.length > 0) {
                    if (!ids.contains(chatroom.id))
                      setState(() {
                        _selected.add(chatroom);
                      });
                    else
                      setState(() {
                        _selected.removeWhere(
                            (element) => element.id == chatroom.id);
                      });
                  } else
                    Navigator.of(context)
                        .pushNamed('/chat', arguments: chatroom.id);
                },
                onLongPress: () {
                  var newSelected = [..._selected];
                  var ids = newSelected.map((e) => e.id).toList();
                  if (!ids.contains(chatroom.id))
                    setState(() {
                      _selected.add(chatroom);
                    });
                },
                child: Container(
                  color:
                      !_selected.map((e) => e.id).toList().contains(chatroom.id)
                          ? Colors.transparent
                          : Colors.black.withAlpha(10),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                    decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[900]
                                  : Colors.grey[300])),
                    ),
                    child: ListTile(
                      enabled: true,
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
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        color: Colors.green,
                                        border: Border.all(
                                            color:
                                                Theme.of(context).hintColor)),
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
                        if (chatroom.data().containsKey('pinned') &&
                            chatroom.data()["pinned"] != null)
                          ConstrainedBox(
                            constraints: BoxConstraints(minWidth: 20),
                            child: Container(
                              height: 20,
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(100)),
                              child: Icon(Icons.lock_outlined,
                                  size: 12, color: Colors.grey[800]),
                            ),
                          ),
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
                    ),
                  ),
                )),
          );
        });
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> filter(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> chatrooms) {
    List<QueryDocumentSnapshot<Map<String, dynamic>>> pinned = [];
    List<QueryDocumentSnapshot<Map<String, dynamic>>> result = [];
    for (var chatroom in chatrooms) {
      var data = chatroom.data();
      if (data.containsKey('pinned') && data["pinned"] != null)
        pinned.add(chatroom);
      else
        result.add(chatroom);
    }
    pinned.sort((i, j) {
      return DateTime.parse(j["pinned"].toString())
          .difference(DateTime.parse(i["pinned"].toString()))
          .inMilliseconds;
    });
    result.sort((i, j) {
      return DateTime.parse(j["updatedAt"].toString())
          .difference(DateTime.parse(i["updatedAt"].toString()))
          .inMilliseconds;
    });
    return [...pinned, ...result];
  }

  AppBar generateAppBar() {
    int pinned = 0;
    for (var chatroom in _selected) {
      var data = chatroom.data();
      if (data.containsKey('pinned') && data["pinned"] != null) pinned++;
    }
    return AppBar(
      elevation: 1,
      backgroundColor: Theme.of(context).hintColor,
      leading: IconButton(
          splashRadius: 24,
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _selected = [];
            });
          }),
      titleSpacing: 5,
      title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(_selected.length.toString(),
              style: Theme.of(context).textTheme.headline3)),
      actions: <Widget>[
        if (pinned == 0)
          IconButton(
            splashRadius: 24,
            icon: Icon(Icons.lock_outlined),
            tooltip: 'Pin',
            onPressed: () {
              handlePin(_selected.map((e) => e.id).toList(), true);
              setState(() {
                _selected = [];
              });
            },
          ),
        if (pinned == _selected.length)
          IconButton(
            splashRadius: 24,
            icon: Icon(Icons.lock_open_outlined),
            tooltip: 'UnPin',
            onPressed: () {
              handlePin(_selected.map((e) => e.id).toList(), false);
              setState(() {
                _selected = [];
              });
            },
          ),
        IconButton(
          splashRadius: 24,
          icon: Icon(Icons.delete_outline_rounded),
          tooltip: 'Delete',
          onPressed: () {
            handleDelete(_selected.map((e) => e.id).toList());
            setState(() {
              _selected = [];
            });
          },
        ),
      ],
    );
  }

  void handlePin(List<String> ids, bool val) {
    var time = DateTime.now().toString();
    for (var id in ids) {
      var doc = firestore
          .collection('users')
          .doc(user.uid)
          .collection('connections')
          .doc(id);
      doc.set({'pinned': val ? time : null}, SetOptions(merge: true));
    }
  }

  void handleDelete(List<String> ids) async {
    SnackbarStore snackbarStore =
        Provider.of<SnackbarStore>(context, listen: false);
    bool result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmation',
              style: Theme.of(context).textTheme.headline4),
          content: Text('Are you sure you want to close the job?',
              style: Theme.of(context).textTheme.headline5),
          actions: <Widget>[
            new TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true)
                    .pop(false); // dismisses only the dialog and returns false
              },
              child: Text(
                'No',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true)
                    .pop(true); // dismisses only the dialog and returns true
              },
              child: Text('Yes',
                  style: TextStyle(color: Theme.of(context).accentColor)),
            ),
          ],
        );
      },
    );
    if (result) {
      snackbarStore.add(SnackbarType(
        message: "Deleted!!!",
        showProgressIndicator: true,
        margin: EdgeInsets.all(10),
        borderRadius: 4,
        duration: null,
        isDismissible: false,
      ));
      try {
        for (var id in ids) {
          var doc = firestore
              .collection('users')
              .doc(user.uid)
              .collection('connections')
              .doc(id);
          doc.delete();
          snackbarStore.add(SnackbarType(
            message: "Deleted successfully!!!",
            margin: EdgeInsets.all(10),
            borderRadius: 4,
            duration: Duration(seconds: 1),
            isDismissible: true,
          ));
        }
      } catch (e) {
        snackbarStore.add(SnackbarType(
          message: "Internal error..Retry!!!",
          margin: EdgeInsets.all(10),
          borderRadius: 4,
          duration: Duration(seconds: 1),
          isDismissible: true,
        ));
      }
    }
  }
}
