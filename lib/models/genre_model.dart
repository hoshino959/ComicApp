class GenreModel {
  final String id;
  final String name;

  GenreModel({required this.id, required this.name});

  factory GenreModel.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] ?? {};
    final nameMap = attributes['name'] ?? {};

    String parsedName =
        nameMap['vi'] ?? nameMap['en'] ?? 'Unknown';

    return GenreModel(
      id: json['id'] ?? '',
      name: parsedName,
    );
  }
}
