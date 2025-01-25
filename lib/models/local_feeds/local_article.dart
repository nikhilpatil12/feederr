import 'dart:convert';

import 'package:feederr/models/article.dart';

class LocalArticle {
  final String? id;
  int? id2;
  final int published;
  final String crawlTimeMsec;
  final String title;
  final String canonical;
  final String alternate;
  final String categories;
  // final String originStreamId;
  // final String originHtmlUrl;
  final String originTitle;
  final String summaryContent;
  final String author;
  String imageUrl;
  int serverId;
  // int feedId;
  bool isRead;
  bool isStarred;
  bool isLocal;

  LocalArticle({
    required this.id,
    this.id2,
    required this.crawlTimeMsec,
    // required this.timestampUsec,
    required this.published,
    required this.title,
    required this.canonical,
    required this.alternate,
    required this.categories,
    // required this.originStreamId,
    // required this.originHtmlUrl,
    required this.originTitle,
    required this.summaryContent,
    required this.author,
    required this.imageUrl,
    required this.serverId,
    // required this.feedId,
    required this.isRead,
    required this.isStarred,
    required this.isLocal,
  });

  // Convert a Article into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id2': id2,
      'crawlTimeMsec': crawlTimeMsec,
      'published': published,
      'title': title,
      'canonical': canonical,
      'alternate': alternate,
      'categories': categories,
      'summary_content': summaryContent,
      'origin_title': originTitle,
      'author': author,
      'serverId': serverId,
      'imageUrl': imageUrl,
    };
  }

  factory LocalArticle.fromMap(Map<String, dynamic> map) {
    return LocalArticle(
      id: map['id'] ?? '',
      id2: map['id2'] ?? 0,
      crawlTimeMsec: map['crawlTimeMsec'] ?? '',
      published: map['published'] ?? 0,
      title: map['title'] ?? '',
      canonical: map['canonical'][0]["href"] ?? '',
      alternate: map['alternate'][0]["href"] ?? '',
      categories: jsonEncode(map['categories']),
      summaryContent: map['summary']['content'] ?? '',
      originTitle: map['origin_title'] ?? '',
      author: map['author'] ?? '',
      serverId: map['serverId'] ?? 0,
      imageUrl: map['imageUrl'] ?? '',
      isLocal: true,
      isRead: map['isRead'] ?? false,
      isStarred: map['isStarred'] ?? false,
    );
  }
  factory LocalArticle.fromDBMap(Map<String, dynamic> map) {
    return LocalArticle(
      id: map['id'] ?? '',
      id2: map['id2'] ?? 0,
      crawlTimeMsec: map['crawlTimeMsec'] ?? '',
      published: map['published'] ?? 0,
      title: map['title'] ?? '',
      canonical: map['canonical'] ?? '',
      alternate: map['alternate'] ?? '',
      categories: map['categories'],
      summaryContent: map['summary_content'] ?? '',
      originTitle: map['origin_title'] ?? '',
      author: map['author'] ?? '',
      serverId: map['serverId'] ?? 0,
      imageUrl: map['imageUrl'] ?? 'https://picsum.photos/250?image=9',
      isLocal: true,
      isRead: false,
      isStarred: false,
    );
  }

  String toJson() => json.encode(toMap());

  factory LocalArticle.fromJson(String source) =>
      LocalArticle.fromMap(json.decode(source));

  // Implement toString to make it easier to see information about
  // each article when using the print statement.
  @override
  String toString() =>
      'Article(id: $id, id2: $id2,  crawlTimeMsec: $crawlTimeMsec,  published: $published, title: $title, canonical:$canonical, alternate:$alternate, categories:$categories, summaryContent:$summaryContent, author:$author, imageUrl:$imageUrl, originTitle:$originTitle, serverId:$serverId)';
}

extension LocalArticleExtension on LocalArticle {
  Article toArticle() {
    return Article(
      id: id,
      id2: id2, // Provide default or calculated value if necessary
      crawlTimeMsec: crawlTimeMsec,
      timestampUsec: "",
      published: published,
      title: title,
      canonical: canonical,
      alternate: alternate,
      categories: categories,
      originStreamId: "", // Default value
      originHtmlUrl: "", // Default value
      originTitle: originTitle, // Default value
      summaryContent: summaryContent,
      author: author,
      imageUrl: imageUrl,
      serverId: 0,
      feedId: 0, // Default value
      isRead: isRead,
      isStarred: isStarred,
      isLocal: true,
    );
  }
}

List<Article> convertLocalArticlesToArticles(List<LocalArticle> localArticles) {
  return localArticles.map((localArticle) => localArticle.toArticle()).toList();
}
