import 'dart:convert';
import 'package:comic_app/models/chapter_model.dart';
import 'package:comic_app/models/chapter_page_model.dart';
import 'package:comic_app/models/comic_detail_model.dart';
import 'package:comic_app/models/comic_model.dart';
import 'package:comic_app/models/genre_model.dart';
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

  static Future<List<ChapterModel>> fetchAllComicChapters(
    String mangaId, {
    String language = 'en',
  }) async {
    List<ChapterModel> allChapters = [];
    int limit = 500;
    int offset = 0;
    int total = 1;

    try {
      while (offset < total) {
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

          total = data['total'] ?? 0;

          final List<dynamic> chapterList =
              data['data'] ?? [];

          allChapters.addAll(
            chapterList
                .map((json) => ChapterModel.fromJson(json))
                .toList(),
          );

          offset += limit;

          if (offset < total) {
            await Future.delayed(
              const Duration(milliseconds: 300),
            );
          }
        } else {
          throw Exception(
            'Failed to load chapters. Status Code: ${response.statusCode}',
          );
        }
      }

      return allChapters;
    } catch (e) {
      return allChapters;
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

  static Future<List<ComicModel>> searchComics(
    String query, {
    int limit = 20,
    int offset = 0,
    List<String>? statuses,
    String? orderBy,
    List<String>? includedGenreIds,
    String searchBy = 'title',
    bool showR18 = false,
  }) async {
    try {
      bool hasNoFilters =
          query.trim().isEmpty &&
          (statuses == null || statuses.isEmpty) &&
          (includedGenreIds == null ||
              includedGenreIds.isEmpty) &&
          !showR18;

      if (hasNoFilters) {
        return await fetchRecentlyUpdatedComics(
          limit: limit,
          offset: offset,
        );
      }

      String urlString =
          '$_baseUrl/manga'
          '?limit=$limit'
          '&offset=$offset'
          '&includes[]=cover_art'
          '&hasAvailableChapters=true';

      if (query.trim().isNotEmpty) {
        if (searchBy == 'author' || searchBy == 'artist') {
          String? personId = await _getAuthorOrArtistId(
            query.trim(),
          );

          if (personId == null) {
            return [];
          }

          if (searchBy == 'author') {
            urlString += '&authors[]=$personId';
          } else {
            urlString += '&artists[]=$personId';
          }
        } else {
          urlString +=
              '&title=${Uri.encodeComponent(query.trim())}';
        }
      }

      urlString +=
          '&contentRating[]=safe&contentRating[]=suggestive&contentRating[]=erotica';
      if (showR18) {
        urlString += '&contentRating[]=pornographic';
      }

      if (statuses != null && statuses.isNotEmpty) {
        for (String status in statuses) {
          urlString += '&status[]=$status';
        }
      }

      if (includedGenreIds != null &&
          includedGenreIds.isNotEmpty) {
        for (String tagId in includedGenreIds) {
          urlString += '&includedTags[]=$tagId';
        }
      }

      String sortQuery = '';
      switch (orderBy) {
        case 'updatedAt':
          sortQuery = '&order[updatedAt]=desc';
          break;
        case 'rating':
          sortQuery = '&order[rating]=desc';
          break;
        case 'followedCount':
          sortQuery = '&order[followedCount]=desc';
          break;
        case 'createdAt':
          sortQuery = '&order[createdAt]=desc';
          break;
        case 'title':
          sortQuery = '&order[title]=asc';
          break;
        case 'relevance':
          sortQuery = '&order[relevance]=desc';
          break;
        default:
          sortQuery = query.trim().isNotEmpty
              ? '&order[relevance]=desc'
              : '&order[updatedAt]=desc';
      }
      urlString += sortQuery;

      final Uri url = Uri.parse(urlString);
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
          'Failed to search comics. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      return [];
    }
  }

  static Future<List<GenreModel>> fetchAllGenres() async {
    try {
      final Uri url = Uri.parse('$_baseUrl/manga/tag');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(
          response.body,
        );
        final List<dynamic> tagList = data['data'] ?? [];

        List<GenreModel> genres = tagList
            .map((json) => GenreModel.fromJson(json))
            .toList();

        genres.sort((a, b) => a.name.compareTo(b.name));

        return genres;
      } else {
        throw Exception(
          'Failed to load genres. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      return [];
    }
  }

  static Future<String?> _getAuthorOrArtistId(
    String name,
  ) async {
    try {
      final Uri url = Uri.parse(
        '$_baseUrl/author?name=${Uri.encodeComponent(name)}&limit=1',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(
          response.body,
        );
        final List<dynamic> results = data['data'] ?? [];

        if (results.isNotEmpty) {
          return results[0]['id'];
        }
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
