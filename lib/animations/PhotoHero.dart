import 'package:flutter/material.dart';

class PhotoHero extends StatelessWidget {
  const PhotoHero(
      {Key key,
      @required this.child,
      @required this.onTap,
      @required this.page})
      : super(key: key);

  final VoidCallback onTap;
  final Widget child;
  final String page;

  Widget build(BuildContext context) {
    return Hero(
      tag: this.page,
      child: GestureDetector(onTap: this.onTap, child: this.child),
    );
  }
}
