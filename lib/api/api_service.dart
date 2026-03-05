import 'dart:convert';
import 'package:comic_app/models/comic_model';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://api.mangadex.org';

  static Future<List<ComicModel>>
  fetchRecentlyUpdatedComics({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final Uri url = Uri.parse(
        '$_baseUrl/manga'
        '?limit=$limit'
        '&offset=$offset'
        '&includes[]=cover_art'
        '&order[updatedAt]=desc'
        '&hasAvailableChapters=true',
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
        throw Exception(
          'Failed to load comics. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      return [];
    }
  }
}
