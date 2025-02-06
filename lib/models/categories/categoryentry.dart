import 'package:blazefeeds/models/article.dart';
import 'package:blazefeeds/models/category.dart';
import 'package:blazefeeds/models/feedentry.dart';

class CategoryEntry {
  final Category category;
  final List<FeedEntry> feedEntry;
  final List<Article> articles;
  final int count;

  CategoryEntry({
    required this.category,
    required this.feedEntry,
    required this.articles,
    required this.count,
  });
}
