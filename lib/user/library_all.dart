import 'package:comic_app/theme/app_dark_colors.dart';
import 'package:comic_app/theme/app_light_colors.dart';
import 'package:comic_app/theme/theme_provider.dart';
import 'package:comic_app/user/library_screen.dart';
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
        Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;
    final gradient = isDark
        ? AppColorsDark.gradientBackground
        : AppColorsLight.gradientBackground;
    return SafeArea(
      child: Scaffold(
        body: SizedBox.expand(
          child: Container(
            decoration: BoxDecoration(gradient: gradient),
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => LibraryScreen()),
                          );
                        },
                        child: Text(
                          'Thư viện',
                          style: TextStyle(
                            color: isDark
                                ? OkLab(0.63, 0.24, 0).toColor()
                                : OkLab(0.75, 0.17, -0.01).toColor(),
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward_ios, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Lịch sử đọc',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Lịch sử đọc',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
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
                          : OkLab(0.55, 0.06, -0.24).toColor(),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDark
                              ? Colors.grey
                              : OkLab(0.88, 0.04, 0).toColor(),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(20),
                        color: isDark
                            ? Colors.grey.withOpacity(0.1)
                            : AppColorsLight.background1,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.refresh,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Tải lại',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
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
