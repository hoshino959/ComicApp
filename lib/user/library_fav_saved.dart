import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comic_app/theme/app_dark_colors.dart';
import 'package:comic_app/theme/app_light_colors.dart';
import 'package:comic_app/theme/theme_provider.dart';
import 'package:comic_app/widgets/reading_grid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:okcolor/models/oklab.dart';
import 'package:provider/provider.dart';

class LibraryFavSaved extends StatelessWidget {
  final String status;

  const LibraryFavSaved({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;
    final gradient = isDark ? AppColorsDark.gradientBackground : AppColorsLight.gradientBackground;
    final isFav = status == "Favorite";

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: isDark ? AppColorsDark.background1 : AppColorsLight.background1,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          ),
        ),
        body: SizedBox.expand(
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(gradient: gradient),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: isDark
                                ? OkLab(0.63, 0.24, 0).toColor().withValues(alpha: 0.3)
                                : OkLab(0.75, 0.17, -0.01).toColor().withValues(alpha: 0.2),
                          ),
                          child: Icon(
                            isFav ? Icons.favorite_border : Icons.bookmark_border_outlined,
                            size: 40,
                            color: OkLab(0.63, 0.24, 0).toColor(),
                          ),
                        ),
                        SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isFav ? 'Yêu thích' : 'Đã lưu',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .collection(status)
                                  .snapshots(),
                              builder: (_, snapshot) {
                                return Text(
                                  '${snapshot.data?.docs.length ?? 0} truyện',
                                  style: TextStyle(
                                    color: isDark
                                        ? OkLab(0.71, 0, -0.02).toColor()
                                        : OkLab(0.55, 0.06, -0.24).toColor(),
                                    fontSize: 16,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    ReadingGrid(status: status),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
