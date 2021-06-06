import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ContactsSearch extends SearchDelegate<dynamic> {
  ContactsSearch(this.contacts);

  final List<QueryDocumentSnapshot<Map<String, dynamic>>> contacts;

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

  Widget buildList(BuildContext context) {
    List<QueryDocumentSnapshot<Map<String, dynamic>>> result = queryFilter();
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
              Navigator.of(context).pushNamed('/chat', arguments: contact.id);
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
                                    borderRadius: BorderRadius.circular(100),
                                    color: Colors.green,
                                    border: Border.all(
                                        color: Theme.of(context).hintColor)),
                              ))
                      ])),
                  title: Text(contact["name"] ?? "",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.headline5.copyWith(
                          fontSize: 18.0, fontWeight: FontWeight.w600)),
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
    );
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> queryFilter() {
    if (query == null || query == "") {
      return this.contacts;
    }
    var newContacts = [...this.contacts];
    newContacts.retainWhere((element) =>
        element["name"].toLowerCase().contains(query.toLowerCase()));
    return newContacts;
  }
}
