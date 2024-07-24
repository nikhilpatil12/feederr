import 'dart:convert';

class Feed {
  final String id;
  final String title;
  final String categories;
  final String url;
  final String htmlUrl;
  final String iconUrl;
  int serverId;

  Feed({
    required this.id,
    required this.title,
    required this.categories,
    required this.url,
    required this.htmlUrl,
    required this.iconUrl,
    required this.serverId,
  });

  // Convert a Feed into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'categories': categories,
      'url': url,
      'htmlUrl': htmlUrl,
      'iconUrl': iconUrl,
      'serverId': serverId,
    };
  }

  factory Feed.fromMap(Map<String, dynamic> map) {
    return Feed(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      categories: map['categories'].toString(),
      url: map['url'] ?? '',
      htmlUrl: map['htmlUrl'] ?? '',
      iconUrl: map['iconUrl'] ?? '',
      serverId: map['serverId'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Feed.fromJson(String source) => Feed.fromMap(json.decode(source));

  // Implement toString to make it easier to see information about
  // each article when using the print statement.
  @override
  String toString() =>
      'Feed(id: $id, title: $title, categories:$categories, url: $url, htmlUrl: $htmlUrl, icon_url:$iconUrl, serverId:$serverId)';
}