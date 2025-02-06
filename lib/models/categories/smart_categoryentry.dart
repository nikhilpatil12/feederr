import 'package:blazefeeds/models/article.dart';
import 'package:blazefeeds/models/feedentry.dart';

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
