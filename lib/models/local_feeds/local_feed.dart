import 'dart:convert';

import 'package:blazefeeds/models/feed.dart';

class LocalFeed {
  final int? id;
  final String title;
  final String categories;
  final String url;
  final String htmlUrl;
  final String iconUrl;
  final int count;

  LocalFeed({
    // required this.id,
    this.id,
    required this.title,
    required this.categories,
    required this.url,
    required this.htmlUrl,
    required this.iconUrl,
    required this.count,
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
      'count': count,
    };
  }

  factory LocalFeed.fromMap(Map<String, dynamic> map) {
    return LocalFeed(
      id: map['id'] ?? 0,
      title: map['title'] ?? '',
      categories: jsonEncode(map['categories']),
      url: map['url'] ?? '',
      htmlUrl: map['htmlUrl'] ?? '',
      iconUrl: map['iconUrl'] ?? '',
      count: map['count'] ?? 0,
    );
  }
  factory LocalFeed.fromDBMap(Map<String, dynamic> map) {
    return LocalFeed(
      id: map['id'] ?? 0,
      title: map['title'] ?? '',
      categories: map['categories'],
      url: map['url'] ?? '',
      htmlUrl: map['htmlUrl'] ?? '',
      iconUrl: map['iconUrl'] ?? '',
      count: map['count'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory LocalFeed.fromJson(String source) => LocalFeed.fromMap(json.decode(source));

  // Implement toString to make it easier to see information about
  // each article when using the print statement.
  @override
  String toString() =>
      'Feed(id: $id, title: $title, categories:$categories, url: $url, htmlUrl: $htmlUrl, icon_url:$iconUrl, count:$count,)';
}

extension LocalFeedExtension on LocalFeed {
  Feed toFeed() {
    return Feed(
      id: id.toString(),
      id2: id,
      title: title,
      categories: categories,
      serverId: 0,
      url: url,
      htmlUrl: htmlUrl,
      iconUrl: iconUrl,
      count: count,
    );
  }
}
