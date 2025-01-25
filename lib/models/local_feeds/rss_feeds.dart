import 'dart:convert';

class RssFeedUrl {
  final int? id;
  final String baseUrl;

  RssFeedUrl({
    this.id,
    required this.baseUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'baseUrl': baseUrl,
    };
  }

  factory RssFeedUrl.fromMap(Map<String, dynamic> map) {
    return RssFeedUrl(
      id: map['id']?.toInt() ?? 0,
      baseUrl: map['baseUrl'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory RssFeedUrl.fromJson(String source) =>
      RssFeedUrl.fromMap(json.decode(source));

  @override
  String toString() => 'Server(id:$id, baseUrl: $baseUrl, )';
}
