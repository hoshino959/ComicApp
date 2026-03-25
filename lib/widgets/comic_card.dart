import 'package:cached_network_image/cached_network_image.dart';
import 'package:comic_app/theme/app_colors.dart';
import 'package:comic_app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:okcolor/models/oklab.dart';
import 'package:provider/provider.dart';

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
    final darkMode =
        Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: darkMode ? OkLab(0.28, -0.01, -0.03).toColor() : Colors.white,
        border: Border.all(color: AppColors.secondaryPink, width: 3),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(9),
              topRight: Radius.circular(9),
            ),
            child: CachedNetworkImage(
              imageUrl: thumbnailUrl,
              width: double.infinity,
              height: 219,
              fit: BoxFit.cover,
              memCacheHeight: 300,
              placeholder: (context, url) => Container(
                height: 219,
                color: Colors.grey.withValues(alpha: 0.1),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.secondaryPink,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 219,
                color: Colors.grey.withValues(alpha: 0.1),
                child: const Icon(
                  Icons.broken_image,
                  color: Colors.grey,
                  size: 40,
                ),
              ),
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
                      color: !darkMode ? Colors.black : Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        color: !darkMode ? Colors.black : Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: darkMode
                        ? OkLab(0.83, 0.07, -0.1).toColor()
                        : OkLab(0.5, 0.14, -0.22).toColor(),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.book,
                      color: Colors.orangeAccent,
                      size: 16,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        newestChapter,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          color: !darkMode ? Colors.black : Colors.white,
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
