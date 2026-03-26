import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comic_app/api/api_service.dart';
import 'package:comic_app/models/chapter_model.dart';
import 'package:comic_app/models/comic_model.dart';
import 'package:comic_app/screens/detail_screen.dart';
import 'package:comic_app/theme/app_colors.dart';
import 'package:comic_app/theme/app_dark_colors.dart';
import 'package:comic_app/theme/app_light_colors.dart';
import 'package:comic_app/theme/theme_provider.dart';
import 'package:comic_app/widgets/comic_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isLoadingRandom = true;
  bool _isLoadingNewest = true;

  final CarouselSliderController _carouselController = CarouselSliderController();

  List<ComicModel>? randomComics;
  List<ComicModel>? newestComics;

  final ScrollController _scrollController = ScrollController();
  int _currentOffset = 0;
  bool _isFetchingMore = false;
  bool _hasMore = true;
  bool isLoading = false;

  bool _showBackToTopButton = false;

  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _initData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        if (!_isFetchingMore && !_isLoadingNewest && _hasMore) {
          fetchNewestComics(isLoadMore: true);
        }
      }

      if (_scrollController.offset >= 400) {
        if (!_showBackToTopButton) {
          setState(() {
            _showBackToTopButton = true;
          });
        }
      } else {
        if (_showBackToTopButton) {
          setState(() {
            _showBackToTopButton = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    setState(() {
      isLoading = true;
    });
    await Future.wait([checkChapterNews(), fetchRandomComics(), fetchNewestComics()]);
    setState(() {
      isLoading = false;
    });
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

  Future<void> fetchRandomComics() async {
    try {
      final result = await ApiService.fetchRandomComicsFromList();
      if (!mounted) return;
      setState(() {
        randomComics = result;
        _isLoadingRandom = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingRandom = false;
      });
      debugPrint('Error fetching comics: $e');
    }
  }

  Future<void> fetchNewestComics({bool isLoadMore = false}) async {
    if (isLoadMore) {
      setState(() {
        _isFetchingMore = true;
      });
    } else {
      setState(() {
        _isLoadingNewest = true;
        _currentOffset = 0;
      });
    }

    try {
      final result = await ApiService.fetchRecentlyUpdatedComics(limit: 20, offset: _currentOffset);

      if (!mounted) return;

      setState(() {
        if (isLoadMore) {
          newestComics!.addAll(result);
        } else {
          newestComics = result;
        }

        _currentOffset += 20;

        if (result.length < 20) {
          _hasMore = false;
        }

        _isLoadingNewest = false;
        _isFetchingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingNewest = false;
        _isFetchingMore = false;
      });
      debugPrint('Error fetching comics: $e');
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;

    final gradient = darkMode ? AppColorsDark.gradientBackground : AppColorsLight.gradientBackground;

    return Stack(
      children: [
        SafeArea(
          child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.fromLTRB(15, 8, 0, 8),
                child: ClipOval(child: Image.asset('assets/images/logo.png', fit: BoxFit.cover)),
              ),
              title: ShaderMask(
                shaderCallback: (boudns) => LinearGradient(
                  colors: darkMode ? [Color(0xffec4899), Color(0xff93339a)] : [Color(0xFFEC4899), Color(0xFF9333EA)],
                ).createShader(boudns),
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    'Comic Garden',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, fontFamily: 'Brush_Script_MT_Italic'),
                  ),
                ),
              ),
              flexibleSpace: Container(decoration: BoxDecoration(gradient: gradient)),
            ),
            floatingActionButton: _showBackToTopButton
                ? FloatingActionButton(
                    onPressed: _scrollToTop,
                    backgroundColor: AppColors.secondaryPink,
                    child: const Icon(Icons.arrow_upward, color: Colors.white),
                  )
                : null,
            body: Container(
              decoration: BoxDecoration(gradient: gradient),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      !darkMode
                          ? 'https://res.cloudinary.com/dxbtuad7u/image/upload/v1773077544/light_bg_e1z6ud.jpg'
                          : 'https://res.cloudinary.com/dxbtuad7u/image/upload/v1773077520/dark_bg_dwxatc.jpg',
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                          child: Text(
                            '◈ Truyện có thể bạn thích ◈',
                            style: TextStyle(color: AppColors.secondaryPink, fontSize: 25),
                          ),
                        ),
                        if (_isLoadingRandom)
                          const SizedBox(height: 320, child: Center(child: CircularProgressIndicator()))
                        else if (randomComics == null || randomComics!.isEmpty)
                          const SizedBox(height: 320, child: Center(child: Text('Không có dữ liệu')))
                        else ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: CarouselSlider(
                              carouselController: _carouselController,
                              options: CarouselOptions(
                                height: 320,
                                viewportFraction: 0.5,
                                enableInfiniteScroll: false,
                                padEnds: false,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    _currentIndex = index;
                                  });
                                },
                              ),
                              items: randomComics!.map((comic) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: InkWell(
                                    onTap: () => {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => DetailScreen(id: comic.id)),
                                      ),
                                    },
                                    child: ComicCard(
                                      thumbnailUrl: comic.thumbnailUrl,
                                      title: comic.title,
                                      timeAgo: comic.timeAgo,
                                      newestChapter: comic.newestChapter,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Center(
                            child: AnimatedSmoothIndicator(
                              activeIndex: _currentIndex,
                              count: randomComics!.length,
                              effect: ExpandingDotsEffect(
                                activeDotColor: AppColors.secondaryPink,
                                dotColor: Colors.grey.withValues(alpha: 0.3),
                                dotHeight: 6,
                                dotWidth: 6,
                                expansionFactor: 3,
                              ),
                              onDotClicked: (index) {
                                _carouselController.animateToPage(index);
                              },
                            ),
                          ),
                        ],
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                          child: Text(
                            '◈ Truyện mới nhất ◈',
                            style: TextStyle(color: AppColors.secondaryPink, fontSize: 25),
                          ),
                        ),
                        if (_isLoadingNewest)
                          const SizedBox(height: 320, child: Center(child: CircularProgressIndicator()))
                        else if (newestComics == null || newestComics!.isEmpty)
                          const SizedBox(height: 320, child: Center(child: Text('Không có dữ liệu')))
                        else ...[
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: newestComics!.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              mainAxisExtent: 320,
                            ),
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () => {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => DetailScreen(id: newestComics![index].id)),
                                  ),
                                },
                                child: ComicCard(
                                  title: newestComics![index].title,
                                  thumbnailUrl: newestComics![index].thumbnailUrl,
                                  timeAgo: newestComics![index].timeAgo,
                                  newestChapter: newestComics![index].newestChapter,
                                ),
                              );
                            },
                          ),
                        ],
                        if (_isFetchingMore)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        if (!_hasMore)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Center(
                              child: Text('Đã tải hết truyện', style: TextStyle(color: AppColors.textColor)),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
