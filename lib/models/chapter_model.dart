class ChapterModel {
  final String id;
  final String chapterTitle;
  final String uploaderName;
  final String publishDate;

  ChapterModel({
    required this.id,
    required this.chapterTitle,
    required this.uploaderName,
    required this.publishDate,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] ?? {};
    final id = json['id'] ?? '';

    String chapNum =
        attributes['chapter']?.toString() ?? '';
    String title = attributes['title']?.toString() ?? '';

    String displayTitle = '';
    if (chapNum.isNotEmpty) {
      displayTitle = 'Chapter $chapNum';
      if (title.isNotEmpty) displayTitle += ': $title';
    } else {
      displayTitle = title.isNotEmpty ? title : 'Oneshot';
    }

    String parsedDate = 'Đang cập nhật';
    if (attributes['publishAt'] != null) {
      DateTime publishAt = DateTime.parse(
        attributes['publishAt'],
      ).toLocal();
      String day = publishAt.day.toString().padLeft(2, '0');
      String month = publishAt.month.toString().padLeft(
        2,
        '0',
      );
      parsedDate = '$day/$month/${publishAt.year}';
    }

    String parsedUploader = 'Không rõ';
    final relationships =
        json['relationships'] as List<dynamic>? ?? [];
    for (var rel in relationships) {
      if (rel['attributes'] != null) {
        if (rel['type'] == 'scanlation_group') {
          parsedUploader =
              rel['attributes']['name'] ?? parsedUploader;
          break;
        } else if (rel['type'] == 'user' &&
            parsedUploader == 'Không rõ') {
          parsedUploader =
              rel['attributes']['username'] ??
              parsedUploader;
        }
      }
    }

    return ChapterModel(
      id: id,
      chapterTitle: displayTitle,
      uploaderName: parsedUploader,
      publishDate: parsedDate,
    );
  }
}
