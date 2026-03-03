import 'package:comic_app/theme/app_colors.dart';
import 'package:comic_app/widgets/comic_card.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> imgList = [
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTNzf3PVejSbptxE9nbN5Ck0Zow95zjzbQihQ&s',
  ];

  int _currentIndex = 0;

  final CarouselSliderController _carouselController =
      CarouselSliderController();

  final List<int> _dummyList = [1, 2, 3, 4, 5];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.fromLTRB(15, 8, 0, 8),
          child: Image.network(
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTnYT0cIjOVWd50zJP4yav9d0Uko3kS1f1-fQ&s',
          ),
        ),
        title: Text(
          'YURINEKO',
          style: TextStyle(letterSpacing: 3),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 150,
              autoPlay: true,
              enlargeCenterPage: true,
              viewportFraction: 1,
            ),
            items: imgList
                .map(
                  (item) => Image.network(
                    item,
                    fit: BoxFit.cover,
                    width: 1000,
                  ),
                )
                .toList(),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 20,
                ),
                child: Text(
                  '◈ Random Yuri ◈',
                  style: TextStyle(
                    color: AppColors.secondaryPink,
                    fontSize: 25,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
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
                  items: _dummyList.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                      ),
                      child: ComicCard(
                        thumbnailUrl:
                            'https://m.media-amazon.com/images/I/81fHjBbiTJL._AC_UF894,1000_QL80_.jpg',
                        title: 'Opapagoto',
                        timeAgo: '6 ngày trước',
                        newestChapter:
                            'Chương 2: Màn ra mắt',
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 15),
              Center(
                child: AnimatedSmoothIndicator(
                  activeIndex: _currentIndex,
                  count: _dummyList.length,
                  effect: ExpandingDotsEffect(
                    activeDotColor: AppColors.secondaryPink,
                    dotColor: Colors.grey.withValues(
                      alpha: 0.3,
                    ),
                    dotHeight: 6,
                    dotWidth: 6,
                    expansionFactor: 3,
                  ),
                  onDotClicked: (index) {
                    _carouselController.animateToPage(
                      index,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
