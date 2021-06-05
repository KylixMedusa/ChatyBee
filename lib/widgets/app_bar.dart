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
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => onBackPressed ?? Navigator.pop(context)),
      centerTitle: true,
      title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(title.toUpperCase(),
              style: Theme.of(context).textTheme.headline3)),
    );
  }
}
