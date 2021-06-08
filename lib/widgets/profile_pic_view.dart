import 'package:flutter/material.dart';

import '../animations/PhotoHero.dart';

class ProfilePicView extends StatelessWidget {
  final Widget picture;
  const ProfilePicView({Key key, this.picture}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PhotoHero(
      page: 'home',
      onTap: () {
        Navigator.pushNamed(context, '/settings');
      },
      child: Container(
        padding: EdgeInsets.all(6.0),
        child: Stack(
          children: [
            Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).accentColor),
                    borderRadius: BorderRadius.circular(100)),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(100), child: picture)),
            Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 15,
                  height: 15,
                  padding: EdgeInsets.all(2),
                  child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Icon(Icons.menu, color: Colors.black)),
                  decoration: BoxDecoration(
                      border: Border.all(),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100)),
                ))
          ],
        ),
      ),
    );
  }
}
