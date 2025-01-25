import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
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
import 'package:feederr/utils/apiservice.dart';
import 'package:feederr/utils/dbhelper.dart';
import 'package:feederr/utils/providers/themeprovider.dart';
import 'package:feederr/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:html/dom.dart';
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
  const HomeScreen({
    super.key,
  });
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
  List<LocalFeedEntry> localFavFeeds = [];
  List<LocalFeedEntry> localNewFeeds = [];
  List<LocalFeedEntry> localAllFeeds = [];
  // var dio = Dio();

  final APIService api = APIService();
  final DatabaseService databaseService = DatabaseService();
  void showStatus(String newStatus) async {
    status = newStatus;
    setState(() {
      status = newStatus;
    });
  }

  void refreshFeeds() async {
    isWebLoading = true;
    isLocalDBLoading = true;
    isLocalFeedLoading = true;
    log("refreshing");
    await _fetchLocalFeedList();
    await _fetchServerFeeds();
    log("refreshed");
    // setState(() {});
  }

  @override
  void initState() {
    super.initState();
    log("refreshing");
    _fetchLocalFeedList();
    _fetchServerFeeds();
    log("refreshed");
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
      var response = await api.fetchLocalFeedContents(feed.baseUrl);
      if (response.statusCode == 200) {
        // print(json.encode(response.data));
        // try{
        LocalFeed? localFeed =
            await databaseService.localFeedByUrl(feed.baseUrl);
        String feedType = detectFeedFormat(response.data);
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
              }
              for (RssItem item in channel.items) {
                LocalArticle? article =
                    await databaseService.localArticle(item.guid ?? "");
                if (article == null) {
                  int id = await databaseService.insertLocalArticle(
                    LocalArticle(
                      id: item.guid,
                      originTitle: localFeed!.title,
                      crawlTimeMsec:
                          DateTime.now().millisecondsSinceEpoch.toString(),
                      serverId: localFeed.id ?? 0,
                      published: convertDateToGReader(item.pubDate ?? ""),
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
                  await databaseService
                      .insertUnreadId(UnreadId(articleId: id, serverId: 0));
                }
              }
              List<LocalArticle> allArticles =
                  await databaseService.localArticlesByLocalFeed(localFeed!);
              localAllFeeds.add(
                LocalFeedEntry(
                  feed: localFeed,
                  articles: allArticles,
                  count: allArticles.length,
                ),
              );
              List<LocalArticle> newArticles = await databaseService
                  .localUnreadArticlesByLocalFeed(localFeed);
              if (newArticles.isNotEmpty) {
                localNewFeeds.add(
                  LocalFeedEntry(
                    feed: localFeed,
                    articles: newArticles,
                    count: newArticles.length,
                  ),
                );
              }
              List<LocalArticle> starredArticles = await databaseService
                  .localStarredArticlesByLocalFeed(localFeed);
              if (starredArticles.isNotEmpty) {
                localFavFeeds.add(
                  LocalFeedEntry(
                    feed: localFeed,
                    articles: starredArticles,
                    count: starredArticles.length,
                  ),
                );
              }
            } catch (e) {
              log("RSS2 Feed Error:$e");
            }
            break;
          case "RSS 1.0":
            try {
              final channel = Rss1Feed.parse(response.data);
              LocalFeed? localFeed =
                  await databaseService.localFeedByUrl(feed.baseUrl);
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
                LocalArticle? article = await databaseService
                    .localArticle(item.dc?.identifier ?? "");
                if (article == null) {
                  int id = await databaseService.insertLocalArticle(
                    LocalArticle(
                      id: item.dc?.identifier,
                      originTitle: localFeed!.title,
                      crawlTimeMsec:
                          DateTime.now().millisecondsSinceEpoch.toString(),
                      serverId: localFeed.id ?? 0,
                      published: convertDateToGReader(item.dc?.date ?? ""),
                      title: item.title ?? "",
                      canonical: item.link ?? "",
                      alternate: "",
                      categories:
                          castToListOfStrings(item.dc?.subjects.toString())
                              .toString(),
                      summaryContent: item.content?.value ?? "",
                      author: item.dc?.creator ?? "",
                      imageUrl: item.content!.images.isNotEmpty
                          ? item.content!.images.first
                          : "",
                      isLocal: true,
                      isRead: false,
                      isStarred: false,
                    ),
                  );
                  // print(resp);
                  await databaseService
                      .insertUnreadId(UnreadId(articleId: id, serverId: 0));
                }
              }
              List<LocalArticle> allArticles =
                  await databaseService.localArticlesByLocalFeed(localFeed!);
              localAllFeeds.add(LocalFeedEntry(
                  feed: localFeed,
                  articles: allArticles,
                  count: allArticles.length));
              List<LocalArticle> newArticles = await databaseService
                  .localUnreadArticlesByLocalFeed(localFeed);
              if (newArticles.isNotEmpty) {
                localNewFeeds.add(
                  LocalFeedEntry(
                    feed: localFeed,
                    articles: newArticles,
                    count: newArticles.length,
                  ),
                );
              }
              List<LocalArticle> starredArticles = await databaseService
                  .localStarredArticlesByLocalFeed(localFeed);
              if (starredArticles.isNotEmpty) {
                localFavFeeds.add(
                  LocalFeedEntry(
                    feed: localFeed,
                    articles: starredArticles,
                    count: starredArticles.length,
                  ),
                );
              }
            } catch (e) {
              log("RSS1 Feed Error:$e");
            }
            break;
          case "Atom":
            try {
              final channel = AtomFeed.parse(response.data);
              LocalFeed? localFeed =
                  await databaseService.localFeedByUrl(feed.baseUrl);
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
                LocalArticle? article =
                    await databaseService.localArticle(item.id ?? "");
                if (article == null) {
                  var document = parse(item.content);
                  String imageUrl = "";
                  List<dynamic> images = document.getElementsByTagName("img");
                  if (images.isNotEmpty) {
                    for (var img in images) {
                      if (img.attributes.containsKey("src") &&
                          !img.attributes['src']!.startsWith('data:image')) {
                        imageUrl = img.attributes['src']!;
                        break; // Stop after finding the first valid image
                      }
                    }
                  }
                  int id = await databaseService.insertLocalArticle(
                    LocalArticle(
                      id: item.id,
                      crawlTimeMsec:
                          DateTime.now().millisecondsSinceEpoch.toString(),
                      originTitle: localFeed!.title,
                      serverId: localFeed.id ?? 0,
                      published: convertDateToGReader(item.published ?? ""),
                      title: item.title ?? "",
                      canonical: item.links.first.href ?? "",
                      alternate: "",
                      categories:
                          castToListOfStrings(item.categories).toString(),
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
                  await databaseService
                      .insertUnreadId(UnreadId(articleId: id, serverId: 0));
                }
              }
              List<LocalArticle> allArticles =
                  await databaseService.localArticlesByLocalFeed(localFeed!);
              localAllFeeds.add(
                LocalFeedEntry(
                    feed: localFeed,
                    articles: allArticles,
                    count: allArticles.length),
              );
              List<LocalArticle> newArticles = await databaseService
                  .localUnreadArticlesByLocalFeed(localFeed);
              if (newArticles.isNotEmpty) {
                localNewFeeds.add(
                  LocalFeedEntry(
                    feed: localFeed,
                    articles: newArticles,
                    count: newArticles.length,
                  ),
                );
              }
              List<LocalArticle> starredArticles = await databaseService
                  .localStarredArticlesByLocalFeed(localFeed);
              if (starredArticles.isNotEmpty) {
                localFavFeeds.add(
                  LocalFeedEntry(
                    feed: localFeed,
                    articles: starredArticles,
                    count: starredArticles.length,
                  ),
                );
              }
            } catch (e) {
              log("Atom Feed Error:$e");
            }
            break;
          default:
            break;
        }

        // print(channel.title);
        // print(channel.items.length);
        // return channel;
      } else {
        log("Error:${response.statusMessage}");
      }
    }
    //   List<LocalFeed> localFeeds =
    //         await databaseService.localFeeds();
    // for (LocalFeed localFeed in localFeeds){

    // }

    setState(() {
      isLocalFeedLoading = true;
    });
  }

  Future<void> _fetchServerFeeds() async {
    try {
      //Getting Server list
      List<Server> serverList = await databaseService.servers();

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
              auth = await api.userLogin(baseUrl, userName, password);
            }
            showStatus("Fetching feeds");
            //Getting feedlist from server(s)
            List<Feed> feedList = await api.fetchFeedList(baseUrl, auth) ?? [];
            dbFeeds = await databaseService.feedsByServerId(serverId);

            dbTags = await databaseService.tags();
            dbUnreadIds = await databaseService.unreadIds();
            dbStarredIds = await databaseService.starredIds();
            dbArticles = await databaseService.articles();

            favCategoryEntries =
                await databaseService.getCategoryEntriesWithStarredArticles();
            allCategoryEntries = await databaseService.getCategoryEntries();
            newCategoryEntries =
                await databaseService.getCategoryEntriesWithNewArticles();
            setState(() {
              isLocalDBLoading = false;
            });
            //Adding new feeds to db
            for (Feed feed in feedList) {
              //saving to DB
              feed.serverId = serverId;
              Feed? dF = await databaseService.feedByServerAndFeedId(
                  serverId, feed.id);
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
                await databaseService.insertFeed(feed);
              }
            }
            dbFeeds = await databaseService.feeds();
            //Removing old feeds from db
            if (dbFeeds.isNotEmpty) {
              for (Feed feed in dbFeeds) {
                if (feedList
                    .where((x) => x.id == feed.id && x.serverId == serverId)
                    .isEmpty) {
                  await databaseService.deleteFeed(feed.id);
                }
              }
            }
            dbFeeds = await databaseService.feeds();
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
              await databaseService.insertFeedWithCategories(feed, categories);
            }
            showStatus("Fetching folders");
            //Getting taglist from server(s)
            List<Tag> tagList = await api.fetchTagList(baseUrl, auth) ?? [];
            //add new tags from server(s)
            for (Tag tag in tagList) {
              //saving to DB
              if (tag.type == "folder") {
                tag.serverId = serverId;
                if (dbTags.isEmpty ||
                    (dbTags.isNotEmpty &&
                        dbTags
                            .where(
                                (x) => x.id == tag.id && x.serverId == serverId)
                            .isEmpty)) {
                  await databaseService.insertTag(tag);
                }
              }
            }
            dbTags = await databaseService.tags();
            //Removing old tags from db
            if (dbTags.isNotEmpty) {
              for (Tag tag in dbTags) {
                if (tagList
                    .where((x) => x.id == tag.id && x.serverId == serverId)
                    .isEmpty) {
                  await databaseService.deleteTag(tag.id);
                }
              }
            }
            dbTags = await databaseService.tags();
            showStatus("Fetching unread items");
            //Get Unread/New Ids
            List<UnreadId> unreadIds =
                await api.fetchUnreadIds(baseUrl, auth) ?? [];
            //Saving newids to db
            for (UnreadId id in unreadIds) {
              //saving to DB
              id.serverId = serverId;
              if (dbUnreadIds.isEmpty ||
                  (dbUnreadIds.isNotEmpty &&
                      dbUnreadIds
                          .where((x) =>
                              x.articleId == id.articleId &&
                              x.serverId == serverId)
                          .isEmpty)) {
                await databaseService.insertUnreadId(id);
              }
            }
            dbUnreadIds = await databaseService.unreadIds();
            //Removing old ids from db
            if (dbUnreadIds.isNotEmpty) {
              for (UnreadId id in dbUnreadIds) {
                if (id.serverId != 0) {
                  if (unreadIds
                      .where((x) =>
                          x.articleId == id.articleId && x.serverId == serverId)
                      .isEmpty) {
                    await databaseService.deleteUnreadId(id.articleId);
                  }
                }
              }
            }
            dbUnreadIds = await databaseService.unreadIds();

            //Add missing IDs from database to the API query sring
            List<String> missingIds = [];
            for (UnreadId unreadId in dbUnreadIds) {
              int id = unreadId.articleId;
              Article? a = await databaseService.article(id);
              if (a == null) {
                // missingIds += "i=$id&";
                missingIds.add(id.toString());
              }
            }

            for (Tag tag in dbTags) {
              List<TaggedId>? taggedIds =
                  await api.fetchTaggedIds(baseUrl, auth, tag.id);
              //Adding new tagged ids to db
              if (taggedIds != null && taggedIds.isNotEmpty) {
                for (TaggedId taggedId in taggedIds) {
                  int id = taggedId.articleId;
                  Article? a = await databaseService.article(id);
                  if (a == null) {
                    missingIds.add(id.toString());
                  }
                }
              }
            }
            // _showOverlay("Fetching new articles...");
            //Get starred Ids
            List<StarredId> newStarredIds =
                await api.fetchStarredIds(baseUrl, auth) ?? [];
            //Saving new starred ids to db
            for (StarredId id in newStarredIds) {
              //saving to DB
              id.serverId = serverId;
              if (dbStarredIds.isEmpty ||
                  (dbStarredIds.isNotEmpty &&
                      dbStarredIds
                          .where((x) =>
                              x.articleId == id.articleId &&
                              x.serverId == serverId)
                          .isEmpty)) {
                await databaseService.insertStarredId(id);
              }
            }
            dbStarredIds = await databaseService.starredIds();
            //Removing old ids from db
            if (dbStarredIds.isNotEmpty) {
              for (StarredId id in dbStarredIds) {
                if (id.serverId != 0) {
                  if (newStarredIds
                      .where((x) =>
                          x.articleId == id.articleId && x.serverId == serverId)
                      .isEmpty) {
                    await databaseService.deleteStarredId(id.articleId);
                  }
                }
              }
            }
            dbStarredIds = await databaseService.starredIds();
            for (StarredId starred in dbStarredIds) {
              int id = starred.articleId;
              Article? a = await databaseService.article(id);
              if (a == null) {
                missingIds.add(id.toString());
              }
            }

            showStatus("Fetching all articles");
            //Fetch and insert new article contents
            if (missingIds.isNotEmpty) {
              List<Article> newArticles = await api.fetchNewArticleContents(
                      baseUrl, auth, missingIds) ??
                  [];
              for (Article newArticle in newArticles) {
                var document = parse(newArticle.summaryContent);
                List<dynamic> images = document.getElementsByTagName("img");
                if (images.isNotEmpty) {
                  for (var img in images) {
                    if (img.attributes.containsKey("src") &&
                        !img.attributes['src']!.startsWith('data:image')) {
                      newArticle.imageUrl = img.attributes['src']!;
                      break; // Stop after finding the first valid image
                    }
                  }
                }
                Feed feed =
                    await databaseService.feed(newArticle.originStreamId);
                newArticle.feedId = feed.id2 ?? 0;
                newArticle.serverId = serverId;
                newArticle.id2 =
                    int.parse(newArticle.id!.split("/").last, radix: 16);

                // newArticle.id2 = getId2(newArticle.id!);
                if (dbArticles.isEmpty ||
                    (dbArticles.isNotEmpty &&
                        dbArticles
                            .where((x) =>
                                x.id == newArticle.id && x.serverId == serverId)
                            .isEmpty)) {
                  // databaseService.insertArticle(newArticle);

                  List<String> articleCategories =
                      castToListOfStrings(jsonDecode(newArticle.categories));
                  await databaseService.insertArticleWithCategories(
                      newArticle, articleCategories);
                }
              }
            }
          }
        }
      }
    } on Exception {
      // Handle error
      log("Invalid feed Error");
    } finally {
      showStatus("Fetching all articles.");
      favCategoryEntries =
          await databaseService.getCategoryEntriesWithStarredArticles();
      showStatus("Fetching all articles..");
      newCategoryEntries =
          await databaseService.getCategoryEntriesWithNewArticles();
      showStatus("Fetching all articles...");
      allCategoryEntries = await databaseService.getCategoryEntries();
      showStatus("");
      setState(() {
        isLocalDBLoading = false;
        isWebLoading = false;
      });
    }
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
                    ? (Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                              backgroundColor:
                                  Color(theme.surfaceColor).withAlpha(56),
                              elevation: 0,
                              title: Text(
                                'Accounts',
                                style: TextStyle(
                                  color: Color(theme.textColor),
                                ),
                                overflow: TextOverflow.fade,
                              ),
                              flexibleSpace: ClipRect(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 36,
                                    sigmaY: 36,
                                  ),
                                  child: Container(
                                    color: Colors.transparent,
                                  ),
                                ),
                              ),
                            ),
                            body: ServerList(
                              databaseService: databaseService,
                              api: api,
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
                          return Scaffold(
                            // extendBodyBehindAppBar: true,
                            appBar: AppBar(
                              backgroundColor:
                                  Color(theme.surfaceColor).withAlpha(56),
                              elevation: 0,
                              title: Text(
                                'Settings',
                                style: TextStyle(
                                  color: Color(theme.textColor),
                                ),
                                overflow: TextOverflow.fade,
                              ),
                              flexibleSpace: ClipRect(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 36,
                                    sigmaY: 36,
                                  ),
                                  child: Container(
                                    color: Colors.transparent,
                                  ),
                                ),
                              ),
                            ),
                            body: Settings(
                              databaseService: databaseService,
                              api: api,
                            ),
                          );
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
                favCategoryEntries,
                newCategoryEntries,
                allCategoryEntries,
                localFavFeeds,
                localNewFeeds,
                localAllFeeds,
                api,
                databaseService,
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
                  screenTransitionAnimationType:
                      ScreenTransitionAnimationType.slide,
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
    List<CategoryEntry> favCatEntries,
    List<CategoryEntry> newCatEntries,
    List<CategoryEntry> allCatEntries,
    List<LocalFeedEntry> localFavFeeds,
    List<LocalFeedEntry> localNewFeeds,
    List<LocalFeedEntry> localAllFeeds,
    APIService api,
    DatabaseService databaseService) {
  return [
    isLocalDBLoading
        ? const CupertinoActivityIndicator(
            radius: 20.0,
            color: Color.fromRGBO(76, 2, 232, 1),
          )
        : TabEntry(
            refreshParent: refreshFeeds,
            categories: favCatEntries,
            path: 'fav',
            api: api,
            databaseService: databaseService,
            localFeeds: localFavFeeds,
          ),
    isLocalDBLoading
        ? const CupertinoActivityIndicator(
            radius: 20.0,
            color: Color.fromRGBO(76, 2, 232, 1),
          )
        : TabEntry(
            refreshParent: refreshFeeds,
            categories: newCatEntries,
            path: 'new',
            api: api,
            databaseService: databaseService,
            localFeeds: localNewFeeds,
          ),
    isLocalDBLoading
        ? const CupertinoActivityIndicator(
            radius: 20.0,
            color: Color.fromRGBO(76, 2, 232, 1),
          )
        : TabEntry(
            refreshParent: refreshFeeds,
            categories: allCatEntries,
            path: 'all',
            api: api,
            databaseService: databaseService,
            localFeeds: localAllFeeds,
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
