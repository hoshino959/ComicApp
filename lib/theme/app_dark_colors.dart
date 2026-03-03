import 'package:flutter/material.dart';

class AppColorsDark {
  static const background1 = Color(0xFF1B1420);
  static const background2 = Color(0xFF241A2B);
  static const background3 = Color(0xFF2E2236);

  static const LinearGradient gradientBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background1, background2, background3],
  );
}
