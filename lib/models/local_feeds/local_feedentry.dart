import 'package:feederr/models/local_feeds/local_article.dart';
import 'package:feederr/models/local_feeds/local_feed.dart';

class LocalFeedEntry {
  final LocalFeed feed;
  final List<LocalArticle> articles;
  final int count;

  LocalFeedEntry({
    required this.feed,
    required this.articles,
    required this.count,
  });
}
