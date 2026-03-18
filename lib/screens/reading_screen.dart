import 'package:cached_network_image/cached_network_image.dart';
import 'package:comic_app/api/api_service.dart';
import 'package:comic_app/models/chapter_model.dart';
import 'package:comic_app/models/chapter_page_model.dart';
import 'package:comic_app/models/reading_comic.dart';
import 'package:flutter/material.dart';

class ReadingScreen extends StatefulWidget {
  final String chapterId;
  final String title;
  final String chapterTitle;
  final String uploaderName;
  final List<ChapterModel> chapters;
  final int index;
  final String comicId;
  final String coverUrl;
  final String status;

  const ReadingScreen({
    super.key,
    required this.chapterId,
    required this.title,
    required this.chapterTitle,
    required this.uploaderName,
    required this.chapters,
    required this.index,
    required this.comicId,
    required this.coverUrl,
    required this.status,
  });

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  ChapterPagesModel? chapterPages;
  bool isLoading = true;
  String? errorMessage;

  String? currentChapterId;
  int? currentIndex;
  String? currentChapterTitle;
  String? currentUploaderName;

  @override
  void initState() {
    super.initState();
    currentChapterId = widget.chapterId;
    currentIndex = widget.index;
    currentChapterTitle = widget.chapterTitle;
    currentUploaderName = widget.uploaderName;
    _fetchData();
  }

  void _fetchData() async {
    try {
      final result = await ApiService.fetchChapterPages(currentChapterId!);
      if (!mounted) return;
      setState(() {
        chapterPages = result;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF16151A),
      appBar: AppBar(
        backgroundColor: Color(0xFF1E1528),
        elevation: 0,
        leadingWidth: 100,
        leading: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.home_outlined,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.settings_outlined,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.outlined_flag, color: Color(0xFFFBBF24)),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.bookmark_border, color: Color(0xFF60A5FA)),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 80,
          decoration: BoxDecoration(color: Color(0xFF16151A)),
          padding: EdgeInsets.symmetric(vertical: 13, horizontal: 5),
          child: Row(
            children: [
              IconButton(
                onPressed: currentIndex! < widget.chapters.length - 1
                    ? () {
                        setState(() {
                          currentIndex = currentIndex! + 1;
                          currentChapterId = widget.chapters[currentIndex!].id;
                          isLoading = true;
                          _fetchData();
                          currentChapterTitle =
                              widget.chapters[currentIndex!].chapterTitle;
                          currentUploaderName =
                              widget.chapters[currentIndex!].uploaderName;
                        });
                      }
                    : null,
                icon: Icon(
                  Icons.keyboard_arrow_left,
                  color: currentIndex! < widget.chapters.length - 1
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Color(0xFFFF2E7E), width: 1.5),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            currentChapterTitle!,
                            style: TextStyle(color: Colors.white, fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              IconButton(
                onPressed: currentIndex! > 0
                    ? () async {
                        setState(() {
                          currentIndex = currentIndex! - 1;
                          currentChapterId = widget.chapters[currentIndex!].id;
                          isLoading = true;
                          _fetchData();
                          currentChapterTitle =
                              widget.chapters[currentIndex!].chapterTitle;
                          currentUploaderName =
                              widget.chapters[currentIndex!].uploaderName;
                        });
                        await ReadingComic.saveProgress(
                          comicId: widget.comicId,
                          comicTitle: widget.title,
                          coverUrl: widget.coverUrl,
                          chapterId: widget.chapters[currentIndex!].id,
                          chapterTitle:
                              widget.chapters[currentIndex!].chapterTitle,
                          chapterIndex: widget.chapters.length - currentIndex!,
                          totalChapters: widget.chapters.length,
                          status: widget.status,
                        );
                      }
                    : null,
                icon: Icon(
                  Icons.keyboard_arrow_right,
                  color: currentIndex! > 0
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? SizedBox(
              height: 700,
              child: Center(child: CircularProgressIndicator()),
            )
          : (errorMessage != null)
          ? SizedBox(height: 700, child: Center(child: Text(errorMessage!)))
          : ListView.builder(
              itemCount: chapterPages!.imageUrls.length + 1,
              itemBuilder: (context, index) {
                return index == 0
                    ? Container(
                        margin: EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: Color(0xFF231A2F),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.fromLTRB(16, 5, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.title,
                                    style: TextStyle(color: Colors.white),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isLoading = true;
                                      _fetchData();
                                    });
                                  },
                                  icon: Icon(
                                    Icons.sync,
                                    size: 20,
                                    color: Color(0xFFFF2E7E),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              currentChapterTitle!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: Color.fromARGB(255, 173, 78, 197),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    currentUploaderName!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color.fromARGB(255, 235, 177, 212),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${chapterPages!.totalPages} trang',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : CachedNetworkImage(
                        imageUrl: chapterPages!.imageUrls[index - 1],
                        fit: BoxFit.fitWidth,
                        placeholder: (context, url) => SizedBox(
                          height: 400,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFFF2E7E),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 400,
                          color: Color(0xFF231A2F),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  color: Colors.white54,
                                  size: 40,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Lỗi hoặc link ảnh đã hết hạn',
                                  style: TextStyle(color: Colors.white54),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
              },
            ),
    );
  }
}
