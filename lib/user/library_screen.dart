import 'package:comic_app/theme/app_dark_colors.dart';
import 'package:comic_app/theme/app_light_colors.dart';
import 'package:comic_app/theme/theme_provider.dart';
import 'package:comic_app/user/library_all.dart';
import 'package:comic_app/widgets/reading_carousel.dart';
import 'package:flutter/material.dart';
import 'package:okcolor/models/oklab.dart';
import 'package:provider/provider.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LibraryScreenState();
  }
}

class _LibraryScreenState extends State<LibraryScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark =
        Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;
    final gradient = !isDark
        ? AppColorsLight.gradientBackground
        : AppColorsDark.gradientBackground;

    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
        body: SizedBox.expand(
          child: Container(
            decoration: BoxDecoration(gradient: gradient),
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 60),
                Text(
                  'Thư viện của tôi',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 30,
                    fontFamily: 'Merienda-ExtraBold',
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Chào mừng trở lại! Đã đến lúc quay lại với những câu chuyện của bạn.',
                  style: TextStyle(
                    color: isDark
                        ? OkLab(0.71, 0, -0.02).toColor()
                        : OkLab(0.55, 0.06, -0.24).toColor(),
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Icon(
                      Icons.play_circle_outline,
                      color: OkLab(0.75, 0.17, -0.01).toColor(),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Tiếp tục đọc',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(
                          context,
                        ).push(MaterialPageRoute(builder: (_) => LibraryAll()));
                      },
                      child: Text(
                        'Xem tất cả',
                        style: TextStyle(
                          fontSize: 14,
                          color: OkLab(0.75, 0.17, -0.01).toColor(),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                //SizedBox thay thế = Carousel truyện đã đọc
                SizedBox(height: 230, child: ReadingCarousel()),
                Row(
                  children: [
                    Icon(
                      Icons.folder_open,
                      color: OkLab(0.75, 0.17, -0.01).toColor(),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Bộ sưu tập của tôi',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                //Đã lưu
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: OkLab(
                        0.71,
                        -0.04,
                        -0.16,
                      ).toColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        width: 1,
                        color: OkLab(
                          0.81,
                          -0.03,
                          -0.1,
                        ).toColor().withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: OkLab(0.62, -0.04, -0.21).toColor(),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            Icons.bookmark_border_outlined,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Đã lưu',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ),
                ),
                //Yêu thích
                SizedBox(height: 15),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: OkLab(
                        0.71,
                        0.19,
                        0.05,
                      ).toColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        width: 1,
                        color: OkLab(
                          0.81,
                          0.11,
                          0.02,
                        ).toColor().withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: OkLab(0.65, 0.24, 0.07).toColor(),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            Icons.favorite_border,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Yêu thích',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ),
                ),
                //Folder Name
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
