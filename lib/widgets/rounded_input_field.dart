import 'package:flutter/material.dart';

class TextFieldContainer extends StatelessWidget {
  final Widget child;
  const TextFieldContainer({
    Key key,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      width: size.width * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).focusColor,
        borderRadius: BorderRadius.circular(29),
      ),
      child: child,
    );
  }
}

class RoundedEmailField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final ValueChanged<String> onChanged;
  const RoundedEmailField({
    Key key,
    this.hintText,
    this.icon = Icons.person,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextFormField(
        onChanged: onChanged,
        cursorColor: Theme.of(context).accentColor,
        enableSuggestions: true,
        style: Theme.of(context).textTheme.headline5,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (String val) =>
            RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch(val)
                ? null
                : "Invalid Email Address",
        decoration: InputDecoration(
          errorStyle:
              Theme.of(context).textTheme.bodyText2.copyWith(color: Colors.red),
          icon: Icon(
            icon,
            color: Theme.of(context).accentColor,
          ),
          hintText: hintText,
          hintStyle: Theme.of(context).textTheme.bodyText2,
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class RoundedPasswordField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const RoundedPasswordField({
    Key key,
    this.onChanged,
  }) : super(key: key);

  @override
  _RoundedPasswordFieldState createState() => _RoundedPasswordFieldState();
}

class _RoundedPasswordFieldState extends State<RoundedPasswordField> {
  bool _obscureText = true;
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextFormField(
        obscureText: _obscureText,
        onChanged: widget.onChanged,
        style: Theme.of(context).textTheme.headline5,
        enableSuggestions: true,
        cursorColor: Theme.of(context).accentColor,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        keyboardType: TextInputType.visiblePassword,
        validator: (String val) => val == "" || val == null
            ? "Field can't be empty"
            : val.length < 8
                ? "Too Small Password"
                : null,
        decoration: InputDecoration(
          errorStyle:
              Theme.of(context).textTheme.bodyText2.copyWith(color: Colors.red),
          hintText: "Password*",
          icon: Icon(
            Icons.lock,
            color: Theme.of(context).accentColor,
          ),
          suffixIcon: GestureDetector(
            onTap: () {
              this._toggle();
            },
            child: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: Theme.of(context).accentColor,
            ),
          ),
          hintStyle: Theme.of(context).textTheme.bodyText2,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
