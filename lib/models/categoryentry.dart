import 'package:feederr/models/article.dart';
import 'package:feederr/models/category.dart';
import 'package:feederr/models/feedentry.dart';

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
