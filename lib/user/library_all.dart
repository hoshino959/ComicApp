import 'package:comic_app/theme/app_dark_colors.dart';
import 'package:comic_app/theme/app_light_colors.dart';
import 'package:comic_app/theme/theme_provider.dart';
import 'package:comic_app/widgets/reading_list.dart';
import 'package:flutter/material.dart';
import 'package:okcolor/models/oklab.dart';
import 'package:provider/provider.dart';

class LibraryAll extends StatefulWidget {
  const LibraryAll({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LibraryAllState();
  }
}

class _LibraryAllState extends State<LibraryAll> {
  @override
  Widget build(BuildContext context) {
    final isDark =
        Provider.of<ThemeProvider>(context).themeMode ==
        ThemeMode.dark;
    final gradient = isDark
        ? AppColorsDark.gradientBackground
        : AppColorsLight.gradientBackground;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: isDark
              ? AppColorsDark.background1
              : AppColorsLight.background1,
          elevation: 0,
        ),
        body: SizedBox.expand(
          child: Container(
            decoration: BoxDecoration(gradient: gradient),
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lịch sử đọc',
                    style: TextStyle(
                      color: isDark
                          ? Colors.white
                          : Colors.black,
                      fontSize: 35,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Tất cả truyện bạn đã đọc',
                    style: TextStyle(
                      color: isDark
                          ? OkLab(0.71, 0, -0.02).toColor()
                          : OkLab(
                              0.55,
                              0.06,
                              -0.24,
                            ).toColor(),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 20),
                  //Vị trí gắn ReadingList
                  ReadingList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
