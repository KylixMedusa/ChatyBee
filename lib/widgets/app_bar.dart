import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  final String title;
  final double height;
  final Function onBackPressed;
  const CustomAppBar(
      {Key key,
      @required this.title,
      this.onBackPressed,
      this.height = kToolbarHeight})
      : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
          splashRadius: 24,
          icon: Icon(Icons.arrow_back),
          onPressed: () => onBackPressed ?? Navigator.pop(context)),
      title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(title.toUpperCase(),
              style: Theme.of(context).textTheme.headline3)),
    );
  }
}
