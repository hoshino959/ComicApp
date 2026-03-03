import 'package:flutter/material.dart';

class AppColorsLight {
  static const background1 = Color(0xFFFDF4F8);
  static const background2 = Color(0xFFFBE7F1);
  static const background3 = Color(0xFFF6DCE9);

  static const LinearGradient gradientBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background1, background2, background3],
  );
}
