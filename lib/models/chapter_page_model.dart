class ChapterPagesModel {
  final List<String> imageUrls;
  final int totalPages;

  ChapterPagesModel({required this.imageUrls, required this.totalPages});

  factory ChapterPagesModel.fromJson(Map<String, dynamic> json, {bool useDataSaver = false}) {
    final baseUrl = json['baseUrl'] ?? '';
    final chapterInfo = json['chapter'] ?? {};
    final hash = chapterInfo['hash'] ?? '';

    final List<dynamic> dataArray = useDataSaver ? (chapterInfo['dataSaver'] ?? []) : (chapterInfo['data'] ?? []);

    final String folder = useDataSaver ? 'data-saver' : 'data';

    List<String> urls = dataArray.map((fileName) {
      return '$baseUrl/$folder/$hash/$fileName';
    }).toList();

    return ChapterPagesModel(imageUrls: urls, totalPages: urls.length);
  }
}
