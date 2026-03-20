import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comic_app/api/api_service.dart';
import 'package:comic_app/models/reading_comic.dart';
import 'package:comic_app/screens/reading_screen.dart';
import 'package:comic_app/theme/app_dark_colors.dart';
import 'package:comic_app/theme/app_light_colors.dart';
import 'package:comic_app/theme/theme_provider.dart';
import 'package:comic_app/widgets/status_chip.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:okcolor/models/oklab.dart';
import 'package:provider/provider.dart';

class ReadingList extends StatefulWidget {
  const ReadingList({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ReadingListState();
  }
}

class _ReadingListState extends State<ReadingList> {
  int currentPage = 1;
  final int pageSize = 10;

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
        .collection('Reading')
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
    final snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .collection('Reading')
        .get();
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

      double progress = (chapterIndex / newTotalChapters) * 100;

      if (oldTotalChapters != newTotalChapters) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .collection('Reading')
            .doc(comicId)
            .update({'totalChapters': newTotalChapters, 'progress': progress});
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

  Future<void> updateFireStore(
    String comicId,
    String string,
    dynamic dynamic,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .collection('Reading')
        .doc(comicId)
        .update({string: dynamic});
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;
    if (isLoading) {
      return SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }
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
              Center(
                child: Text(
                  'Bạn chưa có truyện từng đọc',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          );
        }
        final docs = snapshot.data!.docs;

        final totalPages = (docs.length / pageSize).ceil();

        int start = (currentPage - 1) * pageSize;

        int end = start + pageSize;

        if (end > docs.length) end = docs.length;

        final pageDocs = docs.sublist(start, end);

        return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: isDark
                      ? OkLab(
                          0.37,
                          -0.01,
                          -0.04,
                        ).toColor().withValues(alpha: 0.8)
                      : OkLab(0.88, 0.04, 0).toColor(),
                ),
                borderRadius: BorderRadius.circular(20),
                color: isDark
                    ? AppColorsDark.background2
                    : AppColorsLight.background2,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black.withValues(alpha: 0.1),
                  ),
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: pageDocs.length,
                itemBuilder: (context, index) {
                  final data = pageDocs[index].data() as Map<String, dynamic>;
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
                    child: Column(
                      children: [
                        Row(
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
                                        onPressed: () async {
                                          await ReadingComic.deleteReading(
                                            comicId: comicId,
                                          );
                                        },
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            final chapters =
                                                await ApiService.fetchAllComicChapters(
                                                  comicId,
                                                );
                                            if (progress.toInt() != 1) {
                                              final index = chapters.indexWhere(
                                                (c) => c.id == chapterId,
                                              );
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => ReadingScreen(
                                                    comicId: comicId,
                                                    coverUrl: coverUrl,
                                                    chapterId: chapterId,
                                                    title: comicTitle,
                                                    chapterTitle: chapterTitle,
                                                    uploaderName:
                                                        chapters[index]
                                                            .uploaderName,
                                                    chapters: chapters,
                                                    index: index,
                                                    status: status,
                                                  ),
                                                ),
                                              );

                                              await ReadingComic.saveProgress(
                                                comicId: comicId,
                                                comicTitle: comicTitle,
                                                coverUrl: coverUrl,
                                                chapterId: chapterId,
                                                chapterTitle: chapterTitle,
                                                chapterIndex: chapterIndex,
                                                totalChapters: totalChapters,
                                                status: status,
                                              );
                                            } else {
                                              final index = chapters.length - 1;
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => ReadingScreen(
                                                    comicId: comicId,
                                                    coverUrl: coverUrl,
                                                    chapterId:
                                                        chapters[index].id,
                                                    title: comicTitle,
                                                    chapterTitle:
                                                        chapters[index]
                                                            .chapterTitle,
                                                    uploaderName:
                                                        chapters[index]
                                                            .uploaderName,
                                                    chapters: chapters,
                                                    index: index,
                                                    status: status,
                                                  ),
                                                ),
                                              );

                                              await ReadingComic.pushNew(
                                                comicId: comicId,
                                                comicTitle: comicTitle,
                                                coverUrl: coverUrl,
                                                chapterId: chapters[index].id,
                                                chapterTitle: chapters[index]
                                                    .chapterTitle,
                                                chapterIndex: 1,
                                                totalChapters: totalChapters,
                                                status: status,
                                              );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: !isDark
                                                ? OkLab(
                                                    0.75,
                                                    0.17,
                                                    -0.01,
                                                  ).toColor()
                                                : OkLab(
                                                    0.63,
                                                    0.24,
                                                    0,
                                                  ).toColor(),
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
                        SizedBox(height: 30),
                        if (index != pageDocs.length - 1)
                          Container(
                            color: Colors.grey.withValues(alpha: 0.3),
                            height: 1,
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: currentPage > 1
                      ? () {
                          setState(() {
                            currentPage--;
                          });
                        }
                      : null,
                  icon: Icon(Icons.arrow_back_ios),
                ),
                for (int i = 1; i <= totalPages; i++)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          currentPage = i;
                        });
                      },
                      child: Text(
                        '$i',
                        style: TextStyle(
                          fontWeight: currentPage == i
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                IconButton(
                  onPressed: currentPage < totalPages
                      ? () {
                          setState(() {
                            currentPage++;
                          });
                        }
                      : null,
                  icon: Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
