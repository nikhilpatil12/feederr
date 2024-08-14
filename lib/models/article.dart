import 'dart:convert';

class Article {
  final String? id;
  int? id2;
  final String crawlTimeMsec;
  final String timestampUsec;
  final int published;
  final String title;
  final String canonical;
  final String alternate;
  final String categories;
  final String originStreamId;
  final String originHtmlUrl;
  final String originTitle;
  final String summaryContent;
  final String author;
  String imageUrl;
  int serverId;
  int feedId;

  Article({
    required this.id,
    this.id2,
    required this.crawlTimeMsec,
    required this.timestampUsec,
    required this.published,
    required this.title,
    required this.canonical,
    required this.alternate,
    required this.categories,
    required this.originStreamId,
    required this.originHtmlUrl,
    required this.originTitle,
    required this.summaryContent,
    required this.author,
    required this.imageUrl,
    required this.serverId,
    required this.feedId,
  });

  // Convert a Article into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id2': id2,
      'crawlTimeMsec': crawlTimeMsec,
      'timestampUsec': timestampUsec,
      'published': published,
      'title': title,
      'canonical': canonical,
      'alternate': alternate,
      'categories': categories,
      'origin_streamId': originStreamId,
      'origin_htmlUrl': originHtmlUrl,
      'origin_title': originTitle,
      'summary_content': summaryContent,
      'author': author,
      'imageUrl': imageUrl,
      'serverId': serverId,
      'feedId': feedId,
    };
  }

  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      id: map['id'] ?? '',
      id2: map['id2'] ?? 0,
      crawlTimeMsec: map['crawlTimeMsec'] ?? '',
      timestampUsec: map['timestampUsec'] ?? '',
      published: map['published'] ?? 0,
      title: map['title'] ?? '',
      canonical: map['canonical'][0]["href"] ?? '',
      alternate: map['alternate'][0]["href"] ?? '',
      categories: jsonEncode(map['categories']),
      originStreamId: map['origin']['streamId'] ?? '',
      originHtmlUrl: map['origin']['htmlUrl'] ?? '',
      originTitle: map['origin']['title'] ?? '',
      summaryContent: map['summary']['content'] ?? '',
      author: map['author'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      serverId: map['serverId'] ?? 0,
      feedId: map['feedId'] ?? 0,
    );
  }
  factory Article.fromDBMap(Map<String, dynamic> map) {
    return Article(
      id: map['id'] ?? '',
      id2: map['id2'] ?? 0,
      crawlTimeMsec: map['crawlTimeMsec'] ?? '',
      timestampUsec: map['timestampUsec'] ?? '',
      published: map['published'] ?? 0,
      title: map['title'] ?? '',
      canonical: map['canonical'] ?? '',
      alternate: map['alternate'] ?? '',
      categories: map['categories'],
      originStreamId: map['originStreamId'] ?? '',
      originHtmlUrl: map['origin_htmlUrl'] ?? '',
      originTitle: map['origin_title'] ?? '',
      summaryContent: map['summary_content'] ?? '',
      author: map['author'] ?? '',
      imageUrl: map['imageUrl'] ?? 'https://picsum.photos/250?image=9',
      serverId: map['serverId'] ?? 0,
      feedId: map['feedId'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Article.fromJson(String source) =>
      Article.fromMap(json.decode(source));

  // Implement toString to make it easier to see information about
  // each article when using the print statement.
  @override
  String toString() =>
      'Article(id: $id, id2: $id2, crawlTimeMsec: $crawlTimeMsec, timestampUsec: $timestampUsec, published: $published, title: $title, canonical:$canonical, alternate:$alternate, categories:$categories, originStreamId: $originStreamId, originHtmlUrl: $originHtmlUrl, originTitle:$originTitle, summaryContent:$summaryContent, author:$author, imageUrl:$imageUrl, serverId:$serverId, feedId:$feedId)';
}
