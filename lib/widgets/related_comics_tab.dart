import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:comic_app/theme/app_colors.dart';
import 'package:comic_app/widgets/comic_card.dart';
import 'package:comic_app/models/comic_model.dart';
import 'package:comic_app/models/comic_detail_model.dart';
import 'package:comic_app/api/api_service.dart';
import 'package:comic_app/screens/detail_screen.dart';
import 'package:okcolor/models/oklab.dart';

class RelatedComicsTab extends StatefulWidget {
  final bool isDark;
  final ComicDetailModel comicDetail;

  const RelatedComicsTab({super.key, required this.isDark, required this.comicDetail});

  @override
  State<RelatedComicsTab> createState() => _RelatedComicsTabState();
}

class _RelatedComicsTabState extends State<RelatedComicsTab> {
  bool _isLoading = true;

  List<ComicModel> _seriesComics = [];
  List<ComicModel> _authorComics = [];
  List<ComicModel> _genreComics = [];

  // 3 Controller
  final CarouselSliderController _seriesController = CarouselSliderController();
  final CarouselSliderController _authorController = CarouselSliderController();
  final CarouselSliderController _genreController = CarouselSliderController();

  // 3 Index
  int _seriesIndex = 0;
  int _authorIndex = 0;
  int _genreIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchRelatedData();
  }

  Future<void> _fetchRelatedData() async {
    final detail = widget.comicDetail;

    try {
      final results = await Future.wait([
        ApiService.fetchRelatedComicsByIds(detail.relatedMangaIds, detail.id),
        ApiService.fetchComicsByAuthor(detail.authorId, detail.id),
        ApiService.fetchComicsByTags(detail.tagIds, detail.id),
      ]);

      if (mounted) {
        setState(() {
          _seriesComics = results[0];
          _authorComics = results[1];
          _genreComics = results[2];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator(color: AppColors.secondaryPink)),
      );
    }

    if (_seriesComics.isEmpty && _authorComics.isEmpty && _genreComics.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'Không tìm thấy truyện liên quan nào.',
            style: TextStyle(color: widget.isDark ? Colors.white : Colors.black),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCarouselSection(
          title: '📚 Cùng series / Phần khác',
          comics: _seriesComics,
          currentIndex: _seriesIndex,
          controller: _seriesController,
          onPageChanged: (index) {
            setState(() {
              _seriesIndex = index;
            });
          },
        ),

        if (_seriesComics.isNotEmpty) const SizedBox(height: 30),

        _buildCarouselSection(
          title: '✒️ Cùng tác giả',
          comics: _authorComics,
          currentIndex: _authorIndex,
          controller: _authorController,
          onPageChanged: (index) {
            setState(() {
              _authorIndex = index;
            });
          },
        ),

        if (_authorComics.isNotEmpty) const SizedBox(height: 30),

        _buildCarouselSection(
          title: '✨ Có thể bạn sẽ thích',
          comics: _genreComics,
          currentIndex: _genreIndex,
          controller: _genreController,
          onPageChanged: (index) {
            setState(() {
              _genreIndex = index;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCarouselSection({
    required String title,
    required List<ComicModel> comics,
    required int currentIndex,
    required CarouselSliderController controller,
    required Function(int) onPageChanged,
  }) {
    if (comics.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: widget.isDark ? OkLab(0.83, 0.07, -0.1).toColor() : OkLab(0.5, 0.14, -0.22).toColor(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        CarouselSlider(
          carouselController: controller,
          options: CarouselOptions(
            height: 320,
            viewportFraction: 0.5,
            enableInfiniteScroll: false,
            padEnds: false,
            onPageChanged: (index, reason) {
              onPageChanged(index);
            },
          ),
          items: comics.map((comic) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(id: comic.id)));
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
        const SizedBox(height: 15),
        Center(
          child: AnimatedSmoothIndicator(
            activeIndex: currentIndex,
            count: comics.length,
            effect: ExpandingDotsEffect(
              activeDotColor: AppColors.secondaryPink,
              dotColor: Colors.grey.withValues(alpha: 0.3),
              dotHeight: 6,
              dotWidth: 6,
              expansionFactor: 3,
            ),
            onDotClicked: (index) {
              controller.animateToPage(index);
            },
          ),
        ),
      ],
    );
  }
}
