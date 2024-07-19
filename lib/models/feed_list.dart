import 'dart:convert';

class Feed {
  final String id;
  final String title;
  final String categories;
  final String url;
  final String origin_htmlUrl;
  final String icon_url;

  Feed({
    required this.id,
    required this.title,
    required this.categories,
    required this.url,
    required this.origin_htmlUrl,
    required this.icon_url,
  });

  // Convert a Feed into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'categories': categories,
      'origin_streamId': url,
      'origin_htmlUrl': origin_htmlUrl,
      'origin_title': icon_url
    };
  }

  factory Feed.fromMap(Map<String, dynamic> map) {
    return Feed(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      categories: map['categories'] ?? '',
      url: map['url'] ?? '',
      origin_htmlUrl: map['origin_htmlUrl'] ?? '',
      icon_url: map['icon_url'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Feed.fromJson(String source) => Feed.fromMap(json.decode(source));

  // Implement toString to make it easier to see information about
  // each article when using the print statement.
  @override
  String toString() =>
      'Feed(id: $id, title: $title, categories:$categories, url: $url, origin_htmlUrl: $origin_htmlUrl, icon_url:$icon_url)';
}
