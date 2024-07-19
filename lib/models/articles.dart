import 'dart:convert';

class Article {
  final int? id;
  final String id2;
  final String crawlTimeMsec;
  final String timestampUsec;
  final String published;
  final String title;
  final String canonical;
  final String alternate;
  final String categories;
  final String origin_streamId;
  final String origin_htmlUrl;
  final String origin_title;
  final String summary_content;
  final String author;

  Article(
      {this.id,
      required this.id2,
      required this.crawlTimeMsec,
      required this.timestampUsec,
      required this.published,
      required this.title,
      required this.canonical,
      required this.alternate,
      required this.categories,
      required this.origin_streamId,
      required this.origin_htmlUrl,
      required this.origin_title,
      required this.summary_content,
      required this.author});

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
      'origin_streamId': origin_streamId,
      'origin_htmlUrl': origin_htmlUrl,
      'origin_title': origin_title,
      'summary_content': summary_content,
      'author': author
    };
  }

  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      id: map['id']?.toInt() ?? 0,
      id2: map['id2'] ?? '',
      crawlTimeMsec: map['crawlTimeMsec'] ?? '',
      timestampUsec: map['timestampUsec'] ?? '',
      published: map['published'] ?? '',
      title: map['title'] ?? '',
      canonical: map['canonical'] ?? '',
      alternate: map['alternate'] ?? '',
      categories: map['categories'] ?? '',
      origin_streamId: map['origin_streamId'] ?? '',
      origin_htmlUrl: map['origin_htmlUrl'] ?? '',
      origin_title: map['origin_title'] ?? '',
      summary_content: map['summary_content'] ?? '',
      author: map['author'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Article.fromJson(String source) =>
      Article.fromMap(json.decode(source));

  // Implement toString to make it easier to see information about
  // each article when using the print statement.
  @override
  String toString() =>
      'Article(id: $id, id2: $id2, crawlTimeMsec: $crawlTimeMsec, timestampUsec: $timestampUsec, published: $published, title: $title, canonical:$canonical, alternate:$alternate, categories:$categories, origin_streamId: $origin_streamId, origin_htmlUrl: $origin_htmlUrl, origin_title:$origin_title, summary_content:$summary_content, author:$author)';
}
