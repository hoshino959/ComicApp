import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comic_app/screens/detail_screen.dart';
import 'package:comic_app/theme/theme_provider.dart';
import 'package:comic_app/widgets/status_chip.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:okcolor/models/oklab.dart';
import 'package:provider/provider.dart';

class ReadingGrid extends StatefulWidget {
  const ReadingGrid({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ReadingGridState();
  }
}

class _ReadingGridState extends State<ReadingGrid> {
  int currentPage = 1;
  final int pageSize = 10;

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
  }

  String formatViews(int views) {
    if (views >= 1000000) {
      double val = views / 1000000;
      return val % 1 == 0
          ? '${val.toInt()}M'
          : '${val.toStringAsFixed(1)}M';
    } else if (views >= 1000) {
      double val = views / 1000;
      return val % 1 == 0
          ? '${val.toInt()}K'
          : '${val.toStringAsFixed(1)}K';
    } else {
      return views.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Provider.of<ThemeProvider>(context).themeMode ==
        ThemeMode.dark;
    return StreamBuilder<QuerySnapshot>(
      stream: readingStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Column(
            children: [
              Container(
                width: double.infinity,
                height: 210,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: Text(
                    'Lỗi tải dữ liệu',
                    style: TextStyle(
                      color: isDark
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        if (!snapshot.hasData ||
            snapshot.data!.docs.isEmpty) {
          return Column(
            children: [
              Container(
                width: double.infinity,
                height: 210,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: Text(
                    'Bạn chưa có truyện từng đọc',
                    style: TextStyle(
                      color: isDark
                          ? Colors.white
                          : Colors.black,
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

        final totalPages = (docs.length / pageSize).ceil();

        int start = (currentPage - 1) * pageSize;

        int end = start + pageSize;

        if (end > docs.length) end = docs.length;

        final pageDocs = docs.sublist(start, end);

        return Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: pageDocs.length,
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.54,
                  ),
              itemBuilder: (context, index) {
                final data =
                    pageDocs[index].data()
                        as Map<String, dynamic>;
                final comicId = data['comicId'];
                final comicTitle = data['comicTitle'];
                final coverUrl = data['coverUrl'];
                final chapterTitle = data['chapterTitle'];
                final totalChapters = data['totalChapters'];
                final String status = data['status'];

                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            DetailScreen(id: comicId),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: OkLab(
                          0.28,
                          -0.01,
                          -0.03,
                        ).toColor().withOpacity(0.8),
                        borderRadius: BorderRadius.circular(
                          15,
                        ),
                      ),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(
                                      10,
                                    ),
                                child: Image.network(
                                  coverUrl,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Container(
                                          width: 100,
                                          height: 200,
                                          color: Colors
                                              .grey[300],
                                          child: Icon(
                                            Icons
                                                .broken_image,
                                          ),
                                        );
                                      },
                                ),
                              ),
                              Positioned(
                                child: StatusChip(
                                  status: status,
                                ),
                                bottom: 10,
                                right: 10,
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(
                              10,
                              15,
                              10,
                              0,
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  comicTitle,
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: OkLab(
                                      0.83,
                                      0.07,
                                      -0.1,
                                    ).toColor(),
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  chapterTitle,
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: OkLab(
                                      0.71,
                                      0.12,
                                      -0.17,
                                    ).toColor(),
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    Icon(
                                      Icons
                                          .menu_book_outlined,
                                      color: OkLab(
                                        0.84,
                                        0.05,
                                        0.12,
                                      ).toColor(),
                                      size: 16,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      totalChapters
                                          .toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Icon(
                                      Icons.remove_red_eye,
                                      color: OkLab(
                                        0.71,
                                        -0.04,
                                        -0.16,
                                      ).toColor(),
                                      size: 16,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      formatViews(
                                        totalChapters *
                                                10000 +
                                            Random()
                                                .nextInt(
                                                  9999,
                                                ),
                                      ),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
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
                    padding: EdgeInsets.symmetric(
                      horizontal: 6,
                    ),
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
