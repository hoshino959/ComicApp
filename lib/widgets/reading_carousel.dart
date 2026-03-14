import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comic_app/theme/theme_provider.dart';
import 'package:comic_app/widgets/status_chip.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:okcolor/models/oklab.dart';
import 'package:provider/provider.dart';

class ReadingCarousel extends StatefulWidget {
  const ReadingCarousel({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ReadingCarouselState();
  }
}

class _ReadingCarouselState extends State<ReadingCarousel> {
  int currentIndex = 0;

  late Stream<QuerySnapshot> readingStream;

  String getTimeText(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inDays == 0) {
      return "Hôm nay";
    } else if (difference.inDays == 1) {
      return "1 ngày trước";
    } else {
      return "${difference.inDays} ngày trước";
    }
  }

  @override
  initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;

    readingStream = FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .collection('Reading')
        .orderBy('updatedAt', descending: true)
        .limit(10)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;
    return StreamBuilder<QuerySnapshot>(
      stream: readingStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Column(
            children: [
              Container(
                width: double.infinity,
                height: 210,
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.grey),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: Text(
                    'Lỗi tải dữ liệu',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Column(
            children: [
              Container(
                width: double.infinity,
                height: 210,
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.grey),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: Text(
                    'Bạn chưa có truyện từng đọc',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        final docs = snapshot.data!.docs;
        return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: OkLab(0.88, 0.04, 0).toColor(),
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: CarouselSlider.builder(
                itemCount: docs.length,
                itemBuilder: (context, index, realIndex) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final comicId = data['comicId'];
                  final comicTitle = data['comicTitle'];
                  final coverUrl = data['coverUrl'];
                  final chapterTitle = data['chapterTitle'];
                  final chapterIndex = data['chapterIndex'];
                  final totalChapters = data['totalChapters'];
                  final progress = (data['progress'] as num).toDouble();
                  final chapterId = data['chapterId'];
                  final Timestamp timestamp = data['updatedAt'];
                  final DateTime updatedAt = timestamp.toDate();
                  final String status = data['status'];
                  return Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: isDark
                            ? OkLab(0.63, 0.24, 0).toColor().withOpacity(0.4)
                            : OkLab(0.88, 0.04, 0).toColor(),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            coverUrl,
                            width: 100,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 100,
                                height: 200,
                                color: Colors.grey[300],
                                child: Icon(Icons.broken_image),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                comicTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isDark
                                      ? OkLab(0.83, 0.07, -0.1).toColor()
                                      : OkLab(0.5, 0.14, -0.22).toColor(),
                                ),
                              ),
                              SizedBox(height: 6),
                              Row(
                                children: [
                                  StatusChip(status: status),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      getTimeText(updatedAt),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? OkLab(
                                                0.55,
                                                -0.01,
                                                -0.04,
                                              ).toColor()
                                            : OkLab(
                                                0.7,
                                                -0.01,
                                                -0.04,
                                              ).toColor(),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      "$chapterTitle",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    "${(progress * 100).toInt()}%",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6),
                              LinearProgressIndicator(
                                value: progress,
                                minHeight: 6,
                                borderRadius: BorderRadius.circular(10),
                                color: isDark
                                    ? OkLab(0.55, 0.06, -0.24).toColor()
                                    : OkLab(0.75, 0.17, -0.01).toColor(),
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: progress.toInt() == 1
                                          ? () {}
                                          : () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: !isDark
                                            ? OkLab(0.75, 0.17, -0.01).toColor()
                                            : OkLab(0.63, 0.24, 0).toColor(),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            progress.toInt() == 1
                                                ? Icons.replay
                                                : Icons.play_arrow_sharp,
                                            color: Colors.white,
                                          ),
                                          Text(
                                            progress.toInt() == 1
                                                ? " Đọc lại"
                                                : " Đọc tiếp tục",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
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
                },
                options: CarouselOptions(
                  height: 200,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 5),
                  autoPlayAnimationDuration: Duration(seconds: 1),
                  viewportFraction: 1,
                  onPageChanged: (index, reason) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < docs.length; i++)
                  Container(
                    width: 8,
                    height: 8,
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: currentIndex == i ? Colors.pink : Colors.grey,
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
