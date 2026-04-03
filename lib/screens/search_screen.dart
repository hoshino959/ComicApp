import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comic_app/api/api_service.dart';
import 'package:comic_app/api/notify_services.dart';
import 'package:comic_app/models/chapter_model.dart';
import 'package:comic_app/models/comic_model.dart';
import 'package:comic_app/models/genre_model.dart';
import 'package:comic_app/screens/detail_screen.dart';
import 'package:comic_app/theme/app_colors.dart';
import 'package:comic_app/theme/app_dark_colors.dart';
import 'package:comic_app/theme/app_light_colors.dart';
import 'package:comic_app/theme/theme_provider.dart';
import 'package:comic_app/widgets/comic_card.dart';
import 'package:comic_app/widgets/custom_dropdown.dart';
import 'package:comic_app/widgets/genre_tag.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:okcolor/models/oklab.dart';
import 'package:provider/provider.dart';

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
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _searchGenreController = TextEditingController();
  Timer? _debounce;

  List<String> statuses = [];
  String orderBy = 'default';
  String currentSearchValue = '';

  List<GenreModel> allGenres = [];
  List<GenreModel> displayedGenres = [];
  List<String> selectedGenres = [];
  List<String> selectedGenreIds = [];
  bool isLoadingGenre = true;
  bool isFetchedGenres = false;

  String selectedStatus = 'Tất cả';
  final List<String> statusList = [
    'Tất cả',
    'Đang tiến hành',
    'Đã hoàn thành',
    'Tạm ngưng',
    'Đã hủy',
  ];

  String selectedSort = 'Mới cập nhật';
  final List<String> sortList = [
    'Mới cập nhật',
    'Đánh giá cao nhất',
    'Nhiều người theo dõi nhất',
    'Truyện mới đăng',
    'Tên A-Z',
    'Liên quan nhất',
  ];

  String searchByVi = 'Tiêu đề';
  String searchByEn = 'title';
  bool isR18 = false;

  @override
  void initState() {
    super.initState();
    searchComics();
    _initData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
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

  Future<void> _initData() async {
    setState(() {
      isLoading = true;
    });
    await Future.wait([NotifyServices().checkChapterNews()]);
    setState(() {
      isLoading = false;
    });
  }

  void searchComics({bool isLoadMore = false}) async {
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
        currentSearchValue,
        limit: 20,
        offset: currentOffset,
        statuses: statuses,
        orderBy: orderBy,
        includedGenreIds: selectedGenreIds,
        searchBy: searchByEn,
        showR18: isR18,
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
    final isDark =
        Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;

    final gradient = isDark
        ? AppColorsDark.gradientBackground
        : AppColorsLight.gradientBackground;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: showBackToTopButton
          ? FloatingActionButton(
              onPressed: _scrollToTop,
              backgroundColor: AppColors.secondaryPink,
              child: const Icon(Icons.arrow_upward, color: Colors.white),
            )
          : null,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(gradient: gradient),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tìm kiếm truyện',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? OkLab(0.83, 0.07, -0.1).toColor()
                        : OkLab(0.5, 0.14, -0.22).toColor(),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tìm truyện yêu thích tiếp theo của bạn',
                  style: TextStyle(
                    color: isDark
                        ? OkLab(0.71, 0, -0.02).toColor()
                        : OkLab(0.45, -0.01, -0.03).toColor(),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(blurRadius: 5, color: Colors.grey.shade300),
                    ],
                  ),
                  child: TextField(
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    controller: _searchController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? Color(0xFF231A2F) : Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          width: 2,
                          color: isDark
                              ? OkLab(0.46, 0.19, 0.01).toColor()
                              : OkLab(0.9, 0.06, -0.02).toColor(),
                        ),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: OkLab(0.63, 0.24, 0).toColor(),
                          width: 3,
                        ),
                      ),
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Tìm kiếm',
                    ),

                    onChanged: (value) {
                      setState(() {
                        currentSearchValue = value;

                        if (value.trim().isNotEmpty &&
                            (orderBy == 'default' || orderBy == 'updatedAt')) {
                          selectedSort = 'Liên quan nhất';
                          orderBy = 'relevance';
                        } else if (value.trim().isEmpty &&
                            (orderBy == 'default' || orderBy == 'relevance')) {
                          selectedSort = 'Mới cập nhật';
                          orderBy = 'updatedAt';
                        }
                      });

                      if (_debounce?.isActive ?? false) {
                        _debounce!.cancel();
                      }

                      _debounce = Timer(const Duration(milliseconds: 500), () {
                        hasMore = true;
                        searchComics();
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    InkWell(
                      onTap: () => _showFilterModal(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.3)
                                : Colors.black.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.filter_alt_outlined,
                              size: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Bộ lọc',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () => _showConfModal(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.3)
                                : Colors.black.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.settings_outlined,
                              size: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Cấu hình tìm kiếm',
                              style: TextStyle(
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
                const SizedBox(height: 16),
                if (isLoading)
                  Expanded(child: Center(child: CircularProgressIndicator()))
                else if (comics == null || comics!.isEmpty)
                  Expanded(child: Center(child: Text('Không tìm thấy truyện')))
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
                                    DetailScreen(id: comics![index].id),
                              ),
                            ),
                          },
                          child: ComicCard(
                            title: comics![index].title,
                            thumbnailUrl: comics![index].thumbnailUrl,
                            timeAgo: comics![index].timeAgo,
                            newestChapter: comics![index].newestChapter,
                          ),
                        );
                      },
                    ),
                  ),
                ],
                if (isFetchingMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (!hasMore)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(
                      child: Text(
                        'Đã tải hết truyện',
                        style: TextStyle(color: AppColors.textColor),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterModal(BuildContext context) async {
    String tempStatus = selectedStatus;
    String tempSort = selectedSort;

    List<String> tempGenres = List.from(selectedGenres);
    List<String> tempIdGenres = List.from(selectedGenreIds);

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E1528),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.filter_alt_outlined,
                          color: Color(0xFFFF2E7E),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Bộ lọc',
                          style: TextStyle(
                            color: Color(0xFFFF2E7E),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      color: Colors.white.withValues(alpha: 0.1),
                      height: 32,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Thể loại',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Chọn một hoặc nhiều thể loại',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            _showGenreDialog(
                              context,
                              tempGenres,
                              tempIdGenres,
                              (Map<String, List<String>> returnedGenres) {
                                setModalState(() {
                                  tempGenres = returnedGenres['nameGenres']!;
                                  tempIdGenres = returnedGenres['idGenres']!;
                                });
                              },
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                              shape: BoxShape.circle,
                              color: Colors.transparent,
                            ),
                            child: const Icon(Icons.add, size: 18),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (tempGenres.isEmpty)
                      GenreTag(title: 'No categories selected')
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ...tempGenres.take(10).map((genre) {
                            return GenreTag(title: genre);
                          }),

                          if (tempGenres.length > 10)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: const Color(
                                  0xFFFF2E7E,
                                ).withValues(alpha: 0.2),
                                border: Border.all(
                                  color: const Color(0xFFFF2E7E),
                                ),
                              ),
                              child: Text(
                                '+${tempGenres.length - 10}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF2E7E),
                                ),
                              ),
                            ),
                        ],
                      ),
                    Divider(
                      color: Colors.white.withValues(alpha: 0.1),
                      height: 32,
                    ),

                    const Text(
                      'Trạng thái',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    CustomDropdown(
                      value: tempStatus,
                      items: statusList,
                      onChanged: (newValue) {
                        setModalState(() {
                          tempStatus = newValue!;
                        });
                      },
                    ),
                    Divider(
                      color: Colors.white.withValues(alpha: 0.1),
                      height: 32,
                    ),

                    const Text(
                      'Sắp xếp theo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    CustomDropdown(
                      value: tempSort,
                      items: sortList,
                      onChanged: (newValue) {
                        setModalState(() {
                          tempSort = newValue!;
                        });
                      },
                    ),
                    Divider(
                      color: Colors.white.withValues(alpha: 0.1),
                      height: 32,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context, {
                              'status': 'Tất cả',
                              'sort': currentSearchValue.isEmpty
                                  ? 'Mới cập nhật'
                                  : 'Liên quan nhất',
                              'genreNames': [],
                              'genreIds': [],
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Xoá tất cả',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        InkWell(
                          onTap: () {
                            Navigator.pop(context, {
                              'status': tempStatus,
                              'sort': tempSort,
                              'genreNames': tempGenres,
                              'genreIds': tempIdGenres,
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF2E7E),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            child: const Text(
                              'Áp dụng bộ lọc',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        selectedStatus = result['status']!;
        selectedSort = result['sort']!;

        selectedGenres = List<String>.from(result['genreNames']);
        selectedGenreIds = List<String>.from(result['genreIds']);

        if (selectedStatus == 'Tất cả') {
          statuses = [];
        } else if (selectedStatus == 'Đang tiến hành') {
          statuses = ['ongoing'];
        } else if (selectedStatus == 'Đã hoàn thành') {
          statuses = ['completed'];
        } else if (selectedStatus == 'Tạm ngưng') {
          statuses = ['hiatus'];
        } else if (selectedStatus == 'Đã hủy') {
          statuses = ['cancelled'];
        }

        if (selectedSort == 'Mới cập nhật') {
          orderBy = 'updatedAt';
        } else if (selectedSort == 'Đánh giá cao nhất') {
          orderBy = 'rating';
        } else if (selectedSort == 'Nhiều người theo dõi nhất') {
          orderBy = 'followedCount';
        } else if (selectedSort == 'Truyện mới đăng') {
          orderBy = 'createdAt';
        } else if (selectedSort == 'Tên A-Z') {
          orderBy = 'title';
        } else if (selectedSort == 'Liên quan nhất') {
          orderBy = 'relevance';
        }

        hasMore = true;
        searchComics();
      });
    }
  }

  Future<void> _showGenreDialog(
    BuildContext context,
    List<String> currentSelectedName,
    List<String> currentSelectedId,
    Function(Map<String, List<String>>) onConfirm,
  ) async {
    List<String> tempSelectedName = List.from(currentSelectedName);

    List<String> tempSelectedId = List.from(currentSelectedId);

    displayedGenres = List.from(allGenres);
    _searchGenreController.clear();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            if (!isFetchedGenres) {
              isFetchedGenres = true;

              ApiService.fetchAllGenres()
                  .then((result) {
                    setDialogState(() {
                      allGenres = result;
                      displayedGenres = result;
                      isLoadingGenre = false;
                    });
                  })
                  .catchError((e) {
                    setDialogState(() {
                      isLoadingGenre = false;
                    });
                  });
            }
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1528),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Chọn thể loại',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      controller: _searchGenreController,
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
                      onChanged: (query) {
                        setDialogState(() {
                          if (query.isEmpty) {
                            displayedGenres = allGenres;
                          } else {
                            displayedGenres = allGenres.where((genre) {
                              return genre.name.toLowerCase().contains(
                                query.toLowerCase(),
                              );
                            }).toList();
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    if (isLoadingGenre)
                      const SizedBox(
                        height: 300,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (displayedGenres.isEmpty)
                      const SizedBox(
                        height: 300,
                        child: Center(child: Text('Không có thể loại')),
                      )
                    else ...[
                      Expanded(
                        child: ListView.builder(
                          itemCount: displayedGenres.length,
                          itemBuilder: (context, index) {
                            final genre = displayedGenres[index].name;
                            final id = displayedGenres[index].id;
                            final isChecked = tempSelectedName.contains(genre);

                            return CheckboxListTile(
                              title: Text(
                                genre,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                              value: isChecked,
                              activeColor: const Color(0xFFFF2E7E),
                              checkColor: Colors.white,
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                              contentPadding: EdgeInsets.zero,
                              onChanged: (bool? value) {
                                setDialogState(() {
                                  if (value == true) {
                                    tempSelectedName.add(genre);
                                    tempSelectedId.add(id);
                                  } else {
                                    tempSelectedName.remove(genre);
                                    tempSelectedId.remove(id);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Hủy',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF2E7E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    onConfirm({
                      'idGenres': tempSelectedId,
                      'nameGenres': tempSelectedName,
                    });
                  },
                  child: const Text(
                    'Xong',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showConfModal(BuildContext context) async {
    String tempSearchBy = searchByVi;
    bool tempIsR18 = isR18;

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Widget buildRadioOption(String title) {
              bool isSelected = tempSearchBy == title;
              return InkWell(
                onTap: () {
                  setModalState(() {
                    tempSearchBy = title;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFFF2E7E)
                                : Colors.white.withValues(alpha: 0.3),
                            width: isSelected ? 6 : 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        title,
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFFFF2E7E)
                              : Colors.white,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SafeArea(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E1528),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.settings_outlined, color: Color(0xFFFF2E7E)),
                        SizedBox(width: 6),
                        Text(
                          'Cấu hình tìm kiếm',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF2E7E),
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      color: Colors.white.withValues(alpha: 0.1),
                      height: 32,
                    ),

                    const Text(
                      'Tìm kiếm theo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    buildRadioOption('Tiêu đề'),
                    buildRadioOption('Tác giả'),
                    buildRadioOption('Họa sĩ'),

                    Divider(
                      color: Colors.white.withValues(alpha: 0.1),
                      height: 32,
                    ),

                    InkWell(
                      onTap: () {
                        setModalState(() {
                          tempIsR18 = !tempIsR18;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: tempIsR18
                                    ? const Color(0xFFFF2E7E)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: tempIsR18
                                      ? const Color(0xFFFF2E7E)
                                      : Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                              child: tempIsR18
                                  ? const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Hiển thị nội dung R18',
                              style: TextStyle(
                                color: tempIsR18
                                    ? const Color(0xFFFF2E7E)
                                    : Colors.white,
                                fontWeight: tempIsR18
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Divider(
                      color: Colors.white.withValues(alpha: 0.1),
                      height: 32,
                    ),

                    InkWell(
                      onTap: () {
                        Navigator.pop(context, {
                          'searchBy': tempSearchBy,
                          'isR18': tempIsR18,
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF2E7E),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: const Center(
                          child: Text(
                            'Áp dụng',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        searchByVi = result['searchBy'];
        isR18 = result['isR18'];

        if (searchByVi == 'Tiêu đề') {
          searchByEn = 'title';
        } else if (searchByVi == 'Tác giả') {
          searchByEn = 'author';
        } else if (searchByVi == 'Hoạ sĩ') {
          searchByEn = 'artist';
        }

        hasMore = true;
        searchComics();
      });
    }
  }
}
