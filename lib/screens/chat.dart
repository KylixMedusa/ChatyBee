import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../provider/snackbarStore.dart';
import '../widgets/Snackbar.dart';
import '../widgets/swipeable.dart';

class Profile {
  final String name;
  final String avatar;
  final bool online;
  Profile({this.name, this.avatar, this.online});
}

class ChatPage extends StatefulWidget {
  final String recieverId;
  ChatPage({Key key, @required this.recieverId}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController _controller = new TextEditingController();

  QueryDocumentSnapshot reply;

  Widget _buildMessageComposer() {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey[300],
                        offset: Offset(0, 2),
                        blurRadius: 5)
                  ],
                  borderRadius: BorderRadius.circular(25)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (reply != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: Colors.grey[100].withAlpha(200),
                        ),
                        child: ListTile(
                          minVerticalPadding: 0,
                          dense: true,
                          visualDensity:
                              VisualDensity(horizontal: 0, vertical: 0),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                          horizontalTitleGap: 8,
                          title: Text(
                              reply["senderId"] == user.uid
                                  ? 'You'
                                  : recieverProfile.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  .copyWith(
                                      color: Theme.of(context).accentColor,
                                      fontWeight: FontWeight.w600)),
                          subtitle: Text(reply["text"],
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  .copyWith(fontWeight: FontWeight.w300)),
                          trailing: GestureDetector(
                              child: CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Colors.grey[300],
                                  child: Icon(
                                    Icons.close,
                                    size: 20,
                                    color: Colors.black,
                                  )),
                              onTap: () {
                                setState(() {
                                  reply = null;
                                });
                              }),
                        ),
                      ),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      uploading
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : IconButton(
                              tooltip: "Upload",
                              splashRadius: 24,
                              icon: Icon(Icons.attach_file,
                                  color: Theme.of(context).accentColor),
                              onPressed: () {
                                _pickFile();
                              },
                            ),
                      Expanded(
                        child: Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: TextField(
                              autocorrect: true,
                              controller: _controller,
                              maxLines: 4,
                              minLines: 1,
                              expands: false,
                              style: Theme.of(context).textTheme.headline5,
                              keyboardType: TextInputType.multiline,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                hintStyle: Theme.of(context)
                                    .textTheme
                                    .headline5
                                    .copyWith(color: Colors.grey[500]),
                                hintText: "Send a message ...",
                                border: InputBorder.none,
                              ),
                            )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(left: 10)),
          Material(
            child: Ink(
              decoration: ShapeDecoration(
                shape: CircleBorder(),
                color: Theme.of(context).accentColor,
              ),
              child: IconButton(
                tooltip: "Send",
                splashRadius: 24,
                icon: Icon(Icons.send, color: Colors.white),
                onPressed: () {
                  _send();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool uploading = false;

  Profile recieverProfile;

  Future<String> uploadFile(PlatformFile file) async {
    Reference firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('uploads/${file.name}.${file.extension}');
    try {
      await firebaseStorageRef.putFile(File(file.path));

      return await firebaseStorageRef.getDownloadURL();
    } on FirebaseException catch (_) {
      return null;
    }
  }

  _pickFile() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      allowCompression: true,
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      if (file.size < 10000) {
        var time = DateTime.now().toString();
        setState(() {
          uploading = true;
        });
        String url = await uploadFile(file);

        setState(() {
          uploading = false;
        });
        if (url != null) {
          firestore
              .collection('message')
              .doc(chatroomId)
              .collection('messages')
              .add({
            "type": "file",
            "file": {
              "name": file.name,
              "size": file.size,
              "extension": file.extension,
              "url": url
            },
            "time": time,
            "senderId": user.uid,
            "recieverId": widget.recieverId,
            "chatroomId": chatroomId,
            "seen": false
          });
          DocumentReference doc = firestore
              .collection('users')
              .doc(user.uid)
              .collection('connections')
              .doc(widget.recieverId);
          DocumentReference doc2 = firestore
              .collection('users')
              .doc(widget.recieverId)
              .collection('connections')
              .doc(user.uid);
          doc.set(
              <String, dynamic>{'updatedAt': time}, SetOptions(merge: true));
          doc2.set(
              <String, dynamic>{'updatedAt': time}, SetOptions(merge: true));
        } else {
          SnackbarStore snackbarStore =
              Provider.of<SnackbarStore>(context, listen: false);
          snackbarStore.add(SnackbarType(
            message: "Failed to upload file. Retry!!!",
            margin: EdgeInsets.all(10),
            borderRadius: 4,
            duration: Duration(seconds: 1),
            isDismissible: true,
          ));
        }
      } else {
        SnackbarStore snackbarStore =
            Provider.of<SnackbarStore>(context, listen: false);
        snackbarStore.add(SnackbarType(
          message: "File size should not be more than 10MB!!!",
          margin: EdgeInsets.all(10),
          borderRadius: 4,
          duration: Duration(seconds: 2),
          isDismissible: true,
        ));
      }
    } else {
      // User canceled the picker
    }
  }

  void _send() async {
    if (_controller.text != null && _controller.text.trim() != "") {
      var time = DateTime.now().toString();
      firestore
          .collection('message')
          .doc(chatroomId)
          .collection('messages')
          .add({
        "type": "text",
        "text": _controller.text.trim(),
        "time": time,
        "senderId": user.uid,
        "recieverId": widget.recieverId,
        "chatroomId": chatroomId,
        "reply": reply != null ? reply.id : null,
        "deleted_everyone": false,
        "seen": false,
        "deleted": []
      });
      DocumentReference doc = firestore
          .collection('users')
          .doc(user.uid)
          .collection('connections')
          .doc(widget.recieverId);
      DocumentReference doc2 = firestore
          .collection('users')
          .doc(widget.recieverId)
          .collection('connections')
          .doc(user.uid);
      doc.set(<String, dynamic>{'updatedAt': time}, SetOptions(merge: true));
      doc2.set(<String, dynamic>{'updatedAt': time}, SetOptions(merge: true));
      setState(() {
        _controller.text = "";
        reply = null;
      });
    }
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final User user = FirebaseAuth.instance.currentUser;

  bool isChatRoomLoaded = false;
  bool isProfileLoaded = false;

  get chatroomId {
    if (user.uid.compareTo(widget.recieverId) < 0) {
      return '${user.uid}_${widget.recieverId}';
    } else {
      return '${widget.recieverId}_${user.uid}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream:
            firestore.collection('users').doc(widget.recieverId).snapshots(),
        builder: (ctx,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          final String avatar =
              snapshot.data != null && snapshot.data["avatar"] != null
                  ? snapshot.data["avatar"]
                  : null;
          final Widget avatarWidget =
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
          recieverProfile =
              new Profile(name: name, avatar: avatar, online: online);
          return Scaffold(
            backgroundColor: Theme.of(context).hintColor,
            appBar: AppBar(
              elevation: 0.5,
              backgroundColor: Theme.of(context).hintColor,
              leading: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                child: InkWell(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Row(
                        children: [
                          Icon(Icons.arrow_back),
                          Padding(padding: EdgeInsets.only(left: 5)),
                          Flexible(
                            flex: 1,
                            child: CircleAvatar(
                                child: Stack(children: [
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(color: Colors.grey)),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: avatarWidget),
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
                          ),
                        ],
                      ),
                    )),
              ),
              leadingWidth: 84,
              titleSpacing: 0,
              title: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {},
                      child: SizedBox(
                        height: 56,
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            name,
                            style: Theme.of(context).textTheme.headline3,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              excludeHeaderSemantics: true,
            ),
            body: Snackbar(
              child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                            Theme.of(context).hintColor.withOpacity(0.05),
                            BlendMode.dstATop),
                        repeat: ImageRepeat.noRepeat,
                        image: AssetImage('assets/images/patternLight.png'))),
                child: Column(
                  children: [
                    Expanded(
                      child: Chat(
                        firestore: firestore,
                        recieverId: widget.recieverId,
                        setReply: (newReply) {
                          setState(() {
                            reply = newReply;
                          });
                        },
                        chatroomId: chatroomId,
                        recieverProfile:
                            Profile(avatar: avatar, name: name, online: online),
                      ),
                    ),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        child: _buildMessageComposer()),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

Widget emptyAppBar(color) {
  return PreferredSize(
      preferredSize: Size.fromHeight(0.0),
      child: AppBar(
        shadowColor: Colors.transparent,
        backgroundColor: color,
        brightness: Brightness.light,
      ));
}

class Chat extends StatefulWidget {
  final String chatroomId;
  final Profile recieverProfile;
  final String recieverId;
  final FirebaseFirestore firestore;
  final Function setReply;
  const Chat(
      {Key key,
      this.firestore,
      this.recieverId,
      this.chatroomId,
      this.setReply,
      this.recieverProfile})
      : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  @override
  void initState() {
    super.initState();
    FlutterDownloader.registerCallback(downloadCallback);
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    print(
        'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
  }

  Widget _buildMessage(message, bool isMe, BuildContext context) {
    if (isMe) {
      return Swipeable(
        onSwipeRight: () {
          widget.setReply(message);
        },
        background: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          color: Colors.transparent,
          child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.grey[400].withAlpha(100)),
              child: Icon(Icons.reply)),
          alignment: Alignment.centerLeft,
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Container(
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                !message['seen']
                    ? Icon(Icons.done, size: 16, color: Colors.grey[850])
                    : Icon(Icons.done_all,
                        size: 16, color: Theme.of(context).accentColor),
                SizedBox(width: 5),
                Text(
                  "${format(message['time'])}",
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                SizedBox(width: 15),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * .6),
                        padding:
                            message["reply"] != null && message["reply"] != ""
                                ? const EdgeInsets.fromLTRB(8, 8, 8, 15)
                                : const EdgeInsets.all(15.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).accentColor,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(25),
                            topLeft: Radius.circular(25),
                            bottomLeft: Radius.circular(25),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (message["reply"] != null &&
                                message["reply"] != "") ...[
                              FutureBuilder(
                                  future: widget.firestore
                                      .collection('message')
                                      .doc(widget.chatroomId)
                                      .collection('messages')
                                      .doc(message["reply"])
                                      .get(),
                                  builder: (ctx, snap) {
                                    final sender = snap.data != null &&
                                            snap.data["senderId"] != null
                                        ? snap.data["senderId"] == user.uid
                                            ? 'You'
                                            : widget.recieverProfile.name
                                        : '';
                                    final text = snap.data != null &&
                                            snap.data["text"] != null
                                        ? snap.data["text"]
                                        : '';
                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(18),
                                        color: Colors.black.withAlpha(30),
                                      ),
                                      child: ListTile(
                                        minVerticalPadding: 0,
                                        dense: true,
                                        visualDensity: VisualDensity(
                                            horizontal: 0, vertical: 0),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        horizontalTitleGap: 8,
                                        title: Text(sender,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                .copyWith(
                                                    color: Theme.of(context)
                                                        .focusColor,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                        subtitle: Text(text,
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.w300)),
                                      ),
                                    );
                                  }),
                              Padding(padding: EdgeInsets.only(top: 8))
                            ],
                            Text("${message['text']}",
                                softWrap: true,
                                textAlign: TextAlign.left,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5
                                    .copyWith(color: Colors.white)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Swipeable(
        onSwipeRight: () {
          widget.setReply(message);
        },
        background: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          color: Colors.transparent,
          child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.grey[400].withAlpha(100)),
              child: Icon(Icons.reply)),
          alignment: Alignment.centerLeft,
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Container(
            color: Colors.transparent,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(.3),
                              offset: Offset(0, 2),
                              blurRadius: 5)
                        ],
                      ),
                      child: CircleAvatar(
                        backgroundImage:
                            widget.recieverProfile.avatar != null &&
                                    widget.recieverProfile.avatar != ""
                                ? NetworkImage(widget.recieverProfile.avatar)
                                : AssetImage('assets/images/user.png'),
                      ),
                    ),
                    SizedBox(width: 5),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * .6),
                            padding: const EdgeInsets.all(15.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).focusColor,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(25),
                                bottomLeft: Radius.circular(25),
                                bottomRight: Radius.circular(25),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (message["reply"] != null &&
                                    message["reply"] != "") ...[
                                  FutureBuilder(
                                      future: widget.firestore
                                          .collection('message')
                                          .doc(widget.chatroomId)
                                          .collection('messages')
                                          .doc(message["reply"])
                                          .get(),
                                      builder: (ctx, snap) {
                                        final sender = snap.data != null &&
                                                snap.data["senderId"] != null
                                            ? snap.data["senderId"] == user.uid
                                                ? 'You'
                                                : widget.recieverProfile.name
                                            : '';
                                        final text = snap.data != null &&
                                                snap.data["text"] != null
                                            ? snap.data["text"]
                                            : '';
                                        return Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(18),
                                            color: Colors.black.withAlpha(30),
                                          ),
                                          child: ListTile(
                                            minVerticalPadding: 0,
                                            dense: true,
                                            visualDensity: VisualDensity(
                                                horizontal: 0, vertical: 0),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 8.0),
                                            horizontalTitleGap: 8,
                                            title: Text(sender,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2
                                                    .copyWith(
                                                        color: Theme.of(context)
                                                            .accentColor,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                            subtitle: Text(text,
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.w300)),
                                          ),
                                        );
                                      }),
                                  Padding(padding: EdgeInsets.only(top: 8))
                                ],
                                Text("${message['text']}",
                                    softWrap: true,
                                    style:
                                        Theme.of(context).textTheme.headline5),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 15),
                Text(
                  "${format(message['time'])}",
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildFile(message, bool isMe, BuildContext context) {
    if (isMe) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            !message['seen']
                ? Icon(Icons.done, size: 16, color: Colors.grey[850])
                : Icon(Icons.done_all,
                    size: 16, color: Theme.of(context).accentColor),
            SizedBox(width: 5),
            Text(
              "${format(message['time'])}",
              style: Theme.of(context).textTheme.bodyText2,
            ),
            SizedBox(width: 15),
            Flexible(
              child: Container(
                alignment: Alignment.centerRight,
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * .6),
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(25),
                    topLeft: Radius.circular(25),
                    bottomLeft: Radius.circular(25),
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(25),
                    topLeft: Radius.circular(25),
                    bottomLeft: Radius.circular(25),
                  ),
                  onTap: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${message['file']['name']}",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    .copyWith(color: Colors.white)),
                            Text(
                                "${(message['file']['extension']).toUpperCase()} - ${(message['file']['size'] / 1000).toStringAsFixed(2)}KB",
                                softWrap: true,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    .copyWith(color: Colors.white)),
                          ],
                        ),
                      ),
                      InkWell(
                          borderRadius: BorderRadius.circular(100),
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Theme.of(context).primaryColor),
                                borderRadius: BorderRadius.circular(100)),
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.file_download,
                                color: Theme.of(context).primaryColor),
                          ),
                          onTap: () async {
                            String dir = await _prepareSaveDir();
                            if (dir != null) {
                              FlutterDownloader.enqueue(
                                  url: message['file']['url'],
                                  savedDir: dir,
                                  fileName: message['file']['name'],
                                  showNotification: true,
                                  openFileFromNotification: true);
                            }
                          })
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(.3),
                          offset: Offset(0, 2),
                          blurRadius: 5)
                    ],
                  ),
                  child: CircleAvatar(
                    backgroundImage: widget.recieverProfile.avatar != null &&
                            widget.recieverProfile.avatar != ""
                        ? NetworkImage(widget.recieverProfile.avatar)
                        : AssetImage('assets/images/user.png'),
                  ),
                ),
                SizedBox(width: 5),
                Flexible(
                  child: Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * .6),
                    padding: const EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      color: Color(0xfff9f9f9),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(25),
                        bottomLeft: Radius.circular(25),
                        bottomRight: Radius.circular(25),
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(25),
                        topLeft: Radius.circular(25),
                        bottomLeft: Radius.circular(25),
                      ),
                      onTap: () {},
                      child: Row(
                        children: [
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${message['file']['name']}",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style:
                                        Theme.of(context).textTheme.bodyText2),
                                Text(
                                    "${(message['file']['extension']).toUpperCase()} - ${(message['file']['size'] / 1000).toStringAsFixed(2)}KB",
                                    softWrap: true,
                                    style:
                                        Theme.of(context).textTheme.bodyText2),
                              ],
                            ),
                          ),
                          InkWell(
                              borderRadius: BorderRadius.circular(100),
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Theme.of(context).accentColor),
                                    borderRadius: BorderRadius.circular(100)),
                                padding: EdgeInsets.all(4),
                                child: Icon(Icons.file_download,
                                    color: Theme.of(context).accentColor),
                              ),
                              onTap: () async {
                                String dir = await _prepareSaveDir();
                                if (dir != null) {
                                  FlutterDownloader.enqueue(
                                      url: message['file']['url'],
                                      savedDir: dir,
                                      fileName: message['file']['name'],
                                      showNotification: true,
                                      openFileFromNotification: true);
                                }
                              })
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 15),
            Text(
              "${format(message['time'])}",
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ],
        ),
      );
    }
  }

  String format(String date) {
    var dateTime = DateTime.parse(date);
    return DateFormat('HH:mm').format(dateTime);
  }

  String formatHeader(String date) {
    var dateTime = DateTime.parse(date);
    var differnce = dateTime.difference(DateTime.now()).inDays.abs();
    bool daySame = dateTime.day == DateTime.now().day;
    if (differnce == 0 && daySame) {
      return 'Today';
    } else if (differnce == 1 || (differnce == 0 && !daySame)) {
      return 'Yesterday';
    }
    return DateFormat('dd/MMM/yyyy').format(dateTime);
  }

  final User user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: widget.firestore
            .collection('message')
            .doc(widget.chatroomId)
            .collection('messages')
            .snapshots(),
        builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              snapshot.data?.docs == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final _chats = snapshot.data?.docs ?? [];
          return buildMessages(_chats);
        });
  }

  Widget buildMessages(List<QueryDocumentSnapshot> chats) {
    return StickyGroupedListView<dynamic, String>(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
      elements: chats ?? [],
      groupBy: (dynamic element) {
        DateTime datetime = DateTime.parse(element['time']);
        return DateTime(datetime.year, datetime.month, datetime.day).toString();
      },
      floatingHeader: true,
      groupSeparatorBuilder: (dynamic element) => Container(
        height: 50,
        child: Align(
          alignment: Alignment.center,
          child: Container(
            width: 150,
            decoration: BoxDecoration(
              color: Colors.grey[300].withAlpha(150),
              border: Border.all(
                color: Colors.grey[300].withAlpha(150),
              ),
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                formatHeader(element["time"]),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
      itemBuilder: (context, dynamic message) {
        final bool isMe = message["senderId"] == user.uid;
        final String type = message["type"];
        if (!isMe && !message["seen"]) {
          seenMessage(message.id);
        }
        return type == "text"
            ? _buildMessage(message, isMe, context)
            : _buildFile(message, isMe, context);
      },
      groupComparator: (element1, element2) =>
          DateTime.parse(element1).compareTo(DateTime.parse(element2)),
      itemComparator: (element1, element2) => DateTime.parse(element1['time'])
          .compareTo(DateTime.parse(element2['time'])), // optional
      itemScrollController: GroupedItemScrollController(), // optional
      order: StickyGroupedListOrder.DESC,
      scrollDirection: Axis.vertical,
      reverse: true,
    );
  }

  seenMessage(String docId) {
    final DocumentReference documentReference = widget.firestore
        .collection('message')
        .doc(widget.chatroomId)
        .collection('messages')
        .doc(docId);

    documentReference
        .set(<String, dynamic>{'seen': true}, SetOptions(merge: true));
  }

  Future<String> _prepareSaveDir() async {
    var _localPath = await _findLocalPath();
    return _localPath;
  }

  Future<String> _findLocalPath() async {
    if (Platform.isAndroid) {
      PermissionStatus status = await Permission.storage.request();
      if (status.isGranted || status.isLimited) {
        var directory = await getExternalStorageDirectory();
        String newPath = "";
        List<String> paths = directory.path.split("/");
        for (int x = 1; x < paths.length; x++) {
          String folder = paths[x];
          if (folder != "Android") {
            newPath += "/" + folder;
          } else {
            break;
          }
        }
        newPath = newPath + "/ChatyBee";
        directory = Directory(newPath);
        await directory.create(recursive: true);
        return directory.path;
      }
      return null;
    }
    // await Permission.getSinglePermissionStatus(PermissionName.Storage);
    // await Permission.requestSinglePermission(PermissionName.Storage);
    final directory = await getApplicationDocumentsDirectory();
    return directory?.path;
  }
}
