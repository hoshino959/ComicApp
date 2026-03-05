import 'package:comic_app/api/api_service.dart';
import 'package:comic_app/models/comic_model';
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
  int _currentIndex = 0;
  bool _isLoading = true; // Thêm trạng thái loading

  final CarouselSliderController _carouselController =
      CarouselSliderController();

  List<ComicModel>? comics;

  @override
  void initState() {
    fetchComics();
    super.initState();
  }

  void fetchComics() async {
    try {
      final result = await ApiService.fetchRecentlyUpdatedComics();
      if (!mounted) return;
      setState(() {
        comics = result;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error fetching comics: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.fromLTRB(15, 8, 0, 8),
          child: ClipOval(
            child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
          ),
        ),
        title: Text('Comic Garden'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              'https://scontent.fsgn5-5.fna.fbcdn.net/v/t39.30808-6/623426145_1407740497394126_4920768692675398143_n.jpg?_nc_cat=108&ccb=1-7&_nc_sid=b895b5&_nc_ohc=N2Jbt0WABU8Q7kNvwHwX_S9&_nc_oc=Admwok3cU2hnrTA2093NgoxUURapScRx0I3bgLje-kH87IFSdWMSNQeHfvF3DIVsjdw&_nc_zt=23&_nc_ht=scontent.fsgn5-5.fna&_nc_gid=TLKuWd02XB_1R9tUnCPDaQ&_nc_ss=8&oh=00_AfyPmpx3AWj9A3YcsEeTpUPWPA4UmKpOSsdCmXjq_vG9xA&oe=69AEBD21',
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
                    '◈ Truyện mới nhất ◈',
                    style: TextStyle(
                      color: AppColors.secondaryPink,
                      fontSize: 25,
                    ),
                  ),
                ),
                // Xử lý hiển thị UI dựa theo trạng thái dữ liệu
                if (_isLoading)
                  const SizedBox(
                    height: 320,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (comics == null || comics!.isEmpty)
                  const SizedBox(
                    height: 320,
                    child: Center(child: Text('Không có dữ liệu')),
                  )
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
                      items: comics!.map((comic) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ComicCard(
                            thumbnailUrl: comic.thumbnailUrl,
                            title: comic.title,
                            timeAgo: comic.timeAgo,
                            newestChapter: comic.newestChapter,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Center(
                    child: AnimatedSmoothIndicator(
                      activeIndex: _currentIndex,
                      count: comics!.length,
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
