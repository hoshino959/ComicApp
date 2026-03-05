import 'dart:convert';
import 'package:comic_app/models/comic_model';
import 'package:http/http.dart' as http;
// Import file model của bạn vào đây
// import 'package:comic_app/models/comic_model.dart';

class ApiService {
  static const String _baseUrl = 'https://api.mangadex.org';

  /// Lấy danh sách truyện mới cập nhật
  static Future<List<ComicModel>>
  fetchRecentlyUpdatedComics({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      // Endpoint lấy danh sách manga, sắp xếp theo thời gian cập nhật giảm dần
      // BẮT BUỘC: includes[]=cover_art để server trả kèm data của ảnh bìa
      final Uri url = Uri.parse(
        '$_baseUrl/manga'
        '?limit=$limit'
        '&offset=$offset'
        '&includes[]=cover_art'
        '&order[updatedAt]=desc'
        '&hasAvailableChapters=true', // Chỉ lấy truyện đã có chapter
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(
          response.body,
        );
        final List<dynamic> mangaList = data['data'] ?? [];

        return mangaList
            .map((json) => ComicModel.fromJson(json))
            .toList();
      } else {
        // Có thể throw exception hoặc return mảng rỗng tùy logic xử lý lỗi của bạn
        throw Exception(
          'Failed to load comics. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching comics: $e');
      return [];
    }
  }
}
