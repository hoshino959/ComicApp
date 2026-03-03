import 'package:comic_app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ComicCard extends StatelessWidget {
  final String title;
  final String thumbnailUrl;
  final String timeAgo;
  final String newestChapter;

  const ComicCard({
    super.key,
    required this.title,
    required this.thumbnailUrl,
    required this.timeAgo,
    required this.newestChapter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.secondaryPink,
          width: 3,
        ),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(9),
              topRight: Radius.circular(9),
            ),
            child: Image.network(
              thumbnailUrl,
              width: 180,
              height: 210,
              fit: BoxFit.cover,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.history,
                      color: AppColors.textColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        color: AppColors.textColor,
                      ),
                    ),
                  ],
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.book,
                      color: Colors.orangeAccent,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        newestChapter,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          color: AppColors.textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
