import 'package:feederr/models/article.dart';
import 'package:feederr/models/feedentry.dart';

class SmartCategoryEntry {
  final String title;
  final List<Article> articles;
  final List<FeedEntry> feeds;

  SmartCategoryEntry({
    required this.title,
    required this.articles,
    required this.feeds,
  });
}
