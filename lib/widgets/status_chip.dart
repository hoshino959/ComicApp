import 'package:flutter/material.dart';
import 'package:okcolor/models/oklab.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color baseColor;
    IconData icon;
    String label;
    Color backgroundColor;

    switch (status.toLowerCase()) {
      case 'completed':
        baseColor = const Color(0xFF224338);
        icon = Icons.check_circle_outline;
        label = 'Đã hoàn thành';
        backgroundColor = const Color.fromARGB(255, 162, 245, 213);
        break;
      case 'ongoing':
        baseColor = const Color(0xFFFFF997);
        icon = Icons.timer;
        label = 'Đang tiến hành';
        backgroundColor = baseColor.withValues(alpha: 0.8);
        break;
      case 'hiatus':
        baseColor = const Color(0xFFE65100);
        icon = Icons.pause_circle_outline;
        label = 'Tạm ngưng';
        backgroundColor = baseColor.withValues(alpha: 0.2);
        break;
      case 'cancelled':
        baseColor = const Color(0xFFC62828);
        icon = Icons.cancel_outlined;
        label = 'Đã hủy';
        backgroundColor = baseColor.withValues(alpha: 0.2);
        break;
      default:
        baseColor = Colors.grey;
        icon = Icons.help_outline;
        label = 'Không rõ';
        backgroundColor = baseColor.withValues(alpha: 0.2);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: OkLab(0.55, 0.05, 0.12).toColor()),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: OkLab(0.55, 0.05, 0.12).toColor(),
              fontWeight: FontWeight
                  .w500, // Thêm chút đậm cho chữ dễ đọc hơn trên nền màu
            ),
          ),
        ],
      ),
    );
  }
}
