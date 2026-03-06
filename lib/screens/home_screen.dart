import 'package:comic_app/api/api_service.dart';
import 'package:comic_app/models/comic_model.dart';
import 'package:comic_app/theme/app_colors.dart';
import 'package:comic_app/theme/app_dark_colors.dart';
import 'package:comic_app/theme/app_light_colors.dart';
import 'package:comic_app/theme/theme_provider.dart';
import 'package:comic_app/widgets/comic_card.dart';
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

  final CarouselSliderController _carouselController =
      CarouselSliderController();

  List<ComicModel>? randomComics;
  List<ComicModel>? newestComics;

  final ScrollController _scrollController =
      ScrollController();
  int _currentOffset = 0;
  bool _isFetchingMore = false;
  bool _hasMore = true;

  bool _showBackToTopButton = false;

  @override
  void initState() {
    super.initState();
    fetchRandomComics();
    fetchNewestComics();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent -
              200) {
        if (!_isFetchingMore &&
            !_isLoadingNewest &&
            _hasMore) {
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

  void fetchRandomComics() async {
    try {
      final result =
          await ApiService.fetchRandomComicsFromList();
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

  void fetchNewestComics({bool isLoadMore = false}) async {
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
      final result =
          await ApiService.fetchRecentlyUpdatedComics(
            limit: 20,
            offset: _currentOffset,
          );

      if (!mounted) return;

      setState(() {
        if (isLoadMore) {
          newestComics!.addAll(result);
        } else {
          newestComics = result;
        }

        _currentOffset += 10;

        if (result.length < 10) {
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
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final darkMode =
        Provider.of<ThemeProvider>(context).themeMode ==
        ThemeMode.dark;

    final gradient = darkMode
        ? AppColorsDark.gradientBackground
        : AppColorsLight.gradientBackground;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.fromLTRB(15, 8, 0, 8),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          title: ShaderMask(
            shaderCallback: (boudns) => LinearGradient(
              colors: darkMode
                  ? [Color(0xffec4899), Color(0xff93339a)]
                  : [Color(0xFFEC4899), Color(0xFF9333EA)],
            ).createShader(boudns),
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                'Comic Garden',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Brush_Script_MT_Italic',
                ),
              ),
            ),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(gradient: gradient),
          ),
        ),
        floatingActionButton: _showBackToTopButton
            ? FloatingActionButton(
                onPressed: _scrollToTop,
                backgroundColor: AppColors.secondaryPink,
                child: const Icon(
                  Icons.arrow_upward,
                  color: Colors.white,
                ),
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
                      ? 'https://scontent.fsgn5-5.fna.fbcdn.net/v/t39.30808-6/623426145_1407740497394126_4920768692675398143_n.jpg?_nc_cat=108&ccb=1-7&_nc_sid=b895b5&_nc_ohc=N2Jbt0WABU8Q7kNvwHwX_S9&_nc_oc=Admwok3cU2hnrTA2093NgoxUURapScRx0I3bgLje-kH87IFSdWMSNQeHfvF3DIVsjdw&_nc_zt=23&_nc_ht=scontent.fsgn5-5.fna&_nc_gid=TLKuWd02XB_1R9tUnCPDaQ&_nc_ss=8&oh=00_AfyPmpx3AWj9A3YcsEeTpUPWPA4UmKpOSsdCmXjq_vG9xA&oe=69AEBD21'
                      : 'https://scontent.fsgn5-10.fna.fbcdn.net/v/t39.30808-6/640581554_1426507742184068_2348786958898076064_n.png?stp=dst-jpg_tt6&_nc_cat=106&ccb=1-7&_nc_sid=25d718&_nc_ohc=deyjMKOGcDkQ7kNvwFjrEBo&_nc_oc=Adl6-OD-UqmucQ2mOdCqsvS_BDmwpf9vYcZedBfaO9QivS2iahKg3uOGzL9MpD_bSwA&_nc_zt=23&_nc_ht=scontent.fsgn5-10.fna&_nc_gid=eFA8QgjnZWBh4FuovzXGOg&_nc_ss=8&oh=00_AfwQ6y1EFrxAlIHJufBWxscg0yhifyOhn0q9Zs8AlnWeRA&oe=69B07254',
                ),
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 20,
                      ),
                      child: Text(
                        '◈ Truyện có thể bạn thích ◈',
                        style: TextStyle(
                          color: AppColors.secondaryPink,
                          fontSize: 25,
                        ),
                      ),
                    ),
                    if (_isLoadingRandom)
                      const SizedBox(
                        height: 320,
                        child: Center(
                          child:
                              CircularProgressIndicator(),
                        ),
                      )
                    else if (randomComics == null ||
                        randomComics!.isEmpty)
                      const SizedBox(
                        height: 320,
                        child: Center(
                          child: Text('Không có dữ liệu'),
                        ),
                      )
                    else ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        child: CarouselSlider(
                          carouselController:
                              _carouselController,
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
                              padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                              child: ComicCard(
                                thumbnailUrl:
                                    comic.thumbnailUrl,
                                title: comic.title,
                                timeAgo: comic.timeAgo,
                                newestChapter:
                                    comic.newestChapter,
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
                            activeDotColor:
                                AppColors.secondaryPink,
                            dotColor: Colors.grey
                                .withValues(alpha: 0.3),
                            dotHeight: 6,
                            dotWidth: 6,
                            expansionFactor: 3,
                          ),
                          onDotClicked: (index) {
                            _carouselController
                                .animateToPage(index);
                          },
                        ),
                      ),
                    ],
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 20,
                      ),
                      child: Text(
                        '◈ Truyện mới nhất ◈',
                        style: TextStyle(
                          color: AppColors.secondaryPink,
                          fontSize: 25,
                        ),
                      ),
                    ),
                    if (_isLoadingNewest)
                      const SizedBox(
                        height: 320,
                        child: Center(
                          child:
                              CircularProgressIndicator(),
                        ),
                      )
                    else if (newestComics == null ||
                        newestComics!.isEmpty)
                      const SizedBox(
                        height: 320,
                        child: Center(
                          child: Text('Không có dữ liệu'),
                        ),
                      )
                    else ...[
                      GridView.builder(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        itemCount: newestComics!.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              mainAxisExtent: 320,
                            ),
                        itemBuilder: (context, index) {
                          return ComicCard(
                            title:
                                newestComics![index].title,
                            thumbnailUrl:
                                newestComics![index]
                                    .thumbnailUrl,
                            timeAgo: newestComics![index]
                                .timeAgo,
                            newestChapter:
                                newestComics![index]
                                    .newestChapter,
                          );
                        },
                      ),
                    ],
                    if (_isFetchingMore)
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 20.0,
                        ),
                        child: Center(
                          child:
                              CircularProgressIndicator(),
                        ),
                      ),
                    if (!_hasMore)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20.0,
                        ),
                        child: Center(
                          child: Text(
                            'Đã tải hết truyện',
                            style: TextStyle(
                              color: AppColors.textColor,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
