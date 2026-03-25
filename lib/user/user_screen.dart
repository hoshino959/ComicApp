import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comic_app/api/api_service.dart';
import 'package:comic_app/models/chapter_model.dart';
import 'package:comic_app/screens/main_screen.dart';
import 'package:comic_app/theme/app_dark_colors.dart';
import 'package:comic_app/theme/app_light_colors.dart';
import 'package:comic_app/theme/theme_provider.dart';
import 'package:comic_app/user/library_screen.dart';
import 'package:comic_app/user/login_page.dart';
import 'package:comic_app/user/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:okcolor/models/oklab.dart';
import 'package:provider/provider.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return UserScreenState();
  }
}

class UserScreenState extends State<UserScreen> {
  bool isLoading = false;
  var user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    checkChapterNews();
  }

  Future<void> checkChapterNews() async {
    if (user == null) return;
    final snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .collection('Notification')
        .get();

    for (var doc in snapshot.docs) {
      final comicId = doc.id;
      final totalChaptersFS = doc['totalChapters'] ?? 0;

      final chapters = await ApiService.fetchAllComicChapters(comicId);
      final comicDetail = await ApiService.fetchComicDetail(comicId);

      if (chapters.isEmpty) continue;

      final totalChaptersAPI = chapters.length;

      if (totalChaptersFS < totalChaptersAPI) {
        final sortedChapters = List<ChapterModel>.from(chapters);
        sortedChapters.sort((a, b) => b.publishDate.compareTo(a.publishDate));
        final diff = (totalChaptersAPI - totalChaptersFS).toInt();
        final newChapters = sortedChapters.take(diff).toList();
        for (var chap in newChapters) {
          final docRef = FirebaseFirestore.instance
              .collection('Notification')
              .doc(user!.uid)
              .collection(comicId)
              .doc(chap.id);
          final exists = await docRef.get();
          if (exists.exists) continue;
          await docRef.set({
            'comicId': comicId,
            'comicTitle': comicDetail?.title,
            'coverUrl': comicDetail?.coverUrl,
            'chapter': chap.chapterTitle,
            'chapterId': chap.id,
            'publishDate': chap.publishDate,
            'updatedAt': FieldValue.serverTimestamp(),
            'status': false,
          });
        }
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user!.uid)
            .collection('Notification')
            .doc(comicId)
            .update({'totalChapters': chapters.length});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkMode =
        Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;
    final gradient = darkMode
        ? AppColorsDark.gradientBackground
        : AppColorsLight.gradientBackground;

    return Stack(
      children: [
        SafeArea(
          child: Container(
            decoration: BoxDecoration(gradient: gradient),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Column(
                  children: [
                    SizedBox(height: 60),
                    //logoApp
                    ClipOval(
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    ),

                    SizedBox(height: 50),
                    dashLine(),
                    SizedBox(height: 4),

                    //userInfo
                    InkWell(
                      onTap: () {
                        if (user != null)
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => ProfileScreen()),
                          );
                        if (user == null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => LoginPage()),
                          );
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.account_circle,
                              size: 40,
                              color: !darkMode
                                  ? OkLab(0.5, 0.14, -0.22).toColor()
                                  : OkLab(0.83, 0.07, -0.1).toColor(),
                            ),
                            SizedBox(width: 20),
                            if (user != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hồ sơ',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: !darkMode
                                          ? OkLab(0.5, 0.14, -0.22).toColor()
                                          : OkLab(0.83, 0.07, -0.1).toColor(),
                                    ),
                                  ),
                                  Text(
                                    'Chỉnh sửa hồ sơ của bạn',
                                    style: TextStyle(
                                      color: darkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            if (user == null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Đăng nhập',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: !darkMode
                                          ? OkLab(0.5, 0.14, -0.22).toColor()
                                          : OkLab(0.83, 0.07, -0.1).toColor(),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8),

                    //userLibrary
                    if (user != null)
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => LibraryScreen()),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.library_books,
                                size: 40,
                                color: !darkMode
                                    ? OkLab(0.5, 0.14, -0.22).toColor()
                                    : OkLab(0.83, 0.07, -0.1).toColor(),
                              ),
                              SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Thư viện',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: !darkMode
                                          ? OkLab(0.5, 0.14, -0.22).toColor()
                                          : OkLab(0.83, 0.07, -0.1).toColor(),
                                    ),
                                  ),
                                  Text(
                                    'Xem lại những bộ truyện của bạn',
                                    style: TextStyle(
                                      color: darkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (user != null) SizedBox(height: 8),

                    //userSetting
                    InkWell(
                      onTap: () async {
                        setState(() {
                          isLoading = true;
                        });

                        await Provider.of<ThemeProvider>(
                          context,
                          listen: false,
                        ).toggleTheme();

                        setState(() {
                          isLoading = false;
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.settings,
                              size: 40,
                              color: !darkMode
                                  ? OkLab(0.5, 0.14, -0.22).toColor()
                                  : OkLab(0.83, 0.07, -0.1).toColor(),
                            ),
                            SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cài đặt',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: !darkMode
                                        ? OkLab(0.5, 0.14, -0.22).toColor()
                                        : OkLab(0.83, 0.07, -0.1).toColor(),
                                  ),
                                ),
                                Text(
                                  'Chỉnh nền sáng tối tại đây',
                                  style: TextStyle(
                                    color: darkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 4),

                    dashLine(),
                    SizedBox(height: 4),

                    if (user != null)
                      InkWell(
                        onTap: () async {
                          setState(() {
                            isLoading = true;
                          });
                          await FirebaseAuth.instance.signOut();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => MainScreen()),
                          );
                          setState(() {
                            isLoading = false;
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.logout,
                                size: 40,
                                color: !darkMode
                                    ? OkLab(0.64, 0.21, 0.1).toColor()
                                    : OkLab(0.7, 0.18, 0.07).toColor(),
                              ),
                              SizedBox(width: 20),
                              Text(
                                'Đăng xuất',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: !darkMode
                                      ? OkLab(0.64, 0.21, 0.1).toColor()
                                      : OkLab(0.7, 0.18, 0.07).toColor(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}

class dashLine extends StatelessWidget {
  const dashLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      color: Colors.grey,
      margin: EdgeInsets.symmetric(horizontal: 30),
    );
  }
}
