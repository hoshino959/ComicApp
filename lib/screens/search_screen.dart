import 'dart:async';

import 'package:comic_app/api/api_service.dart';
import 'package:comic_app/models/comic_model.dart';
import 'package:comic_app/screens/detail_screen.dart';
import 'package:comic_app/theme/app_colors.dart';
import 'package:comic_app/widgets/comic_card.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool isLoading = true;
  List<ComicModel>? comics;
  int currentOffset = 0;
  bool isFetchingMore = false;
  bool hasMore = true;
  bool showBackToTopButton = false;
  final ScrollController _scrollController =
      ScrollController();
  final TextEditingController _searchController =
      TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    searchComics();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent -
              200) {
        if (!isFetchingMore && !isLoading && hasMore) {
          searchComics(isLoadMore: true);
        }
      }

      if (_scrollController.offset >= 400) {
        if (!showBackToTopButton) {
          setState(() {
            showBackToTopButton = true;
          });
        }
      } else {
        if (showBackToTopButton) {
          setState(() {
            showBackToTopButton = false;
          });
        }
      }
    });
  }

  void searchComics({
    bool isLoadMore = false,
    String query = '',
  }) async {
    if (isLoadMore) {
      setState(() {
        isFetchingMore = true;
      });
    } else {
      setState(() {
        isLoading = true;
        currentOffset = 0;
      });
    }

    try {
      final result = await ApiService.searchComics(
        query,
        limit: 20,
        offset: currentOffset,
      );

      if (!mounted) return;

      setState(() {
        if (isLoadMore) {
          comics!.addAll(result);
        } else {
          comics = result;
        }

        currentOffset += 20;

        if (result.length < 20) {
          hasMore = false;
        }

        isLoading = false;
        isFetchingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        isFetchingMore = false;
      });
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
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF16151A),
      floatingActionButton: showBackToTopButton
          ? FloatingActionButton(
              onPressed: _scrollToTop,
              backgroundColor: AppColors.secondaryPink,
              child: const Icon(
                Icons.arrow_upward,
                color: Colors.white,
              ),
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tìm kiếm truyện',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD69DE5),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tìm truyện yêu thích tiếp theo của bạn',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFF231A2F),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Tìm kiếm',
                ),
                onChanged: (value) {
                  if (_debounce?.isActive ?? false) {
                    _debounce!.cancel();
                  }
                  _debounce = Timer(
                    const Duration(milliseconds: 500),
                    () {
                      if (value.trim().isNotEmpty) {
                        hasMore = true;
                        searchComics(query: value);
                      } else {
                        hasMore = true;
                        searchComics();
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        20,
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(
                          alpha: 0.3,
                        ),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.filter_alt_outlined,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Bộ lọc',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        20,
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(
                          alpha: 0.3,
                        ),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.settings_outlined,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Cấu hình tìm kiếm',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (isLoading)
                const SizedBox(
                  height: 320,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (comics == null || comics!.isEmpty)
                const SizedBox(
                  height: 320,
                  child: Center(
                    child: Text('Không tìm thấy truyện'),
                  ),
                )
              else ...[
                Expanded(
                  child: GridView.builder(
                    controller: _scrollController,
                    itemCount: comics!.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailScreen(
                                    id: comics![index].id,
                                  ),
                            ),
                          ),
                        },
                        child: ComicCard(
                          title: comics![index].title,
                          thumbnailUrl:
                              comics![index].thumbnailUrl,
                          timeAgo: comics![index].timeAgo,
                          newestChapter:
                              comics![index].newestChapter,
                        ),
                      );
                    },
                  ),
                ),
              ],
              if (isFetchingMore)
                const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 20.0,
                  ),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              if (!hasMore)
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
        ),
      ),
    );
  }
}
