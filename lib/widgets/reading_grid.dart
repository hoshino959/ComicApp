import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comic_app/api/api_service.dart';
import 'package:comic_app/screens/detail_screen.dart';
import 'package:comic_app/theme/theme_provider.dart';
import 'package:comic_app/widgets/status_chip.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:okcolor/models/oklab.dart';
import 'package:provider/provider.dart';

class ReadingGrid extends StatefulWidget {
  final String status;

  const ReadingGrid({super.key, required this.status});

  @override
  State<StatefulWidget> createState() {
    return _ReadingGridState();
  }
}

class _ReadingGridState extends State<ReadingGrid> {
  bool isLoading = false;

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
        .collection(widget.status)
        .orderBy('updatedAt', descending: true)
        .snapshots();
    _initData();
  }

  Future<void> _initData() async {
    setState(() {
      isLoading = true;
    });
    await updateComic();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> updateComic() async {
    final user = FirebaseAuth.instance.currentUser;
    final snapshot = await FirebaseFirestore.instance.collection('Users').doc(user!.uid).collection('Reading').get();
    for (var doc in snapshot.docs) {
      final data = doc.data();

      final comicId = data['comicId'];

      final oldTotalChapters = data['totalChapters'];
      final oldCoverUrl = data['coverUrl'];
      final oldTitle = data['comicTitle'];
      final oldStatus = data['status'];

      final chapterIndex = data['chapterIndex'];

      final chapters = await ApiService.fetchAllComicChapters(comicId);
      final comicDetail = await ApiService.fetchComicDetail(comicId);

      if (chapters.isEmpty || comicDetail == null) continue;

      final newTotalChapters = chapters.length;
      final newCoverUrl = comicDetail.coverUrl;
      final newTitle = comicDetail.title;
      final newStatus = comicDetail.status;

      double progress = (chapterIndex / newTotalChapters);

      if (oldTotalChapters != newTotalChapters) {
        await FirebaseFirestore.instance.collection('Users').doc(user.uid).collection('Reading').doc(comicId).update({
          'totalChapters': newTotalChapters,
          'progress': progress,
        });
      }
      if (oldCoverUrl != newCoverUrl) {
        updateFireStore(comicId, 'coverUrl', newCoverUrl);
      }
      if (oldTitle != newTitle) {
        updateFireStore(comicId, 'comicTitle', newTitle);
      }
      if (oldStatus != newStatus) {
        updateFireStore(comicId, 'status', newStatus);
      }
    }
  }

  Future<void> updateFireStore(String comicId, String string, dynamic dynamic) async {
    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection('Users').doc(user!.uid).collection('Reading').doc(comicId).update({
      string: dynamic,
    });
  }

  String formatViews(int views) {
    if (views >= 1000000) {
      double val = views / 1000000;
      return val % 1 == 0 ? '${val.toInt()}M' : '${val.toStringAsFixed(1)}M';
    } else if (views >= 1000) {
      double val = views / 1000;
      return val % 1 == 0 ? '${val.toInt()}K' : '${val.toStringAsFixed(1)}K';
    } else {
      return views.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;
    return StreamBuilder<QuerySnapshot>(
      stream: readingStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Expanded(
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.75,
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
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Expanded(
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.75,
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
          );
        }
        final docs = snapshot.data!.docs;

        final screenWidth = MediaQuery.of(context).size.width;
        final itemWidth = (screenWidth - 20) / 2;
        final itemHeight = 335;

        final ratio = itemWidth / itemHeight;

        return Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: ratio),
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                final comicId = data['comicId'];
                final comicTitle = data['comicTitle'];
                final coverUrl = data['coverUrl'];
                final chapterTitle = data['chapterTitle'];
                final totalChapters = data['totalChapters'];
                final String status = data['status'];

                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetailScreen(id: comicId)));
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? OkLab(0.28, -0.01, -0.03).toColor().withValues(alpha: 0.8) : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10)],
                      ),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  coverUrl,
                                  width: double.infinity,
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
                              Positioned(child: StatusChip(status: status), bottom: 10, right: 10),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(10, 15, 10, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  comicTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isDark
                                        ? OkLab(0.83, 0.07, -0.1).toColor()
                                        : OkLab(0.5, 0.14, -0.22).toColor(),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  chapterTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isDark
                                        ? OkLab(0.71, 0.12, -0.17).toColor()
                                        : OkLab(0.56, 0.15, -0.24).toColor(),
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    Icon(Icons.menu_book_outlined, color: OkLab(0.84, 0.05, 0.12).toColor(), size: 16),
                                    SizedBox(width: 5),
                                    Text(
                                      totalChapters.toString(),
                                      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14),
                                    ),
                                    SizedBox(width: 10),
                                    Icon(Icons.remove_red_eye, color: OkLab(0.71, -0.04, -0.16).toColor(), size: 16),
                                    SizedBox(width: 5),
                                    Text(
                                      formatViews(totalChapters * 10000 + Random().nextInt(9999)),
                                      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
