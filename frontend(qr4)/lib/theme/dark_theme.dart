import 'package:flutter/material.dart';

ThemeData darkTheme =ThemeData(
  colorScheme: ColorScheme.dark(
    background: Colors.black,
    primary: Colors.grey[900]!,
    secondary: Colors.grey[300]!,
  ).copyWith(brightness: Brightness.dark),
);