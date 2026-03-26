import 'package:flutter/material.dart';

class StatItem extends StatelessWidget {
  final Icon icon;
  final String title;

  const StatItem({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 4),
        Text(title, style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
      ],
    );
  }
}
