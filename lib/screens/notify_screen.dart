import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comic_app/api/api_service.dart';
import 'package:comic_app/screens/reading_screen.dart';
import 'package:comic_app/theme/app_dark_colors.dart';
import 'package:comic_app/theme/app_light_colors.dart';
import 'package:comic_app/theme/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:okcolor/models/oklab.dart';
import 'package:provider/provider.dart';

class NotifyScreen extends StatefulWidget {
  const NotifyScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _NotifyScreenState();
  }
}

class _NotifyScreenState extends State<NotifyScreen> {
  final user = FirebaseAuth.instance.currentUser;

  bool isLoading = true;
  bool isDisabled = true;
  bool showUnreadOnly = false;

  List<Map<String, dynamic>> allNotifications = [];

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    List<Map<String, dynamic>> tempList = [];

    final comicsSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .collection('Notification')
        .get();

    for (var comicDoc in comicsSnapshot.docs) {
      final comicId = comicDoc.id;

      final chaptersSnapshot = await FirebaseFirestore.instance
          .collection('Notification')
          .doc(user!.uid)
          .collection(comicId)
          .get();

      for (var chap in chaptersSnapshot.docs) {
        tempList.add(chap.data());
      }
    }
    tempList.sort((a, b) {
      final aTime = a['updatedAt'] as Timestamp?;
      final bTime = b['updatedAt'] as Timestamp?;
      return (bTime?.compareTo(aTime ?? Timestamp(0, 0))) ?? 0;
    });
    setState(() {
      allNotifications = tempList;
      isLoading = false;
      isDisabled = !allNotifications.any((e) => e['status'] == false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;
    final gradient = isDark ? AppColorsDark.gradientBackground : AppColorsLight.gradientBackground;
    final filtered = showUnreadOnly ? allNotifications.where((e) => e['status'] == false).toList() : allNotifications;
    return SafeArea(
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: gradient),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Thông báo',
                      style: TextStyle(
                        color: isDark ? OkLab(0.83, 0.07, -0.1).toColor() : OkLab(0.5, 0.14, -0.22).toColor(),
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Quản lý và xem lại tất cả các thông báo của bạn từ hệ thống.',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? OkLab(0.7, -0.01, -0.04).toColor() : OkLab(0.55, -0.01, -0.04).toColor(),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 20),
                    Material(
                      color: isDark
                          ? (!isDisabled
                                ? OkLab(0.63, 0.24, 0).toColor()
                                : OkLab(0.63, 0.24, 0).toColor().withValues(alpha: 0.5))
                          : (!isDisabled
                                ? OkLab(0.75, 0.17, -0.01).toColor()
                                : OkLab(0.75, 0.17, -0.01).toColor().withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        onTap: isDisabled
                            ? null
                            : () async {
                                setState(() {
                                  isLoading = true;
                                });
                                for (var item in allNotifications) {
                                  if (item['status'] == false) {
                                    await FirebaseFirestore.instance
                                        .collection('Notification')
                                        .doc(user!.uid)
                                        .collection(item['comicId'])
                                        .doc(item['chapterId'])
                                        .update({'status': true});
                                  }
                                }
                                await loadNotifications();
                                setState(() {
                                  isLoading = false;
                                });
                              },
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_outline, color: Colors.white),
                              SizedBox(width: 10),
                              Text('Đánh dấu tất cả là đã đọc', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              showUnreadOnly = false;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: isDark
                                  ? (!showUnreadOnly ? OkLab(0.63, 0.24, 0).toColor() : Colors.transparent)
                                  : (!showUnreadOnly ? OkLab(0.75, 0.17, -0.01).toColor() : Colors.white),
                              border: Border.all(
                                width: 1,
                                color: OkLab(0.75, 0.17, -0.01).toColor().withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              'Tất cả',
                              style: TextStyle(
                                color: isDark ? Colors.white : (!showUnreadOnly ? Colors.white : Colors.black),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              showUnreadOnly = true;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: isDark
                                  ? (showUnreadOnly ? OkLab(0.63, 0.24, 0).toColor() : Colors.transparent)
                                  : (showUnreadOnly ? OkLab(0.75, 0.17, -0.01).toColor() : Colors.white),
                              border: Border.all(
                                width: 1,
                                color: OkLab(0.75, 0.17, -0.01).toColor().withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              'Chưa đọc',
                              style: TextStyle(
                                color: isDark ? Colors.white : (showUnreadOnly ? Colors.white : Colors.black),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        final publishTime = DateFormat('dd/MM/yyyy').parse(item['publishDate']);
                        String timeAgo(DateTime dateTime) {
                          final diff = DateTime.now().difference(dateTime);

                          if (diff.inSeconds < 60) {
                            return '${diff.inSeconds} giây trước';
                          } else if (diff.inMinutes < 60) {
                            return '${diff.inMinutes} phút trước';
                          } else if (diff.inHours < 24) {
                            return '${diff.inHours} giờ trước';
                          } else if (diff.inDays < 7) {
                            return '${diff.inDays} ngày trước';
                          } else if (diff.inDays < 30) {
                            return '${(diff.inDays / 7).floor()} tuần trước';
                          } else if (diff.inDays < 365) {
                            return '${(diff.inDays / 30).floor()} tháng trước';
                          } else {
                            return '${(diff.inDays / 365).floor()} năm trước';
                          }
                        }

                        return GestureDetector(
                          onTap: () async {
                            setState(() {
                              isLoading = true;
                            });

                            await FirebaseFirestore.instance
                                .collection('Notification')
                                .doc(user!.uid)
                                .collection(item['comicId'])
                                .doc(item['chapterId'])
                                .update({'status': true});

                            await loadNotifications();

                            final chapters = await ApiService.fetchAllComicChapters(item['comicId']);

                            final index = chapters.indexWhere((c) => c.id == item['chapterId']);

                            final comicDetail = await ApiService.fetchComicDetail(item['comicId']);

                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ReadingScreen(
                                  chapterId: item['chapterId'],
                                  title: item['comicTitle'],
                                  chapterTitle: item['chapter'],
                                  uploaderName: chapters[index].uploaderName,
                                  chapters: chapters,
                                  index: index,
                                  comicId: item['comicId'],
                                  coverUrl: item['coverUrl'],
                                  status: comicDetail!.status,
                                ),
                              ),
                            );
                            setState(() {
                              isLoading = false;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: isDark ? OkLab(0.23, 0, -0.01).toColor() : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                width: 1,
                                color: isDark
                                    ? OkLab(0.97, 0, 0).toColor().withValues(alpha: 0.15)
                                    : OkLab(0.88, 0.04, 0).toColor(),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        item['coverUrl'] ?? '',
                                        width: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 50,
                                            color: Colors.grey[300],
                                            child: Icon(Icons.broken_image),
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 10),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['comicTitle'],
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: TextStyle(
                                              color: isDark ? Colors.white : OkLab(0.21, 0, -0.04).toColor(),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            'CHAPTER • ' + timeAgo(publishTime).toUpperCase(),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: TextStyle(
                                              color: isDark
                                                  ? OkLab(0.7, -0.01, -0.04).toColor()
                                                  : OkLab(0.55, -0.01, -0.04).toColor(),
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (item['status'] == false)
                                      Container(
                                        width: 10,
                                        height: 10,
                                        margin: EdgeInsets.only(right: 10),
                                        decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                      ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Đã thêm chapter: ' + item['chapter'],
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: isDark
                                        ? OkLab(0.87, -0.01, -0.02).toColor()
                                        : OkLab(0.45, -0.01, -0.04).toColor(),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isLoading)
            Container(
              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.1)),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
