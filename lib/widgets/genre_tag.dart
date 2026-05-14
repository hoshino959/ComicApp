import 'package:flutter/material.dart';
import 'package:okcolor/models/oklab.dart';

class GenreTag extends StatelessWidget {
  final String title;

  const GenreTag({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Color(0xffF48FB1) : OkLab(0.75, 0.17, -0.01).toColor(),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: !isDark ? Colors.white : OkLab(0.53, 0.22, 0.02).toColor(),
        ),
      ),
    );
  }
}
