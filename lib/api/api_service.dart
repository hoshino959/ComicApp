import 'dart:convert';
import 'package:comic_app/models/chapter_model.dart';
import 'package:comic_app/models/chapter_page_model.dart';
import 'package:comic_app/models/comic_detail_model.dart';
import 'package:comic_app/models/comic_model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://api.mangadex.org';

  static Future<List<ComicModel>>
  fetchRecentlyUpdatedComics({
    int limit = 20,
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

  static Future<List<ComicModel>>
  fetchRandomComicsFromList() async {
    try {
      final Uri url = Uri.parse(
        '$_baseUrl/manga'
        '?limit=100'
        '&offset=0'
        '&includes[]=cover_art'
        '&hasAvailableChapters=true',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(
          response.body,
        );
        final List<dynamic> mangaList = data['data'] ?? [];

        List<ComicModel> comics = mangaList
            .map((json) => ComicModel.fromJson(json))
            .toList();

        comics.shuffle();

        return comics.take(10).toList();
      } else {
        throw Exception('Failed to load random comics');
      }
    } catch (e) {
      return [];
    }
  }

  static Future<ComicDetailModel?> fetchComicDetail(
    String id,
  ) async {
    try {
      final Uri mangaUrl = Uri.parse(
        '$_baseUrl/manga/$id'
        '?includes[]=author'
        '&includes[]=artist'
        '&includes[]=cover_art',
      );

      final mangaResponse = await http.get(mangaUrl);

      if (mangaResponse.statusCode == 200) {
        final Map<String, dynamic> mangaData = json.decode(
          mangaResponse.body,
        );
        final mangaJson = mangaData['data'];

        final Uri statsUrl = Uri.parse(
          '$_baseUrl/statistics/manga/$id',
        );
        final statsResponse = await http.get(statsUrl);

        Map<String, dynamic>? statsJson;
        if (statsResponse.statusCode == 200) {
          final Map<String, dynamic> statsData = json
              .decode(statsResponse.body);
          statsJson = statsData['statistics'];
        }

        return ComicDetailModel.fromJson(
          mangaJson,
          statsJson,
        );
      } else {
        throw Exception(
          'Failed to load comic details. Status Code: ${mangaResponse.statusCode}',
        );
      }
    } catch (e) {
      return null;
    }
  }

  static Future<List<ChapterModel>> fetchComicChapters(
    String mangaId, {
    int limit = 100,
    int offset = 0,
    String language = 'en',
  }) async {
    try {
      final Uri url = Uri.parse(
        '$_baseUrl/manga/$mangaId/feed'
        '?limit=$limit'
        '&offset=$offset'
        '&translatedLanguage[]=$language'
        '&includes[]=scanlation_group'
        '&includes[]=user'
        '&order[chapter]=desc',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(
          response.body,
        );
        final List<dynamic> chapterList =
            data['data'] ?? [];

        return chapterList
            .map((json) => ChapterModel.fromJson(json))
            .toList();
      } else {
        throw Exception(
          'Failed to load chapters. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      return [];
    }
  }

  static Future<ChapterPagesModel?> fetchChapterPages(
    String chapterId, {
    bool useDataSaver = false,
  }) async {
    try {
      final Uri url = Uri.parse(
        '$_baseUrl/at-home/server/$chapterId',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(
          response.body,
        );

        return ChapterPagesModel.fromJson(
          data,
          useDataSaver: useDataSaver,
        );
      } else {
        throw Exception(
          'Failed to load chapter images. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      return null;
    }
  }
}
