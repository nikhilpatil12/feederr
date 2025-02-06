import 'package:blazefeeds/models/local_feeds/local_article.dart';
import 'package:blazefeeds/models/local_feeds/local_feed.dart';
import 'package:blazefeeds/models/local_feeds/rss_feeds.dart';

class LocalFeedEntry {
  LocalFeed feed;
  final RssFeedUrl feedUrl;
  List<LocalArticle> articles;
  // final int count;

  LocalFeedEntry({
    required this.feed,
    required this.feedUrl,
    required this.articles,
    // required this.count,
  });
}
