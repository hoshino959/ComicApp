import 'package:cached_network_image/cached_network_image.dart';
import 'package:comic_app/api/api_service.dart';
import 'package:comic_app/models/chapter_model.dart';
import 'package:comic_app/models/comic_detail_model.dart';
import 'package:comic_app/screens/reading_screen.dart';
import 'package:comic_app/theme/app_colors.dart';
import 'package:comic_app/theme/app_dark_colors.dart';
import 'package:comic_app/theme/app_light_colors.dart';
import 'package:comic_app/theme/theme_provider.dart';
import 'package:comic_app/widgets/chapter_item.dart';
import 'package:comic_app/widgets/genre_tag.dart';
import 'package:comic_app/widgets/stat_item.dart';
import 'package:comic_app/widgets/status_chip.dart';
import 'package:flutter/material.dart';
import 'package:okcolor/models/oklab.dart';
import 'package:provider/provider.dart';

class DetailScreen extends StatefulWidget {
  final String id;

  const DetailScreen({super.key, required this.id});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  ComicDetailModel? comicDetail;
  bool isLoading = true;
  String? errorMessage;

  List<ChapterModel>? chapters;
  bool isLoadingChapter = true;
  String? errorMessageChapter;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _fetchChapters();
  }

  void _fetchData() async {
    try {
      final result = await ApiService.fetchComicDetail(
        widget.id,
      );
      if (!mounted) return;
      setState(() {
        comicDetail = result;
        isLoading = false;
      });
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
      final result = await ApiService.fetchComicChapters(
        widget.id,
      );
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
  Widget build(BuildContext context) {
    final isDark =
        Provider.of<ThemeProvider>(context).themeMode ==
        ThemeMode.dark;

    final gradient = isDark
        ? AppColorsDark.gradientBackground
        : AppColorsLight.gradientBackground;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isLoading
          ? SizedBox(
              height: 700,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : (errorMessage != null)
          ? SizedBox(
              height: 700,
              child: Center(child: Text(errorMessage!)),
            )
          : Container(
              decoration: BoxDecoration(gradient: gradient),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(15),
                            child: CachedNetworkImage(
                              imageUrl:
                                  comicDetail!.coverUrl,
                              width: 200,
                              height: 300,
                              fit: BoxFit.cover,
                              memCacheHeight: 300,
                              placeholder: (context, url) =>
                                  Container(
                                    height: 300,
                                    color: Colors.grey
                                        .withValues(
                                          alpha: 0.1,
                                        ),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors
                                            .secondaryPink,
                                      ),
                                    ),
                                  ),
                              errorWidget:
                                  (
                                    context,
                                    url,
                                    error,
                                  ) => Container(
                                    height: 300,
                                    color: Colors.grey
                                        .withValues(
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
                                ? OkLab(
                                    0.83,
                                    0.07,
                                    -0.1,
                                  ).toColor()
                                : OkLab(
                                    0.5,
                                    0.14,
                                    -0.22,
                                  ).toColor(),
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          comicDetail!.altTitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? Colors.white
                                : Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 12,
                          children: [
                            for (var genre
                                in comicDetail!.genres)
                              GenreTag(title: genre),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.start,
                          children: [
                            StatusChip(
                              status: comicDetail!.status,
                            ),
                            const SizedBox(width: 12),
                            StatItem(
                              icon: Icon(
                                Icons
                                    .calendar_today_outlined,
                                size: 16,
                                color: OkLab(
                                  0.79,
                                  -0.18,
                                  0.1,
                                ).toColor(),
                              ),
                              title:
                                  comicDetail!.publishYear,
                            ),
                            const SizedBox(width: 12),
                            StatItem(
                              icon: Icon(
                                Icons
                                    .remove_red_eye_outlined,
                                size: 16,
                                color: OkLab(
                                  0.71,
                                  -0.04,
                                  -0.16,
                                ).toColor(),
                              ),
                              title: '0',
                            ),
                            const SizedBox(width: 12),
                            StatItem(
                              icon: Icon(
                                Icons.bookmark_border,
                                size: 16,
                                color: OkLab(
                                  0.72,
                                  0.2,
                                  -0.04,
                                ).toColor(),
                              ),
                              title: comicDetail!.follows
                                  .toString(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.start,
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
                                color: isDark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              comicDetail!.authorName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: isDark
                                    ? OkLab(
                                        0.83,
                                        -0.07,
                                        -0.09,
                                      ).toColor()
                                    : OkLab(
                                        0.59,
                                        -0.07,
                                        -0.14,
                                      ).toColor(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColorsDark.background3
                                : AppColorsLight
                                      .background3,
                            borderRadius:
                                BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 10,
                                color: Colors.black26,
                              ),
                            ],
                          ),
                          child: Text(
                            comicDetail!.description,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: isDark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                ChapterModel firstChapter =
                                    chapters![chapters!
                                            .length -
                                        1];
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ReadingScreen(
                                          chapterId:
                                              firstChapter
                                                  .id,
                                          title:
                                              comicDetail!
                                                  .title,
                                          chapterTitle:
                                              firstChapter
                                                  .chapterTitle,
                                          uploaderName:
                                              firstChapter
                                                  .uploaderName,
                                          chapters:
                                              chapters!,
                                          index:
                                              chapters!
                                                  .length -
                                              1,
                                        ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: OkLab(
                                    0.63,
                                    0.24,
                                    0,
                                  ).toColor(),
                                  borderRadius:
                                      BorderRadius.circular(
                                        10,
                                      ),
                                ),
                                padding:
                                    EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,
                                  mainAxisSize:
                                      MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons
                                          .visibility_outlined,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      'Bắt đầu đọc',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight:
                                            FontWeight.bold,
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
                                ChapterModel lastChapter =
                                    chapters![0];
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ReadingScreen(
                                          chapterId:
                                              lastChapter
                                                  .id,
                                          title:
                                              comicDetail!
                                                  .title,
                                          chapterTitle:
                                              lastChapter
                                                  .chapterTitle,
                                          uploaderName:
                                              lastChapter
                                                  .uploaderName,
                                          chapters:
                                              chapters!,
                                          index: 0,
                                        ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: OkLab(
                                    0.55,
                                    0.06,
                                    -0.24,
                                  ).toColor(),
                                  borderRadius:
                                      BorderRadius.circular(
                                        10,
                                      ),
                                ),
                                padding:
                                    EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,
                                  mainAxisSize:
                                      MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons
                                          .auto_awesome_outlined,
                                      size: 18,
                                      color: !isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      'Đọc mới nhất',
                                      style: TextStyle(
                                        color: !isDark
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 14,
                                        fontWeight:
                                            FontWeight.bold,
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
                            color: Color(0xFF231A2F),
                            borderRadius:
                                BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding:
                                      EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                  decoration: BoxDecoration(
                                    color: Color(
                                      0xFFA855F7,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(
                                          24,
                                        ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    children: [
                                      Icon(
                                        Icons
                                            .format_list_bulleted,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(
                                        width: 6,
                                      ),
                                      Text(
                                        'Chapters',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                          color:
                                              Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    children: [
                                      Icon(
                                        Icons
                                            .chat_bubble_outline,
                                        size: 18,
                                        color: Colors.white
                                            .withValues(
                                              alpha: 0.6,
                                            ),
                                      ),
                                      const SizedBox(
                                        width: 6,
                                      ),
                                      Text(
                                        '(5)',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors
                                              .white
                                              .withValues(
                                                alpha: 0.6,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    children: [
                                      Icon(
                                        Icons
                                            .auto_awesome_outlined,
                                        size: 18,
                                        color: Colors.white
                                            .withValues(
                                              alpha: 0.6,
                                            ),
                                      ),
                                      const SizedBox(
                                        width: 6,
                                      ),
                                      Text(
                                        'Liên quan',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors
                                              .white
                                              .withValues(
                                                alpha: 0.6,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius:
                                BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white
                                  .withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  Text(
                                    'Tất cả chapters',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight.bold,
                                      color: Color(
                                        0xFFD69DE5,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            isLoadingChapter =
                                                true;
                                            _fetchChapters();
                                          });
                                        },
                                        icon: Icon(
                                          Icons.sync,
                                          color: Color(
                                            0xFFFF2E7E,
                                          ),
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 16,
                                      ),
                                      IconButton(
                                        onPressed: () {},
                                        icon: Icon(
                                          Icons.sort,
                                          size: 18,
                                          color: Color(
                                            0xFFFF2E7E,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              isLoadingChapter
                                  ? const SizedBox(
                                      height: 300,
                                      child: Center(
                                        child:
                                            CircularProgressIndicator(),
                                      ),
                                    )
                                  : (errorMessageChapter !=
                                        null)
                                  ? SizedBox(
                                      height: 300,
                                      child: Center(
                                        child: Text(
                                          errorMessageChapter!,
                                        ),
                                      ),
                                    )
                                  : chapters!.isEmpty
                                  ? const SizedBox(
                                      height: 150,
                                      child: Center(
                                        child: Text(
                                          'Bộ truyện này chưa có chapter nào.',
                                          style: TextStyle(
                                            color: Colors
                                                .white70,
                                          ),
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount:
                                          chapters!.length,
                                      itemBuilder: (context, index) {
                                        return InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ReadingScreen(
                                                  chapterId:
                                                      chapters![index]
                                                          .id,
                                                  title: comicDetail!
                                                      .title,
                                                  chapterTitle:
                                                      chapters![index]
                                                          .chapterTitle,
                                                  uploaderName:
                                                      chapters![index]
                                                          .uploaderName,
                                                  chapters:
                                                      chapters!,
                                                  index:
                                                      index,
                                                ),
                                              ),
                                            );
                                          },
                                          child: ChapterItem(
                                            chapterTitle:
                                                chapters![index]
                                                    .chapterTitle,
                                            uploaderName:
                                                chapters![index]
                                                    .uploaderName,
                                            publishDate:
                                                chapters![index]
                                                    .publishDate,
                                            isNewest:
                                                index == 0,
                                          ),
                                        );
                                      },
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
