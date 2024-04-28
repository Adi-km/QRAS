import 'package:flutter/material.dart';

ThemeData lightTheme =ThemeData(

  colorScheme: ColorScheme.dark(
    background: Colors.grey[200]!,
    // color1: Colors.deepPurpleAccent,
    // color2: Colors.deepPurple,
    primary: Colors.grey[500]!,
    // scaffoldBackgorunndColor: Colors.white,
    secondary: Colors.grey[900]!,
  ).copyWith(brightness: Brightness.light),
);
