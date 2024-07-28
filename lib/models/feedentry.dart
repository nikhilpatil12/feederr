import 'package:feederr/models/article.dart';
import 'package:feederr/models/feed.dart';

class FeedEntry {
  final Feed feed;
  final List<Article> articles;
  final int count;

  FeedEntry({
    required this.feed,
    required this.articles,
    required this.count,
  });
}
