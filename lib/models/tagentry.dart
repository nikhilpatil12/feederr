import 'package:feederr/models/article.dart';
import 'package:feederr/models/feed.dart';
import 'package:feederr/models/tag.dart';

class TagEntry {
  final Tag tag;
  final List<Feed> feeds;
  final List<Article> articles;

  TagEntry({
    required this.tag,
    required this.feeds,
    required this.articles,
  });
}
