import 'package:comic_app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:okcolor/models/oklab.dart';
import 'package:provider/provider.dart';

class ChapterItem extends StatelessWidget {
  final String chapterTitle;
  final String uploaderName;
  final String publishDate;
  final bool isNewest;

  const ChapterItem({
    super.key,
    required this.chapterTitle,
    required this.uploaderName,
    required this.publishDate,
    required this.isNewest,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? OkLab(0.92, 0, 0).toColor() : Colors.black.withValues(alpha: 0.2), width: 1),
      ),
      padding: EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chapterTitle,
                  style: TextStyle(
                    color: isDark ? Color(0xFFA855F7) : OkLab(0.63, 0.15, -0.22).toColor(),
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: OkLab(0.55, 0, -0.02).toColor(),
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        uploaderName,
                        style: TextStyle(color: OkLab(0.55, 0, -0.02).toColor(), fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(publishDate, style: TextStyle(color: OkLab(0.55, 0, -0.02).toColor(), fontSize: 12)),
              const SizedBox(height: 5),
              isNewest
                  ? Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Color(0xFFFF2E7E)),
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Text('Mới nhất', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ],
      ),
    );
  }
}
