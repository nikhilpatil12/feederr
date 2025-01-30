import 'dart:convert';
import 'dart:core';
import 'dart:developer';
import 'package:dart_rss/dart_rss.dart';
import 'package:dart_rss/domain/rss1_item.dart';
import 'package:feederr/models/article.dart';
import 'package:feederr/models/feed.dart';
import 'package:feederr/models/categories/categoryentry.dart';
import 'package:feederr/models/local_feeds/local_article.dart';
import 'package:feederr/models/local_feeds/local_feed.dart';
import 'package:feederr/models/local_feeds/local_feedentry.dart';
import 'package:feederr/models/local_feeds/rss_feeds.dart';
import 'package:feederr/models/tagged_id.dart';
import 'package:feederr/models/unread.dart';
import 'package:feederr/models/server.dart';
import 'package:feederr/models/starred.dart';
import 'package:feederr/models/tag.dart';
import 'package:feederr/pages/add_server.dart';
import 'package:feederr/pages/article_tab.dart';
import 'package:feederr/providers/local_feed_provider.dart';
import 'package:feederr/providers/server_categories_provider.dart';
import 'package:feederr/utils/apiservice.dart';
import 'package:feederr/utils/dbhelper.dart';
import 'package:feederr/providers/theme_provider.dart';
import 'package:feederr/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html/parser.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:feederr/pages/settings.dart';
import 'package:feederr/models/app_theme.dart';
import 'package:provider/provider.dart';

bool isWebLoading = false;
bool isLocalDBLoading = false;
bool isLocalFeedLoading = false;
String status = "";

class HomeScreen extends StatefulWidget {
  HomeScreen({
    super.key,
  });
  final APIService api = APIService();
  final DatabaseService databaseService = DatabaseService();
  final AppUtils utils = AppUtils();
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<Feed> dbFeeds = [];
  List<Tag> dbTags = [];
  List<UnreadId> dbUnreadIds = [];
  List<StarredId> dbStarredIds = [];

  List<Article> dbArticles = [];

  List<CategoryEntry> favCategoryEntries = [];
  List<CategoryEntry> newCategoryEntries = [];
  List<CategoryEntry> allCategoryEntries = [];
  ServerCatogoriesProvider allServerCatogoriesProvider = ServerCatogoriesProvider.createEmpty();
  ServerCatogoriesProvider newServerCatogoriesProvider = ServerCatogoriesProvider.createEmpty();
  ServerCatogoriesProvider favServerCatogoriesProvider = ServerCatogoriesProvider.createEmpty();
  LocalFeedsProvider allFeedsProvider = LocalFeedsProvider.createEmpty();
  LocalFeedsProvider newFeedsProvider = LocalFeedsProvider.createEmpty();
  LocalFeedsProvider favFeedsProvider = LocalFeedsProvider.createEmpty();
  List<LocalFeedEntry> localFavFeeds = [];
  List<LocalFeedEntry> localNewFeeds = [];
  List<LocalFeedEntry> localAllFeeds = [];
  Set<String> liImagesToCache = {};

  void showStatus(String newStatus) async {
    status = newStatus;
    setState(() {
      status = newStatus;
    });
  }

  void refreshFeeds() async {
    liImagesToCache = {};
    log("Refreshing feeds");
    await _fetchDBServerFeeds();
    await _fetchLocalFeedList();
    await _fetchServerFeeds();
    await _fetchDBServerFeeds();
    // TODO: remove the comment below
    await _cacheImages();
    log("Images to cache: ${liImagesToCache.length}");
    // log("Unique Images to cache: ${liImagesToCache.toSet().length}");
    log("Refreshed feeds");
    // setState(() {});
  }

  @override
  void initState() {
    super.initState();
    isWebLoading = true;
    isLocalDBLoading = true;
    isLocalFeedLoading = true;
    // _fetchDBServerFeeds();
    // _fetchLocalFeedList();
    // _fetchServerFeeds();
    // _cacheImages();
    refreshFeeds();
  }

  Future<void> _fetchLocalFeedList() async {
    localAllFeeds = [];
    localNewFeeds = [];
    localFavFeeds = [];
    // await databaseService
    //     .insertRssFeed(RssFeed(baseUrl: 'https://www.billboard.com/feed/'));
    // List<RssFeedUrl> feedList = await databaseService.rssFeeds();
    List<RssFeedUrl> feedList = [
      RssFeedUrl(baseUrl: 'https://www.theverge.com/rss/index.xml'),
      RssFeedUrl(baseUrl: 'https://www.billboard.com/feed/'),
      // RssFeedUrl(
      //     baseUrl:
      //         'https://lorem-rss.herokuapp.com/feed?unit=second&interval=30'),
      // RssFeedUrl(
      //     baseUrl: 'http://feeds.bbci.co.uk/news/world/asia/india/rss.xml'),
      // RssFeedUrl(baseUrl: 'https://www.bhaskar.com/rss-feed/1061/'),
      RssFeedUrl(baseUrl: 'https://maharashtratimes.com/rssfeedsdefault.cms'),
      // RssFeedUrl(baseUrl: 'https://www.loksatta.com/desh-videsh/feed/'),
    ];
    for (RssFeedUrl feed in feedList) {
      LocalFeed? localFeed = await widget.databaseService.localFeedByUrl(feed.baseUrl);
      try {
        var response = await widget.api.fetchLocalFeedContents(feed.baseUrl);
        if (response.statusCode == 200) {
          // print(json.encode(response.data));
          // try{
          String feedType = widget.utils.detectFeedFormat(response.data);
          switch (feedType) {
            case "RSS 2.0":
              try {
                final channel = RssFeed.parse(response.data);
                if (localFeed == null) {
                  await widget.databaseService.insertLocalFeed(
                    LocalFeed(
                        title: channel.title ?? feed.id.toString(),
                        categories: channel.categories.toString(),
                        url: feed.baseUrl,
                        htmlUrl: channel.link ?? "",
                        iconUrl: channel.image?.url ?? "",
                        count: channel.items.length),
                  );
                  localFeed = await widget.databaseService.localFeedByUrl(feed.baseUrl);
                  liImagesToCache.add(localFeed?.iconUrl ?? "");
                  // widget.api.cacheImages();
                }
                for (RssItem item in channel.items) {
                  LocalArticle? article =
                      await widget.databaseService.localArticle(item.guid ?? "");
                  if (article == null) {
                    int id = await widget.databaseService.insertLocalArticle(
                      LocalArticle(
                        id: item.guid,
                        originTitle: localFeed!.title,
                        crawlTimeMsec: DateTime.now().millisecondsSinceEpoch.toString(),
                        serverId: localFeed.id ?? 0,
                        published: widget.utils.convertDateToGReader(item.pubDate ?? ""),
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
                    // print(resp);
                    await widget.databaseService
                        .insertUnreadId(UnreadId(articleId: id, serverId: 0));
                  }
                }
              } catch (e) {
                log("RSS2 Feed Error:$e");
              }
              break;
            case "RSS 1.0":
              try {
                final channel = Rss1Feed.parse(response.data);
                // LocalFeed? localFeed =
                //     await widget.databaseService.localFeedByUrl(feed.baseUrl);
                if (localFeed == null) {
                  await widget.databaseService.insertLocalFeed(LocalFeed(
                      title: channel.title ?? feed.id.toString(),
                      categories: channel.dc?.subjects.toString() ?? "",
                      url: feed.baseUrl,
                      htmlUrl: channel.link ?? "",
                      iconUrl: channel.image ?? "",
                      count: channel.items.length));
                  localFeed = await widget.databaseService.localFeedByUrl(feed.baseUrl);
                }
                for (Rss1Item item in channel.items) {
                  LocalArticle? article =
                      await widget.databaseService.localArticle(item.dc?.identifier ?? "");
                  if (article == null) {
                    int id = await widget.databaseService.insertLocalArticle(
                      LocalArticle(
                        id: item.dc?.identifier,
                        originTitle: localFeed!.title,
                        crawlTimeMsec: DateTime.now().millisecondsSinceEpoch.toString(),
                        serverId: localFeed.id ?? 0,
                        published: widget.utils.convertDateToGReader(item.dc?.date ?? ""),
                        title: item.title ?? "",
                        canonical: item.link ?? "",
                        alternate: "",
                        categories: widget.utils
                            .castToListOfStrings(item.dc?.subjects.toString())
                            .toString(),
                        summaryContent: item.content?.value ?? "",
                        author: item.dc?.creator ?? "",
                        imageUrl: item.content!.images.isNotEmpty ? item.content!.images.first : "",
                        isLocal: true,
                        isRead: false,
                        isStarred: false,
                      ),
                    );
                    // print(resp);
                    await widget.databaseService
                        .insertUnreadId(UnreadId(articleId: id, serverId: 0));
                  }
                }
                // List<LocalArticle> allArticles = await widget.databaseService
                //     .localArticlesByLocalFeed(localFeed!);
                // localAllFeeds.add(LocalFeedEntry(
                //     feed: localFeed,
                //     articles: allArticles,
                //     count: allArticles.length));
                // List<LocalArticle> newArticles = await widget.databaseService
                //     .localUnreadArticlesByLocalFeed(localFeed);
                // if (newArticles.isNotEmpty) {
                //   localNewFeeds.add(
                //     LocalFeedEntry(
                //       feed: localFeed,
                //       articles: newArticles,
                //       count: newArticles.length,
                //     ),
                //   );
                // }
                // List<LocalArticle> starredArticles = await widget
                //     .databaseService
                //     .localStarredArticlesByLocalFeed(localFeed);
                // if (starredArticles.isNotEmpty) {
                //   localFavFeeds.add(
                //     LocalFeedEntry(
                //       feed: localFeed,
                //       articles: starredArticles,
                //       count: starredArticles.length,
                //     ),
                //   );
                // }
              } catch (e) {
                log("RSS1 Feed Error:$e");
              }
              break;
            case "Atom":
              try {
                final channel = AtomFeed.parse(response.data);
                // LocalFeed? localFeed =
                //     await widget.databaseService.localFeedByUrl(feed.baseUrl);
                if (localFeed == null) {
                  await widget.databaseService.insertLocalFeed(LocalFeed(
                      title: channel.title ?? feed.id.toString(),
                      categories: channel.categories.toString(),
                      url: feed.baseUrl,
                      htmlUrl: channel.links.first.href ?? "",
                      iconUrl: channel.icon ?? "",
                      count: channel.items.length));
                  localFeed = await widget.databaseService.localFeedByUrl(feed.baseUrl);
                }
                for (AtomItem item in channel.items) {
                  try {
                    LocalArticle? article =
                        await widget.databaseService.localArticle(item.id ?? "");
                    if (article == null) {
                      var document = parse(item.content);
                      String imageUrl = "";
                      List<dynamic> images = document.getElementsByTagName("img");
                      if (images.isNotEmpty) {
                        bool firstImageSet = false;
                        for (var img in images) {
                          if (img.attributes.containsKey("src") &&
                              !img.attributes['src']!.startsWith('data:image')) {
                            // widget.api.cacheImages(imageUrl);
                            liImagesToCache.add(img.attributes['src']!);
                            if (!firstImageSet) {
                              imageUrl = img.attributes['src']!;
                              firstImageSet = true; // Mark the first image as set
                            }
                          }
                        }
                      }
                      int id = await widget.databaseService.insertLocalArticle(
                        LocalArticle(
                          id: item.id,
                          crawlTimeMsec: DateTime.now().millisecondsSinceEpoch.toString(),
                          originTitle: localFeed!.title,
                          serverId: localFeed.id ?? 0,
                          published: widget.utils.convertDateToGReader(item.published ?? ""),
                          title: item.title ?? "",
                          canonical: item.links.first.href ?? "",
                          alternate: "",
                          categories: item.categories
                                  ?.map((category) => category.term ?? "")
                                  .toList()
                                  .toString() ??
                              [].toString(),
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
                      await widget.databaseService
                          .insertUnreadId(UnreadId(articleId: id, serverId: 0));
                    }
                  } catch (e) {
                    log("$e");
                  }
                }
                // List<LocalArticle> allArticles = await widget.databaseService
                //     .localArticlesByLocalFeed(localFeed!);
                // localAllFeeds.add(
                //   LocalFeedEntry(
                //       feed: localFeed,
                //       articles: allArticles,
                //       count: allArticles.length),
                // );
                // List<LocalArticle> newArticles = await widget.databaseService
                //     .localUnreadArticlesByLocalFeed(localFeed);
                // if (newArticles.isNotEmpty) {
                //   localNewFeeds.add(
                //     LocalFeedEntry(
                //       feed: localFeed,
                //       articles: newArticles,
                //       count: newArticles.length,
                //     ),
                //   );
                // }
                // List<LocalArticle> starredArticles = await widget
                //     .databaseService
                //     .localStarredArticlesByLocalFeed(localFeed);
                // if (starredArticles.isNotEmpty) {
                //   localFavFeeds.add(
                //     LocalFeedEntry(
                //       feed: localFeed,
                //       articles: starredArticles,
                //       count: starredArticles.length,
                //     ),
                //   );
                // }
              } catch (e) {
                log("Atom Feed Error:$e");
              }
              break;
            default:
              break;
          }
        } else {
          log("Error: ${response.statusMessage}");
        }
      } on Exception catch (e) {
        log("Local feed fetching failure: $e");
      }
      List<LocalArticle> allArticles =
          await widget.databaseService.localArticlesByLocalFeed(localFeed!);
      localAllFeeds.add(
        LocalFeedEntry(
          feed: localFeed,
          articles: allArticles,
          count: allArticles.length,
        ),
      );
      List<LocalArticle> newArticles =
          await widget.databaseService.localUnreadArticlesByLocalFeed(localFeed);
      if (newArticles.isNotEmpty) {
        localNewFeeds.add(
          LocalFeedEntry(
            feed: localFeed,
            articles: newArticles,
            count: newArticles.length,
          ),
        );
      }
      List<LocalArticle> starredArticles =
          await widget.databaseService.localStarredArticlesByLocalFeed(localFeed);
      if (starredArticles.isNotEmpty) {
        localFavFeeds.add(
          LocalFeedEntry(
            feed: localFeed,
            articles: starredArticles,
            count: starredArticles.length,
          ),
        );
      }
    }

    allFeedsProvider.updateCategories(localAllFeeds);
    newFeedsProvider.updateCategories(localNewFeeds);
    favFeedsProvider.updateCategories(localFavFeeds);
    setState(() {
      isLocalFeedLoading = false;
    });
  }

  Future<void> _fetchDBServerFeeds() async {
    favCategoryEntries = [];
    allCategoryEntries = [];
    newCategoryEntries = [];
    List<Server> serverList = await widget.databaseService.servers();

    if (serverList.isNotEmpty) {
      for (Server server in serverList) {
        if (server.baseUrl != "localhost") {
          int serverId = server.id ?? 0;
          favCategoryEntries
              .addAll(await widget.databaseService.getCategoryEntriesWithStarredArticles(serverId));
          allCategoryEntries.addAll(await widget.databaseService.getAllCategoryEntries(serverId));
          newCategoryEntries
              .addAll(await widget.databaseService.getCategoryEntriesWithNewArticles(serverId));
          setState(() {
            isLocalDBLoading = false;
          });
        }
      }
    }
    allServerCatogoriesProvider.updateCategories(allCategoryEntries);
    favServerCatogoriesProvider.updateCategories(favCategoryEntries);
    newServerCatogoriesProvider.updateCategories(newCategoryEntries);
  }

  Future<void> _fetchServerFeeds() async {
    try {
      //Getting Server list
      List<Server> serverList = await widget.databaseService.servers();

      if (serverList.isNotEmpty) {
        for (Server server in serverList) {
          if (server.baseUrl != "localhost") {
            String baseUrl = server.baseUrl;
            String userName = server.userName;
            String password = server.password;
            String auth = server.auth ?? '';
            int serverId = server.id ?? 0;
            if (auth == '') {
              // Login and set the auth token
              auth = await widget.api.userLogin(baseUrl, userName, password);
            }
            showStatus("Fetching feeds");
            //Getting feedlist from server(s)
            List<Feed> feedList = await widget.api.fetchFeedList(baseUrl, auth) ?? [];
            dbFeeds = await widget.databaseService.feedsByServerId(serverId);

            dbTags = await widget.databaseService.tagsForServer(serverId);
            dbUnreadIds = await widget.databaseService.unreadIdsForServer(serverId);
            dbStarredIds = await widget.databaseService.starredIdsForServer(serverId);
            dbArticles = await widget.databaseService.articlesForServer(serverId);

            // favCategoryEntries.addAll(
            //     await widget.databaseService.getCategoryEntriesWithStarredArticles(serverId));
            // allCategoryEntries.addAll(await widget.databaseService.getAllCategoryEntries(serverId));
            // newCategoryEntries
            //     .addAll(await widget.databaseService.getCategoryEntriesWithNewArticles(serverId));
            // setState(() {
            //   isLocalDBLoading = false;
            // });
            //Adding new feeds to db
            for (Feed feed in feedList) {
              //saving to DB
              feed.serverId = serverId;
              Feed? dF = await widget.databaseService.feedByServerAndFeedId(serverId, feed.id);
              if (dF == null) {
                // if (feed.iconUrl.length < 5) {
                //   final response = await dio.get(feed.htmlUrl);
                //   var document = parse(response.data);

                //   String? iconUrl;
                //   final linkTags = document.getElementsByTagName('link');
                //   for (var tag in linkTags) {
                //     if (tag.attributes['rel']?.contains('icon') == true) {
                //       iconUrl = tag.attributes['href'];
                //       break;
                //     }
                //   }
                //   feed.iconUrl = iconUrl ?? "";
                // }
                await widget.databaseService.insertFeed(feed);
              }
            }
            dbFeeds = await widget.databaseService.feedsByServerId(serverId);
            //Removing old feeds from db
            if (dbFeeds.isNotEmpty) {
              for (Feed feed in dbFeeds) {
                if (feedList.where((x) => x.id == feed.id && x.serverId == serverId).isEmpty) {
                  await widget.databaseService.deleteFeed(feed.id);
                }
              }
            }
            dbFeeds = await widget.databaseService.feedsByServerId(serverId);
            for (Feed feed in dbFeeds) {
              List<String> categories = [];
              var feedCategories = jsonDecode(feed.categories);

              if (feedCategories is List) {
                for (var feedCategory in feedCategories) {
                  if (feedCategory is Map && feedCategory.containsKey('id')) {
                    categories.add(feedCategory['id']);
                  }
                }
              }
              await widget.databaseService.insertFeedWithCategories(feed, categories);
            }
            showStatus("Fetching folders");
            //Getting taglist from server(s)
            List<Tag> tagList = await widget.api.fetchTagList(baseUrl, auth) ?? [];
            //add new tags from server(s)
            for (Tag tag in tagList) {
              //saving to DB
              if (tag.type == "folder") {
                tag.serverId = serverId;
                if (dbTags.isEmpty ||
                    (dbTags.isNotEmpty &&
                        dbTags.where((x) => x.id == tag.id && x.serverId == serverId).isEmpty)) {
                  await widget.databaseService.insertTag(tag);
                }
              }
            }
            dbTags = await widget.databaseService.tagsForServer(serverId);
            //Removing old tags from db
            if (dbTags.isNotEmpty) {
              for (Tag tag in dbTags) {
                if (tagList.where((x) => x.id == tag.id && x.serverId == serverId).isEmpty) {
                  await widget.databaseService.deleteTag(tag.id);
                }
              }
            }
            dbTags = await widget.databaseService.tagsForServer(serverId);
            showStatus("Fetching unread items");
            //Get Unread/New Ids
            List<UnreadId> unreadIds = await widget.api.fetchUnreadIds(baseUrl, auth) ?? [];
            //Saving newids to db
            for (UnreadId id in unreadIds) {
              //saving to DB
              id.serverId = serverId;
              if (dbUnreadIds.isEmpty ||
                  (dbUnreadIds.isNotEmpty &&
                      dbUnreadIds
                          .where((x) => x.articleId == id.articleId && x.serverId == serverId)
                          .isEmpty)) {
                await widget.databaseService.insertUnreadId(id);
              }
            }
            dbUnreadIds = await widget.databaseService.unreadIdsForServer(serverId);
            //Removing old ids from db
            if (dbUnreadIds.isNotEmpty) {
              for (UnreadId id in dbUnreadIds) {
                if (id.serverId != 0) {
                  if (unreadIds
                      .where((x) => x.articleId == id.articleId && x.serverId == serverId)
                      .isEmpty) {
                    await widget.databaseService.deleteUnreadId(id.articleId);
                  }
                }
              }
            }
            dbUnreadIds = await widget.databaseService.unreadIdsForServer(serverId);

            //Add missing IDs from database to the API query sring
            List<String> missingIds = [];
            for (UnreadId unreadId in dbUnreadIds) {
              int id = unreadId.articleId;
              Article? a = await widget.databaseService.article(id);
              if (a == null) {
                // missingIds += "i=$id&";
                missingIds.add(id.toString());
              }
            }

            for (Tag tag in dbTags) {
              List<TaggedId>? taggedIds = await widget.api.fetchTaggedIds(baseUrl, auth, tag.id);
              //Adding new tagged article ids to db
              if (taggedIds != null && taggedIds.isNotEmpty) {
                for (TaggedId taggedId in taggedIds) {
                  int id = taggedId.articleId;
                  Article? a = await widget.databaseService.article(id);
                  if (a == null) {
                    missingIds.add(id.toString());
                  }
                }
              }
            }
            // _showOverlay("Fetching new articles...");
            //Get starred Ids
            List<StarredId> newStarredIds = await widget.api.fetchStarredIds(baseUrl, auth) ?? [];
            //Saving new starred ids to db
            for (StarredId id in newStarredIds) {
              //saving to DB
              id.serverId = serverId;
              if (dbStarredIds.isEmpty ||
                  (dbStarredIds.isNotEmpty &&
                      dbStarredIds
                          .where((x) => x.articleId == id.articleId && x.serverId == serverId)
                          .isEmpty)) {
                await widget.databaseService.insertStarredId(id);
              }
            }
            dbStarredIds = await widget.databaseService.starredIdsForServer(serverId);
            //Removing old ids from db
            if (dbStarredIds.isNotEmpty) {
              for (StarredId id in dbStarredIds) {
                if (id.serverId != 0) {
                  if (newStarredIds
                      .where((x) => x.articleId == id.articleId && x.serverId == serverId)
                      .isEmpty) {
                    await widget.databaseService.deleteStarredId(id.articleId);
                  }
                }
              }
            }
            dbStarredIds = await widget.databaseService.starredIdsForServer(serverId);
            for (StarredId starred in dbStarredIds) {
              int id = starred.articleId;
              Article? a = await widget.databaseService.article(id);
              if (a == null) {
                missingIds.add(id.toString());
              }
            }

            showStatus("Fetching all articles");
            //Fetch and insert new article contents
            if (missingIds.isNotEmpty) {
              List<Article> newArticles =
                  await widget.api.fetchNewArticleContents(baseUrl, auth, missingIds) ?? [];
              for (Article newArticle in newArticles) {
                var document = parse(newArticle.summaryContent);
                List<dynamic> images = document.getElementsByTagName("img");
                if (images.isNotEmpty) {
                  bool firstImageSet = false;
                  for (var img in images) {
                    if (img.attributes.containsKey("src") &&
                        !img.attributes['src']!.startsWith('data:image')) {
                      String imageUrl = img.attributes['src']!;
                      // widget.api.cacheImages(newArticle.imageUrl);
                      liImagesToCache.add(imageUrl);
                      if (!firstImageSet) {
                        newArticle.imageUrl = imageUrl;
                        firstImageSet = true; // Mark the first image as set
                      }
                    }
                  }
                }
                Feed feed = await widget.databaseService.feed(newArticle.originStreamId);
                newArticle.feedId = feed.id2 ?? 0;
                newArticle.serverId = serverId;
                newArticle.id2 = int.parse(newArticle.id!.split("/").last, radix: 16);

                // newArticle.id2 = getId2(newArticle.id!);
                if (dbArticles.isEmpty ||
                    (dbArticles.isNotEmpty &&
                        dbArticles
                            .where((x) => x.id == newArticle.id && x.serverId == serverId)
                            .isEmpty)) {
                  // widget.databaseService.insertArticle(newArticle);

                  List<String> articleCategories =
                      widget.utils.castToListOfStrings(jsonDecode(newArticle.categories));
                  await widget.databaseService
                      .insertArticleWithCategories(newArticle, articleCategories);
                }
              }
            }
          }
        }
      }
    } on Exception {
      // Handle error
      log("Server feed Error");
    } finally {
      // List<Server> serverList = await widget.databaseService.servers();
      // favCategoryEntries = [];
      // newCategoryEntries = [];
      // allCategoryEntries = [];
      // if (serverList.isNotEmpty) {
      //   for (Server server in serverList) {
      //     if (server.baseUrl != "localhost") {
      //       showStatus("Fetching all articles.");
      //       favCategoryEntries.addAll(
      //           await widget.databaseService.getCategoryEntriesWithStarredArticles(server.id ?? 0));
      //       showStatus("Fetching all articles..");
      //       newCategoryEntries.addAll(
      //           await widget.databaseService.getCategoryEntriesWithNewArticles(server.id ?? 0));
      //       showStatus("Fetching all articles...");
      //       allCategoryEntries
      //           .addAll(await widget.databaseService.getAllCategoryEntries(server.id ?? 0));
      showStatus("");
      //     }
      //   }
      setState(() {
        // isLocalDBLoading = false;
        isWebLoading = false;
      });
    }
  }

  Future<void> _cacheImages() async {
    setState(() {
      status = "Caching Images";
    });
    await widget.api.cacheImages(liImagesToCache.toList());
    liImagesToCache = {};
    setState(() {
      status = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    PersistentTabController controller;
    controller = PersistentTabController(initialIndex: 1);

    return Selector<ThemeProvider, AppTheme>(
        selector: (_, themeProvider) => themeProvider.theme,
        builder: (_, theme, __) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                "Feederr",
                style: TextStyle(
                  color: Color(theme.primaryColor),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(10.0),
                child: status != ""
                    ? (Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(status),
                        CupertinoActivityIndicator(
                          color: Color(theme.primaryColor),
                          radius: 10,
                        ),
                      ]))
                    : Container(),
              ),
              actions: <Widget>[
                IconButton(
                  color: Color(theme.primaryColor),
                  icon: const Icon(CupertinoIcons.add),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: () => {
                    HapticFeedback.mediumImpact(),
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) {
                          return Scaffold(
                            // extendBodyBehindAppBar: true,
                            appBar: AppBar(
                              backgroundColor: Color(theme.surfaceColor).withAlpha(56),
                              elevation: 0,
                              title: Text(
                                'Accounts',
                                style: TextStyle(
                                  color: Color(theme.textColor),
                                ),
                                overflow: TextOverflow.fade,
                              ),
                              // flexibleSpace:
                              // ClipRect(
                              //   child: BackdropFilter(
                              //     filter: ImageFilter.blur(
                              //       sigmaX: 36,
                              //       sigmaY: 36,
                              //     ),
                              //     child: Container(
                              //       color: Colors.transparent,
                              //     ),
                              //   ),
                              // ),
                            ),
                            body: ServerList(
                              databaseService: widget.databaseService,
                              api: widget.api,
                            ),
                          );
                        },
                      ),
                    ),
                  },
                ),
                IconButton(
                  color: Color(theme.primaryColor),
                  icon: const Icon(CupertinoIcons.settings_solid),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) {
                          return Settings();
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
            body: PersistentTabView(
              context,
              controller: controller,
              screens: _buildScreens(
                refreshFeeds,
                favServerCatogoriesProvider,
                newServerCatogoriesProvider,
                allServerCatogoriesProvider,
                favFeedsProvider,
                newFeedsProvider,
                allFeedsProvider,
                widget.api,
                widget.databaseService,
              ),
              items: _navBarsItems(theme),
              hideNavigationBarWhenKeyboardAppears: true,
              padding: const EdgeInsets.only(top: 8),
              backgroundColor: Color(theme.secondaryColor),
              isVisible: true,
              animationSettings: const NavBarAnimationSettings(
                navBarItemAnimation: ItemAnimationSettings(
                  // Navigation Bar's items animation properties.
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInCirc,
                ),
                screenTransitionAnimation: ScreenTransitionAnimationSettings(
                  // Screen transition animation on change of selected tab.
                  animateTabTransition: true,
                  duration: Duration(milliseconds: 300),
                  screenTransitionAnimationType: ScreenTransitionAnimationType.slide,
                ),
              ),
              confineToSafeArea: true,
              navBarHeight: kBottomNavigationBarHeight,
              navBarStyle: NavBarStyle
                  .style12, // Choose the nav bar style with this property 7,12,13 are fav
            ),
          );
        });
  }
}

List<Widget> _buildScreens(
  VoidCallback refreshFeeds,
  ServerCatogoriesProvider favCatEntriesProvider,
  ServerCatogoriesProvider newCatEntriesProvider,
  ServerCatogoriesProvider allCatEntriesProvider,
  LocalFeedsProvider localFavFeedsProvider,
  LocalFeedsProvider localNewFeedsProvider,
  LocalFeedsProvider localAllFeedsProvider,
  APIService api,
  DatabaseService databaseService,
) {
  return [
    isLocalDBLoading
        ? const CupertinoActivityIndicator(
            radius: 20.0,
            color: Color.fromRGBO(76, 2, 232, 1),
          )
        : MultiProvider(
            providers: [
              ChangeNotifierProvider<ServerCatogoriesProvider>(
                create: (_) => favCatEntriesProvider,
              ),
              ChangeNotifierProvider<LocalFeedsProvider>(
                create: (_) => localFavFeedsProvider,
              ),
            ],
            child: TabEntry(
              refreshParent: refreshFeeds,
              path: 'fav',
              api: api,
              databaseService: databaseService,
            ),
          ),
    isLocalDBLoading
        ? const CupertinoActivityIndicator(
            radius: 20.0,
            color: Color.fromRGBO(76, 2, 232, 1),
          )
        : MultiProvider(
            providers: [
              ChangeNotifierProvider<ServerCatogoriesProvider>(
                create: (_) => newCatEntriesProvider,
              ),
              ChangeNotifierProvider<LocalFeedsProvider>(
                create: (_) => localNewFeedsProvider,
              ),
            ],
            child: TabEntry(
              refreshParent: refreshFeeds,
              path: 'new',
              api: api,
              databaseService: databaseService,
            ),
          ),
    isLocalDBLoading
        ? const CupertinoActivityIndicator(
            radius: 20.0,
            color: Color.fromRGBO(76, 2, 232, 1),
          )
        : MultiProvider(
            providers: [
              ChangeNotifierProvider<ServerCatogoriesProvider>(
                create: (_) => allCatEntriesProvider,
              ),
              ChangeNotifierProvider<LocalFeedsProvider>(
                create: (_) => localAllFeedsProvider,
              ),
            ],
            child: TabEntry(
              refreshParent: refreshFeeds,
              path: 'all',
              api: api,
              databaseService: databaseService,
            ),
          ),
  ];
}

List<PersistentBottomNavBarItem> _navBarsItems(AppTheme theme) {
  return [
    PersistentBottomNavBarItem(
      icon: const Icon(CupertinoIcons.star),
      title: ("Starred"),
      onSelectedTabPressWhenNoScreensPushed: () => {
        HapticFeedback.mediumImpact(),
      },
      activeColorPrimary: Color(theme.primaryColor),
      inactiveColorPrimary: Color(theme.textColor),
      activeColorSecondary: Color(theme.primaryColor),
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(CupertinoIcons.circle),
      title: ("New"),
      activeColorPrimary: const Color.fromARGB(255, 0, 0, 0),
      inactiveColorPrimary: Color(theme.textColor),
      activeColorSecondary: Color(theme.primaryColor),
      // routeAndNavigatorSettings: const RouteAndNavigatorSettings(
      //   initialRoute: "/new",
      // ),
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(CupertinoIcons.line_horizontal_3_decrease),
      title: ("All"),
      activeColorPrimary: const Color.fromARGB(255, 0, 0, 0),
      inactiveColorPrimary: Color(theme.textColor),
      activeColorSecondary: Color(theme.primaryColor),
      // routeAndNavigatorSettings: const RouteAndNavigatorSettings(
      //   initialRoute: "/new",
      // ),
    ),
  ];
}
