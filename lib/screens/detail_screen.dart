import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comic_app/api/api_service.dart';
import 'package:comic_app/models/chapter_model.dart';
import 'package:comic_app/models/comic_detail_model.dart';
import 'package:comic_app/models/reading_comic.dart';
import 'package:comic_app/screens/reading_screen.dart';
import 'package:comic_app/theme/app_colors.dart';
import 'package:comic_app/theme/app_dark_colors.dart';
import 'package:comic_app/theme/app_light_colors.dart';
import 'package:comic_app/theme/theme_provider.dart';
import 'package:comic_app/widgets/chapter_item.dart';
import 'package:comic_app/widgets/comment_section.dart';
import 'package:comic_app/widgets/expandable_description.dart';
import 'package:comic_app/widgets/genre_tag.dart';
import 'package:comic_app/widgets/related_comics_tab.dart';
import 'package:comic_app/widgets/stat_item.dart';
import 'package:comic_app/widgets/status_chip.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:okcolor/models/oklab.dart';
import 'package:provider/provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class DetailScreen extends StatefulWidget {
  final String id;

  const DetailScreen({super.key, required this.id});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final user = FirebaseAuth.instance.currentUser;
  bool isFav = false;
  bool isSaved = false;
  bool isNotify = false;
  bool isLoadingBtn = false;

  ComicDetailModel? comicDetail;
  bool isLoading = true;
  String? errorMessage;

  List<ChapterModel>? chapters;
  bool isLoadingChapter = true;
  String? errorMessageChapter;
  bool isReversedChapter = false;

  int chunkSize = 100;
  int currentChunkIndex = 0;

  int count = 0;

  final ScrollController _chunkScrollController = ScrollController();

  int selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _fetchChapters();
  }

  Future<void> getCount() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('Comments')
        .doc(widget.id)
        .collection('comments')
        .get();
    setState(() {
      count = snapshot.docs.length;
    });
  }

  Future<void> checkSavedAndFavorite() async {
    if (user == null || comicDetail == null) return;
    final results = await Future.wait([
      FirebaseFirestore.instance
          .collection('Users')
          .doc(user!.uid)
          .collection('Favorite')
          .doc(comicDetail!.id)
          .get(),
      FirebaseFirestore.instance
          .collection('Users')
          .doc(user!.uid)
          .collection('Saved')
          .doc(comicDetail!.id)
          .get(),
      FirebaseFirestore.instance
          .collection('Users')
          .doc(user!.uid)
          .collection('Notification')
          .doc(comicDetail!.id)
          .get(),
    ]);
    final docsFav = results[0];

    final docsSaved = results[1];

    final docsNotify = results[1];

    if (!mounted) return;

    setState(() {
      isFav = docsFav.exists;
      isSaved = docsSaved.exists;
      isNotify = docsNotify.exists;
    });
  }

  void _fetchData() async {
    try {
      final result = await ApiService.fetchComicDetail(widget.id);
      if (!mounted) return;
      setState(() {
        comicDetail = result;
        isLoading = false;
      });
      checkSavedAndFavorite();
      getCount();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  void _fetchChapters() async {
    try {
      final result = await ApiService.fetchAllComicChapters(widget.id);

      if (!mounted) return;
      setState(() {
        chapters = result;
        isLoadingChapter = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoadingChapter = false;
        errorMessageChapter = e.toString();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _chunkScrollController.dispose();
  }

  Widget _buildTabItem(int index, String title, IconData icon, bool isDark) {
    bool isSelected = selectedTabIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedTabIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                      ? const Color(0xFFA855F7)
                      : OkLab(0.56, 0.15, -0.24).toColor())
                : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? Colors.white
                    : (isDark
                          ? Colors.white.withValues(alpha: 0.6)
                          : Colors.black.withValues(alpha: 0.6)),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Colors.white
                      : (isDark
                            ? Colors.white.withValues(alpha: 0.6)
                            : Colors.black.withValues(alpha: 0.6)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;
    final gradient = isDark
        ? AppColorsDark.gradientBackground
        : AppColorsLight.gradientBackground;

    List<ChapterModel> currentChapters = [];
    int totalChunks = 0;

    if (chapters != null && chapters!.isNotEmpty) {
      List<ChapterModel> baseList = chapters!.reversed.toList();

      totalChunks = (baseList.length / chunkSize).ceil();

      int startIndex = currentChunkIndex * chunkSize;
      int endIndex = (startIndex + chunkSize > baseList.length)
          ? baseList.length
          : startIndex + chunkSize;

      currentChapters = baseList.sublist(startIndex, endIndex);

      if (isReversedChapter) {
        currentChapters = currentChapters.reversed.toList();
      }
    }

    return Scaffold(
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
      floatingActionButton: SpeedDial(
        icon: Icons.menu,
        activeIcon: Icons.close,
        backgroundColor: const Color(0xFFFF2E7E),
        foregroundColor: Colors.white,

        overlayColor: Colors.black,
        overlayOpacity: 0.7,

        spaceBetweenChildren: 12,

        renderOverlay: true,
        useRotationAnimation: true,

        children: [
          SpeedDialChild(
            child: Icon(
              !isNotify
                  ? Icons.notifications_active_outlined
                  : Icons.notifications_off_outlined,
              color: Colors.white,
            ),
            backgroundColor: const Color(0xFFC0A3E5),
            onTap: () async {
              if (user == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: isDark
                        ? OkLab(0.2, 0.06, 0.02).toColor()
                        : OkLab(0.97, 0.02, 0).toColor(),
                    content: Text(
                      'Bạn cần đăng nhập để thực hiện hành động này.',
                      style: TextStyle(
                        color: isDark
                            ? OkLab(0.8, 0.11, 0.04).toColor()
                            : OkLab(0.58, 0.21, 0.12).toColor(),
                      ),
                    ),
                  ),
                );
              } else {
                setState(() {
                  isLoadingBtn = true;
                });
                if (!isNotify) {
                  await ReadingComic.addLibrary(
                    comicId: comicDetail!.id,
                    comicTitle: comicDetail!.title,
                    coverUrl: comicDetail!.coverUrl,
                    chapterTitle: chapters![0].chapterTitle,
                    totalChapters: chapters!.length,
                    status: comicDetail!.status,
                    collection: 'Notification',
                  );
                } else {
                  await ReadingComic.deleteReading(
                    comicId: comicDetail!.id,
                    collection: 'Notification',
                  );
                }
                await checkSavedAndFavorite();
                setState(() {
                  isLoadingBtn = false;
                });
              }
            },
          ),

          SpeedDialChild(
            child: Icon(
              !isFav ? Icons.favorite_border_rounded : Icons.favorite,
              color: Colors.white,
            ),
            backgroundColor: const Color(0xFFFFA5B4),
            onTap: () async {
              if (user == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: isDark
                        ? OkLab(0.2, 0.06, 0.02).toColor()
                        : OkLab(0.97, 0.02, 0).toColor(),
                    content: Text(
                      'Bạn cần đăng nhập để thực hiện hành động này.',
                      style: TextStyle(
                        color: isDark
                            ? OkLab(0.8, 0.11, 0.04).toColor()
                            : OkLab(0.58, 0.21, 0.12).toColor(),
                      ),
                    ),
                  ),
                );
              } else {
                setState(() {
                  isLoadingBtn = true;
                });
                if (!isFav) {
                  await ReadingComic.addLibrary(
                    comicId: comicDetail!.id,
                    comicTitle: comicDetail!.title,
                    coverUrl: comicDetail!.coverUrl,
                    chapterTitle: chapters![0].chapterTitle,
                    totalChapters: chapters!.length,
                    status: comicDetail!.status,
                    collection: 'Favorite',
                  );
                  await FirebaseFirestore.instance
                      .collection('Favorite')
                      .doc(comicDetail!.id)
                      .collection('Users')
                      .doc(user!.uid)
                      .set({
                        'comicId': comicDetail!.id,
                        'comicTitle': comicDetail!.title,
                        'coverUrl': comicDetail!.coverUrl,
                        'chapterTitle': chapters![0].chapterTitle,
                        'totalChapters': chapters!.length,
                        'status': comicDetail!.status,
                      });
                } else {
                  await ReadingComic.deleteReading(
                    comicId: comicDetail!.id,
                    collection: 'Favorite',
                  );
                  await FirebaseFirestore.instance
                      .collection('Favorite')
                      .doc(comicDetail!.id)
                      .collection('Users')
                      .doc(user!.uid)
                      .delete();
                }
                await checkSavedAndFavorite();
                setState(() {
                  isLoadingBtn = false;
                });
              }
            },
          ),

          SpeedDialChild(
            child: Icon(
              !isSaved ? Icons.bookmark_border_rounded : Icons.bookmark,
              color: Colors.white,
            ),
            backgroundColor: const Color(0xFF90CAF9),
            onTap: () async {
              if (user == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: isDark
                        ? OkLab(0.2, 0.06, 0.02).toColor()
                        : OkLab(0.97, 0.02, 0).toColor(),
                    content: Text(
                      'Bạn cần đăng nhập để thực hiện hành động này.',
                      style: TextStyle(
                        color: isDark
                            ? OkLab(0.8, 0.11, 0.04).toColor()
                            : OkLab(0.58, 0.21, 0.12).toColor(),
                      ),
                    ),
                  ),
                );
              } else {
                setState(() {
                  isLoadingBtn = true;
                });
                if (!isSaved) {
                  await ReadingComic.addLibrary(
                    comicId: comicDetail!.id,
                    comicTitle: comicDetail!.title,
                    coverUrl: comicDetail!.coverUrl,
                    chapterTitle: chapters![0].chapterTitle,
                    totalChapters: chapters!.length,
                    status: comicDetail!.status,
                    collection: 'Saved',
                  );
                  await FirebaseFirestore.instance
                      .collection('Saved')
                      .doc(comicDetail!.id)
                      .collection('Users')
                      .doc(user!.uid)
                      .set({
                        'comicId': comicDetail!.id,
                        'comicTitle': comicDetail!.title,
                        'coverUrl': comicDetail!.coverUrl,
                        'chapterTitle': chapters![0].chapterTitle,
                        'totalChapters': chapters!.length,
                        'status': comicDetail!.status,
                      });
                } else {
                  await ReadingComic.deleteReading(
                    comicId: comicDetail!.id,
                    collection: 'Saved',
                  );
                  await FirebaseFirestore.instance
                      .collection('Saved')
                      .doc(comicDetail!.id)
                      .collection('Users')
                      .doc(user!.uid)
                      .delete();
                }
                await checkSavedAndFavorite();
                setState(() {
                  isLoadingBtn = false;
                });
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          isLoading
              ? SizedBox(
                  height: 700,
                  child: Center(child: CircularProgressIndicator()),
                )
              : (errorMessage != null)
              ? SizedBox(height: 700, child: Center(child: Text(errorMessage!)))
              : Container(
                  decoration: BoxDecoration(gradient: gradient),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: CachedNetworkImage(
                                  imageUrl: comicDetail!.coverUrl,
                                  width: 200,
                                  height: 300,
                                  fit: BoxFit.cover,
                                  memCacheHeight: 300,
                                  placeholder: (context, url) => Container(
                                    height: 300,
                                    color: Colors.grey.withValues(alpha: 0.1),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.secondaryPink,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        height: 300,
                                        color: Colors.grey.withValues(
                                          alpha: 0.1,
                                        ),
                                        child: const Icon(
                                          Icons.broken_image,
                                          color: Colors.grey,
                                          size: 40,
                                        ),
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              comicDetail!.title,
                              style: TextStyle(
                                fontSize: 24,
                                color: isDark
                                    ? OkLab(0.83, 0.07, -0.1).toColor()
                                    : OkLab(0.5, 0.14, -0.22).toColor(),
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              comicDetail!.altTitle,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 8,
                              runSpacing: 12,
                              children: [
                                for (var genre in comicDetail!.genres)
                                  GenreTag(title: genre),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                StatusChip(status: comicDetail!.status),
                                const SizedBox(width: 12),
                                StatItem(
                                  icon: Icon(
                                    Icons.calendar_today_outlined,
                                    size: 16,
                                    color: OkLab(0.79, -0.18, 0.1).toColor(),
                                  ),
                                  title: comicDetail!.publishYear,
                                ),
                                const SizedBox(width: 12),
                                StatItem(
                                  icon: Icon(
                                    Icons.remove_red_eye_outlined,
                                    size: 16,
                                    color: OkLab(0.71, -0.04, -0.16).toColor(),
                                  ),
                                  title: '0',
                                ),
                                const SizedBox(width: 12),
                                StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('Saved')
                                      .doc(comicDetail!.id)
                                      .collection('Users')
                                      .snapshots(),
                                  builder: (_, snapshot) {
                                    return Row(
                                      children: [
                                        Icon(
                                          Icons.bookmark_border,
                                          size: 16,
                                          color: OkLab(
                                            0.71,
                                            -0.04,
                                            -0.16,
                                          ).toColor(),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${snapshot.data?.docs.length ?? 0}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(width: 12),
                                StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('Favorite')
                                      .doc(comicDetail!.id)
                                      .collection('Users')
                                      .snapshots(),
                                  builder: (_, snapshot) {
                                    return Row(
                                      children: [
                                        Icon(
                                          Icons.favorite_border,
                                          size: 16,
                                          color: OkLab(
                                            0.72,
                                            0.2,
                                            -0.0,
                                          ).toColor(),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${snapshot.data?.docs.length ?? 0}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(width: 10),
                                Icon(
                                  Icons.history_edu,
                                  size: 20,
                                  color: Color(0xFF3B82F6),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Tác giả:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    comicDetail!.authorName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: isDark
                                          ? OkLab(0.83, -0.07, -0.09).toColor()
                                          : OkLab(0.59, -0.07, -0.14).toColor(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            ExpandableDescription(
                              text: comicDetail!.description,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {
                                    ChapterModel firstChapter =
                                        chapters![chapters!.length - 1];
                                    ReadingComic.saveProgress(
                                      comicId: widget.id,
                                      comicTitle: comicDetail!.title,
                                      coverUrl: comicDetail!.coverUrl,
                                      chapterId: firstChapter.id,
                                      chapterTitle: firstChapter.chapterTitle,
                                      chapterIndex: 1,
                                      totalChapters: chapters!.length,
                                      status: comicDetail!.status,
                                    );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ReadingScreen(
                                          comicId: widget.id,
                                          coverUrl: comicDetail!.coverUrl,
                                          chapterId: firstChapter.id,
                                          title: comicDetail!.title,
                                          chapterTitle:
                                              firstChapter.chapterTitle,
                                          uploaderName:
                                              firstChapter.uploaderName,
                                          chapters: chapters!,
                                          index: chapters!.length - 1,
                                          status: comicDetail!.status,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: OkLab(0.63, 0.24, 0).toColor(),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.visibility_outlined,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Bắt đầu đọc',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                InkWell(
                                  onTap: () {
                                    ChapterModel lastChapter = chapters![0];
                                    ReadingComic.saveProgress(
                                      comicId: widget.id,
                                      comicTitle: comicDetail!.title,
                                      coverUrl: comicDetail!.coverUrl,
                                      chapterId: lastChapter.id,
                                      chapterTitle: lastChapter.chapterTitle,
                                      chapterIndex: chapters!.length,
                                      totalChapters: chapters!.length,
                                      status: comicDetail!.status,
                                    );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ReadingScreen(
                                          comicId: widget.id,
                                          coverUrl: comicDetail!.coverUrl,
                                          chapterId: lastChapter.id,
                                          title: comicDetail!.title,
                                          chapterTitle:
                                              lastChapter.chapterTitle,
                                          uploaderName:
                                              lastChapter.uploaderName,
                                          chapters: chapters!,
                                          index: 0,
                                          status: comicDetail!.status,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: OkLab(0.55, 0.06, -0.24).toColor(),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.auto_awesome_outlined,
                                          size: 18,
                                          color: !isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Đọc mới nhất',
                                          style: TextStyle(
                                            color: !isDark
                                                ? Colors.white
                                                : Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Color(0xFF231A2F)
                                    : OkLab(0.97, 0.01, 0).toColor(),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: OkLab(
                                    0.9,
                                    0.06,
                                    -0.02,
                                  ).toColor().withValues(alpha: 0.5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  _buildTabItem(
                                    0,
                                    'Chapters',
                                    Icons.format_list_bulleted,
                                    isDark,
                                  ),
                                  StreamBuilder<DocumentSnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('Comments')
                                        .doc(widget.id)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      int count =
                                          snapshot.data?['totalComments'] ?? 0;
                                      return _buildTabItem(
                                        1,
                                        count == 0 ? '' : ' ($count)',
                                        Icons.chat_bubble_outline,
                                        isDark,
                                      );
                                    },
                                  ),
                                  _buildTabItem(
                                    2,
                                    'Liên quan',
                                    Icons.auto_awesome_outlined,
                                    isDark,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (selectedTabIndex == 0)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,

                                  borderRadius: BorderRadius.circular(16),

                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.1)
                                        : OkLab(0.88, 0.04, 0).toColor(),

                                    width: 1,
                                  ),
                                ),

                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),

                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,

                                      children: [
                                        Text(
                                          'Tất cả chapters',

                                          style: TextStyle(
                                            fontSize: 16,

                                            fontWeight: FontWeight.bold,

                                            color: isDark
                                                ? Color(0xFFD69DE5)
                                                : OkLab(
                                                    0.5,
                                                    0.14,
                                                    -0.22,
                                                  ).toColor(),
                                          ),
                                        ),

                                        Row(
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  isLoadingChapter = true;

                                                  _fetchChapters();
                                                });
                                              },

                                              icon: Icon(
                                                Icons.sync,
                                                color: Color(0xFFFF2E7E),
                                                size: 18,
                                              ),
                                            ),

                                            IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  isReversedChapter =
                                                      !isReversedChapter;

                                                  if (isReversedChapter) {
                                                    currentChunkIndex =
                                                        totalChunks - 1;
                                                  } else {
                                                    currentChunkIndex = 0;
                                                  }

                                                  if (_chunkScrollController
                                                      .hasClients) {
                                                    _chunkScrollController
                                                        .animateTo(
                                                          0.0,

                                                          duration:
                                                              const Duration(
                                                                milliseconds:
                                                                    300,
                                                              ),

                                                          curve:
                                                              Curves.easeInOut,
                                                        );
                                                  }
                                                });
                                              },

                                              icon: RotatedBox(
                                                quarterTurns: isReversedChapter
                                                    ? 0
                                                    : 2,

                                                child: Icon(
                                                  Icons.sort,
                                                  color: Color(0xFFFF2E7E),
                                                  size: 18,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 8),

                                    if (totalChunks > 1)
                                      SizedBox(
                                        height: 40,

                                        child: ListView.builder(
                                          controller: _chunkScrollController,

                                          scrollDirection: Axis.horizontal,

                                          itemCount: totalChunks,

                                          itemBuilder: (context, index) {
                                            int actualIndex = isReversedChapter
                                                ? (totalChunks - 1 - index)
                                                : index;

                                            int startChap =
                                                actualIndex * chunkSize + 1;

                                            int endChap =
                                                (actualIndex + 1) * chunkSize;

                                            if (endChap > chapters!.length) {
                                              endChap = chapters!.length;
                                            }

                                            bool isSelected =
                                                currentChunkIndex ==
                                                actualIndex;

                                            return InkWell(
                                              onTap: () {
                                                setState(() {
                                                  currentChunkIndex =
                                                      actualIndex;
                                                });
                                              },

                                              child: Container(
                                                margin: EdgeInsets.only(
                                                  right: 15,
                                                ),

                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 10,
                                                ),

                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),

                                                  border: Border.all(
                                                    color: Colors.white,
                                                  ),

                                                  color: isSelected
                                                      ? Color(0xFFFF2E7E)
                                                      : Colors.transparent,
                                                ),

                                                child: Text(
                                                  '$startChap - $endChap',

                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),

                                    totalChunks > 1
                                        ? SizedBox(height: 20)
                                        : SizedBox.shrink(),

                                    isLoadingChapter
                                        ? const SizedBox(
                                            height: 300,
                                            child: Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          )
                                        : (errorMessageChapter != null)
                                        ? SizedBox(
                                            height: 300,
                                            child: Center(
                                              child: Text(errorMessageChapter!),
                                            ),
                                          )
                                        : chapters!.isEmpty
                                        ? SizedBox(
                                            height: 150,

                                            child: Center(
                                              child: Text(
                                                'Bộ truyện này chưa có chapter nào.',

                                                style: TextStyle(
                                                  color: isDark
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                              ),
                                            ),
                                          )
                                        : ListView.builder(
                                            shrinkWrap: true,

                                            physics:
                                                const NeverScrollableScrollPhysics(),

                                            itemCount: currentChapters.length,

                                            itemBuilder: (context, index) {
                                              final chapter =
                                                  currentChapters[index];

                                              return InkWell(
                                                onTap: () async {
                                                  int absoluteIndex = chapters!
                                                      .indexOf(chapter);

                                                  await ReadingComic.saveProgress(
                                                    comicId: widget.id,

                                                    comicTitle:
                                                        comicDetail!.title,

                                                    coverUrl:
                                                        comicDetail!.coverUrl,

                                                    chapterId: chapter.id,

                                                    chapterTitle:
                                                        chapter.chapterTitle,

                                                    chapterIndex:
                                                        chapters!.length -
                                                        absoluteIndex,

                                                    totalChapters:
                                                        chapters!.length,

                                                    status: comicDetail!.status,
                                                  );

                                                  Navigator.push(
                                                    context,

                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ReadingScreen(
                                                            comicId: widget.id,

                                                            coverUrl:
                                                                comicDetail!
                                                                    .coverUrl,

                                                            chapterId:
                                                                chapter.id,

                                                            title: comicDetail!
                                                                .title,

                                                            chapterTitle: chapter
                                                                .chapterTitle,

                                                            uploaderName: chapter
                                                                .uploaderName,

                                                            chapters: chapters!,

                                                            index:
                                                                absoluteIndex,

                                                            status: comicDetail!
                                                                .status,
                                                          ),
                                                    ),
                                                  );
                                                },

                                                child: ChapterItem(
                                                  chapterTitle:
                                                      chapter.chapterTitle,

                                                  uploaderName:
                                                      chapter.uploaderName,

                                                  publishDate:
                                                      chapter.publishDate,

                                                  isNewest:
                                                      chapter.id ==
                                                      chapters![0].id,
                                                ),
                                              );
                                            },
                                          ),
                                  ],
                                ),
                              )
                            else if (selectedTabIndex == 1)
                              user == null
                                  ? Container(
                                      height: 200,
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Vui lòng đăng nhập để sử dụng tính năng này',
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    )
                                  : CommentSection(comicId: widget.id)
                            else if (selectedTabIndex == 2)
                              RelatedComicsTab(
                                isDark: isDark,
                                comicDetail: comicDetail!,
                              ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
          //isFavLoading
          if (isLoadingBtn)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
