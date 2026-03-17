class ComicDetailModel {
  final String id;
  final String title;
  final String altTitle;
  final String coverUrl;
  final List<String> genres;
  final String status;
  final String publishYear;
  final String authorName;
  final String description;
  final int follows;
  final String views;

  ComicDetailModel({
    required this.id,
    required this.title,
    required this.altTitle,
    required this.coverUrl,
    required this.genres,
    required this.status,
    required this.publishYear,
    required this.authorName,
    required this.description,
    required this.follows,
    required this.views,
  });

  factory ComicDetailModel.fromJson(
    Map<String, dynamic> json,
    Map<String, dynamic>? statsJson,
  ) {
    final attributes = json['attributes'] ?? {};
    final id = json['id'] ?? '';

    String parsedTitle = 'Đang cập nhật';
    if (attributes['title'] != null &&
        attributes['title'].isNotEmpty) {
      parsedTitle =
          attributes['title']['vi'] ??
          attributes['title']['en'] ??
          attributes['title'].values.first.toString();
    }

    String parsedAltTitle = 'Không có tên thay thế';
    final altTitles =
        attributes['altTitles'] as List<dynamic>? ?? [];
    if (altTitles.isNotEmpty) {
      for (var alt in altTitles) {
        if (alt['vi'] != null) {
          parsedAltTitle = alt['vi'];
          break;
        } else if (alt['en'] != null &&
            parsedAltTitle.isEmpty) {
          parsedAltTitle = alt['en'];
        } else if (alt['ja-ro'] != null &&
            parsedAltTitle.isEmpty) {
          parsedAltTitle = alt['ja-ro'];
        }
      }

      if (parsedAltTitle.isEmpty) {
        parsedAltTitle = altTitles.first.values.first
            .toString();
      }
    }

    String parsedDescription = 'Không có nội dung mô tả.';
    if (attributes['description'] != null &&
        attributes['description'].isNotEmpty) {
      parsedDescription =
          attributes['description']['vi'] ??
          attributes['description']['en'] ??
          attributes['description'].values.first.toString();
    }

    List<String> parsedGenres = [];
    final tags = attributes['tags'] as List<dynamic>? ?? [];
    for (var tag in tags) {
      final tagAttributes = tag['attributes'];
      if (tagAttributes != null &&
          tagAttributes['name'] != null) {
        parsedGenres.add(
          tagAttributes['name']['vi'] ??
              tagAttributes['name']['en'] ??
              '',
        );
      }
    }

    String parsedStatus = attributes['status'] ?? 'unknown';
    String parsedYear =
        attributes['year']?.toString() ?? 'N/A';
    if (parsedYear == 'N/A' &&
        attributes['createdAt'] != null) {
      DateTime createdAt = DateTime.parse(
        attributes['createdAt'],
      ).toLocal();
      parsedYear =
          '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }

    String parsedAuthor = 'Đang cập nhật';
    String coverFileName = '';
    final relationships =
        json['relationships'] as List<dynamic>? ?? [];

    for (var rel in relationships) {
      if (rel['type'] == 'author' &&
          rel['attributes'] != null) {
        parsedAuthor =
            rel['attributes']['name'] ?? parsedAuthor;
      }
      if (rel['type'] == 'cover_art' &&
          rel['attributes'] != null) {
        coverFileName = rel['attributes']['fileName'] ?? '';
      }
    }

    String parsedCoverUrl = coverFileName.isNotEmpty
        ? 'https://uploads.mangadex.org/covers/$id/$coverFileName'
        : 'https://mangadex.org/img/avatar.png';

    int parsedFollows = 0;
    if (statsJson != null && statsJson[id] != null) {
      parsedFollows = statsJson[id]['follows'] ?? 0;
    }

    return ComicDetailModel(
      id: id,
      title: parsedTitle,
      altTitle: parsedAltTitle,
      coverUrl: parsedCoverUrl,
      genres: parsedGenres,
      status: parsedStatus,
      publishYear: parsedYear,
      authorName: parsedAuthor,
      description: parsedDescription,
      follows: parsedFollows,
      views: '0',
    );
  }
}
