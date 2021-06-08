import 'package:flutter/material.dart';
import './config.dart';

var kLightTheme = ThemeData(
  canvasColor: Colors.transparent,
  primaryColor: Colors.white,
  brightness: Brightness.light,
  accentColor: CustomColors().accentColor(1),
  focusColor: CustomColors().mainColor(1),
  hintColor: CustomColors().secondColor(1),
  accentTextTheme:
      TextTheme(headline6: TextStyle(fontFamily: "Red Hat Display")),
  textTheme: TextTheme(
    button: TextStyle(
      fontFamily: 'Red Hat Display',
      fontSize: 16,
      fontWeight: FontWeight.w800,
      color: Color(0xFFFFFFFF),
    ),
    headline5: TextStyle(
      fontSize: 16.0,
      color: Colors.black,
      fontFamily: "Red Hat Display",
    ),
    headline4: TextStyle(
        fontSize: 16,
        fontFamily: "Red Hat Display",
        fontWeight: FontWeight.w500,
        color: CustomColors().accentColor(1)),
    headline3: TextStyle(
        fontSize: 20,
        fontFamily: "Red Hat Display",
        fontWeight: FontWeight.w500,
        color: Colors.black),
    headline2: TextStyle(
        fontSize: 24,
        fontFamily: "Red Hat Display",
        fontWeight: FontWeight.w500,
        color: Colors.black),
    headline1: TextStyle(
      fontFamily: 'Red Hat Display',
      color: CustomColors().accentColor(1),
      fontSize: 50,
      fontWeight: FontWeight.w600,
    ),
    subtitle1: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w900,
      color: CustomColors().secondColor(1),
      fontFamily: "Roboto",
    ),
    headline6: TextStyle(
      fontSize: 13.0,
      color: Colors.black.withOpacity(.85),
      fontFamily: "Red Hat Display",
    ),
    bodyText2: TextStyle(
      fontFamily: 'Red Hat Display',
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.black.withOpacity(.75),
    ),
    bodyText1: TextStyle(
      fontFamily: 'Red Hat Display',
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: Colors.black.withOpacity(1),
    ),
    caption: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: CustomColors().accentColor(1),
    ),
  ),
);

var kDarkTheme = ThemeData(
  canvasColor: Colors.transparent,
  primaryColor: Colors.black45,
  brightness: Brightness.dark,
  accentColor: CustomColors().accentDarkColor(1),
  focusColor: CustomColors().mainDarkColor(1),
  hintColor: CustomColors().secondDarkColor(1),
  accentTextTheme:
      TextTheme(headline6: TextStyle(fontFamily: "Red Hat Display")),
  textTheme: TextTheme(
    button: TextStyle(
      fontFamily: 'Red Hat Display',
      fontSize: 16,
      fontWeight: FontWeight.w800,
      color: Color(0xFF181818),
    ),
    headline5: TextStyle(
      fontSize: 16.0,
      color: Colors.grey[200],
      fontFamily: "Red Hat Display",
    ),
    headline4: TextStyle(
        fontSize: 16,
        fontFamily: "Red Hat Display",
        fontWeight: FontWeight.w500,
        color: CustomColors().accentDarkColor(1)),
    headline3: TextStyle(
        fontSize: 20,
        fontFamily: "Red Hat Display",
        fontWeight: FontWeight.w500,
        color: Colors.white),
    headline2: TextStyle(
        fontSize: 24,
        fontFamily: "Red Hat Display",
        fontWeight: FontWeight.w500,
        color: Colors.white),
    headline1: TextStyle(
      fontFamily: 'Red Hat Display',
      color: CustomColors().accentDarkColor(1),
      fontSize: 50,
      fontWeight: FontWeight.w600,
    ),
    subtitle1: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w900,
      color: CustomColors().secondDarkColor(1),
      fontFamily: "Roboto",
    ),
    headline6: TextStyle(
      fontSize: 14.0,
      color: CustomColors().accentDarkColor(.85),
      fontFamily: "Red Hat Display",
    ),
    bodyText2: TextStyle(
      fontFamily: 'Red Hat Display',
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.grey[350],
    ),
    bodyText1: TextStyle(
      fontFamily: 'Red Hat Display',
      fontSize: 22,
      fontWeight: FontWeight.w500,
      color: CustomColors().accentDarkColor(1),
    ),
    caption: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: CustomColors().accentDarkColor(1),
    ),
  ),
);
