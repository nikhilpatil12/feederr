import 'dart:developer';

import 'package:dart_rss/domain/atom_feed.dart';
import 'package:dart_rss/domain/atom_item.dart';
import 'package:dart_rss/domain/rss1_feed.dart';
import 'package:dart_rss/domain/rss1_item.dart';
import 'package:dart_rss/domain/rss_feed.dart';
import 'package:dart_rss/domain/rss_item.dart';
import 'package:blazefeeds/models/local_feeds/local_article.dart';
import 'package:blazefeeds/models/local_feeds/local_feed.dart';
import 'package:blazefeeds/models/local_feeds/local_feedentry.dart';
import 'package:blazefeeds/models/local_feeds/rss_feeds.dart';
import 'package:blazefeeds/models/unread.dart';
import 'package:blazefeeds/utils/apiservice.dart';
import 'package:blazefeeds/utils/dbhelper.dart';
import 'package:blazefeeds/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';

class IndividualLocalFeedProvider extends ChangeNotifier {
  late LocalFeedEntry _feed;
  late String _path;

  LocalFeedEntry get feed => _feed;
  String get path => _path;

  final DatabaseService databaseService = DatabaseService();
  final APIService api = APIService();
  final AppUtils utils = AppUtils();

  IndividualLocalFeedProvider({required LocalFeedEntry feedEntry, required String path}) {
    _feed = feedEntry;
    _path = path;
    refreshLocalFeed();
  }

  Future<void> refreshLocalFeed() async {
    Set<String> liImagesToCache = {};
    RssFeedUrl feed = this.feed.feedUrl;
    LocalFeed? localFeed = await databaseService.localFeedByUrl(feed.baseUrl);
    if (path != "all" && path != "fav") {
      try {
        var response = await api.fetchLocalFeedContents(feed.baseUrl);
        if (response.statusCode == 200) {
          String feedType = utils.detectFeedFormat(response.data);
          switch (feedType) {
            case "RSS 2.0":
              try {
                final channel = RssFeed.parse(response.data);
                if (localFeed == null) {
                  await databaseService.insertLocalFeed(
                    LocalFeed(
                        title: channel.title ?? feed.id.toString(),
                        categories: channel.categories.toString(),
                        url: feed.baseUrl,
                        htmlUrl: channel.link ?? "",
                        iconUrl: channel.image?.url ?? "",
                        count: channel.items.length),
                  );
                  localFeed = await databaseService.localFeedByUrl(feed.baseUrl);
                  liImagesToCache.add(localFeed?.iconUrl ?? "");
                  // api.cacheImages();
                }
                for (RssItem item in channel.items) {
                  LocalArticle? article = await databaseService.localArticle(item.guid ?? "");
                  if (article == null) {
                    int id = await databaseService.insertLocalArticle(
                      LocalArticle(
                        id: item.guid,
                        originTitle: localFeed!.title,
                        crawlTimeMsec: DateTime.now().millisecondsSinceEpoch.toString(),
                        serverId: localFeed.id ?? 0,
                        published: utils.convertDateToGReader(item.pubDate ?? ""),
                        title: item.title ?? "",
                        canonical: item.link ?? "",
                        alternate: "",
                        categories: item.categories.toString(),
                        summaryContent: item.content?.value ?? "",
                        author: item.author ?? "",
                        imageUrl: item.content != null
                            ? item.content!.images.isNotEmpty
                                ? item.content!.images.first
                                : ""
                            : "",
                        isLocal: true,
                        isRead: false,
                        isStarred: false,
                      ),
                    );
                    await databaseService.insertUnreadId(UnreadId(articleId: id, serverId: 0));
                  }
                }
              } catch (e) {
                log("RSS2 Feed Error:$e");
              }
              break;
            case "RSS 1.0":
              try {
                final channel = Rss1Feed.parse(response.data);
                if (localFeed == null) {
                  await databaseService.insertLocalFeed(LocalFeed(
                      title: channel.title ?? feed.id.toString(),
                      categories: channel.dc?.subjects.toString() ?? "",
                      url: feed.baseUrl,
                      htmlUrl: channel.link ?? "",
                      iconUrl: channel.image ?? "",
                      count: channel.items.length));
                  localFeed = await databaseService.localFeedByUrl(feed.baseUrl);
                }
                for (Rss1Item item in channel.items) {
                  LocalArticle? article =
                      await databaseService.localArticle(item.dc?.identifier ?? "");
                  if (article == null) {
                    int id = await databaseService.insertLocalArticle(
                      LocalArticle(
                        id: item.dc?.identifier,
                        originTitle: localFeed!.title,
                        crawlTimeMsec: DateTime.now().millisecondsSinceEpoch.toString(),
                        serverId: localFeed.id ?? 0,
                        published: utils.convertDateToGReader(item.dc?.date ?? ""),
                        title: item.title ?? "",
                        canonical: item.link ?? "",
                        alternate: "",
                        categories:
                            utils.castToListOfStrings(item.dc?.subjects.toString()).toString(),
                        summaryContent: item.content?.value ?? "",
                        author: item.dc?.creator ?? "",
                        imageUrl: item.content!.images.isNotEmpty ? item.content!.images.first : "",
                        isLocal: true,
                        isRead: false,
                        isStarred: false,
                      ),
                    );
                    // print(resp);
                    await databaseService.insertUnreadId(UnreadId(articleId: id, serverId: 0));
                  }
                }
              } catch (e) {
                log("RSS1 Feed Error:$e");
              }
              break;
            case "Atom":
              try {
                final channel = AtomFeed.parse(response.data);
                if (localFeed == null) {
                  await databaseService.insertLocalFeed(LocalFeed(
                      title: channel.title ?? feed.id.toString(),
                      categories: channel.categories.toString(),
                      url: feed.baseUrl,
                      htmlUrl: channel.links.first.href ?? "",
                      iconUrl: channel.icon ?? "",
                      count: channel.items.length));
                  localFeed = await databaseService.localFeedByUrl(feed.baseUrl);
                }
                for (AtomItem item in channel.items) {
                  try {
                    LocalArticle? article = await databaseService.localArticle(item.id ?? "");
                    if (article == null) {
                      var document = parse(item.content);
                      String imageUrl = "";
                      List<dynamic> images = document.getElementsByTagName("img");
                      if (images.isNotEmpty) {
                        bool firstImageSet = false;
                        for (var img in images) {
                          if (img.attributes.containsKey("src") &&
                              !img.attributes['src']!.startsWith('data:image')) {
                            // api.cacheImages(imageUrl);
                            liImagesToCache.add(img.attributes['src']!);
                            if (!firstImageSet) {
                              imageUrl = img.attributes['src']!;
                              firstImageSet = true; // Mark the first image as set
                            }
                          }
                        }
                      }
                      int id = await databaseService.insertLocalArticle(
                        LocalArticle(
                          id: item.id,
                          crawlTimeMsec: DateTime.now().millisecondsSinceEpoch.toString(),
                          originTitle: localFeed!.title,
                          serverId: localFeed.id ?? 0,
                          published: utils.convertDateToGReader(item.published ?? ""),
                          title: item.title ?? "",
                          canonical: item.links.first.href ?? "",
                          alternate: "",
                          categories: item.categories
                              .map((category) => category.term ?? "")
                              .toList()
                              .toString(),
                          summaryContent: item.content ?? "",
                          author: item.authors.first.name ?? "",
                          imageUrl: item.media?.thumbnails.isNotEmpty ?? true
                              ? item.media?.thumbnails.first.url ?? ""
                              : imageUrl,
                          isLocal: true,
                          isRead: false,
                          isStarred: false,
                        ),
                      );
                      // print(resp);
                      await databaseService.insertUnreadId(UnreadId(articleId: id, serverId: 0));
                    }
                  } catch (e) {
                    log("$e");
                  }
                }
              } catch (e) {
                log("Atom Feed Error:$e");
              }
              break;
            default:
              break;
          }
          await api.cacheImages(liImagesToCache.toList());
        } else {
          log("Error: ${response.statusMessage}");
        }
      } on Exception catch (e) {
        log("Local feed fetching failure: $e");
      }
    }
    if (localFeed != null) {
      List<LocalArticle> articles = [];
      switch (path) {
        case 'all':
          articles = await databaseService.localArticlesByLocalFeed(localFeed);
        case 'new':
          articles = await databaseService.localUnreadArticlesByLocalFeed(localFeed);
        case 'fav':
          articles = await databaseService.localStarredArticlesByLocalFeed(localFeed);
        default:
          break;
      }
      if (articles.length != this.feed.articles.length) {
        // feed.articles = articles;
        // feed
        this.feed.articles = articles;
        // this.feed.articles = articles;
        // updateLocalFeed(this.feed);
      }
    }
  }

  // static IndividualLocalFeedProvider createEmpty() {
  //   return IndividualLocalFeedProvider._internal();
  // }

  // Future<void> initiateCategories() async {
  //   _feed = LocalFeedEntry();
  //   notifyListeners(); // Notify listeners when settings are loaded
  // }

  Future<void> updateLocalFeed(LocalFeedEntry feedEntry) async {
    _feed = feedEntry;
    await refreshLocalFeed();
    notifyListeners();
  }
}

class LocalFeedsProvider extends ChangeNotifier {
  final Map<String, IndividualLocalFeedProvider> _feedProviders = {};

  int get length => _feedProviders.length;
  bool get isEmpty => _feedProviders.isEmpty;
  bool get isNotEmpty => _feedProviders.isNotEmpty;

  // Add a new feed provider
  void addFeedProvider(String id, IndividualLocalFeedProvider feedProvider) {
    _feedProviders[id] = feedProvider;
    // _feeds[id] = feedProvider.feed;
    notifyListeners();
  }

  // Get all feed providers
  Map<String, IndividualLocalFeedProvider> getAllFeedProviders() => _feedProviders;
  List<LocalFeedEntry> getAllFeedEntries() {
    final liFeedEntries = <LocalFeedEntry>[];
    for (var entry in _feedProviders.entries) {
      liFeedEntries.add(entry.value._feed);
    }
    return liFeedEntries;
  }

  IndividualLocalFeedProvider getSingleFeedProvider(key) => _feedProviders[key]!;

  Future<void> updateFeedProvider(String id, LocalFeedEntry feedEntry) async {
    if (_feedProviders.containsKey(id)) {
      await _feedProviders[id]!.updateLocalFeed(feedEntry);
      // _feeds[id]!.feed = feedEntry.feed;
      notifyListeners();
    }
  }
}
