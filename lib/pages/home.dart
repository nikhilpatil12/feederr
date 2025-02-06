import 'dart:convert';
import 'dart:core';
import 'dart:developer';
import 'dart:ui';
import 'package:dart_rss/dart_rss.dart';
import 'package:blazefeeds/models/article.dart';
import 'package:blazefeeds/models/feed.dart';
import 'package:blazefeeds/models/categories/categoryentry.dart';
import 'package:blazefeeds/models/local_feeds/local_article.dart';
import 'package:blazefeeds/models/local_feeds/local_feed.dart';
import 'package:blazefeeds/models/local_feeds/local_feedentry.dart';
import 'package:blazefeeds/models/local_feeds/rss_feeds.dart';
import 'package:blazefeeds/models/tagged_id.dart';
import 'package:blazefeeds/models/unread.dart';
import 'package:blazefeeds/models/server.dart';
import 'package:blazefeeds/models/starred.dart';
import 'package:blazefeeds/models/tag.dart';
import 'package:blazefeeds/pages/settings/add_server.dart';
import 'package:blazefeeds/pages/article_tab.dart';
import 'package:blazefeeds/providers/individual_local_feed_provider.dart';
import 'package:blazefeeds/providers/server_categories_provider.dart';
import 'package:blazefeeds/providers/status_provider.dart';
import 'package:blazefeeds/utils/apiservice.dart';
import 'package:blazefeeds/utils/dbhelper.dart';
import 'package:blazefeeds/providers/theme_provider.dart';
import 'package:blazefeeds/utils/utils.dart';
import 'package:blazefeeds/widgets/status.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html/parser.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:blazefeeds/pages/settings.dart';
import 'package:blazefeeds/models/app_theme.dart';
import 'package:provider/provider.dart';

// bool isWebLoading = false;
// bool isLocalDBLoading = false;
// bool isLocalFeedLoading = false;

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final APIService api;
  late final DatabaseService databaseService;
  late final AppUtils utils;
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
  // List<IndividualLocalFeedProvider> allFeedsProvider = [];
  // List<IndividualLocalFeedProvider> newFeedsProvider = [];
  // List<IndividualLocalFeedProvider> favFeedsProvider = [];
  late LocalFeedsProvider allFeedsProvider;
  late LocalFeedsProvider newFeedsProvider;
  late LocalFeedsProvider favFeedsProvider;
  List<LocalFeedEntry> localFavFeeds = [];
  List<LocalFeedEntry> localNewFeeds = [];
  List<LocalFeedEntry> localAllFeeds = [];
  Set<String> liImagesToCache = {};

  late final AnimationController _animationController;
  final MenuController _menuController = MenuController();
  bool initialBuild = true;

  void refreshFeeds() async {
    liImagesToCache = {};
    log("Refreshing feeds");
    if (!initialBuild) {
      utils.showStatus(context, "Syncing feeds");
    }
    await _fetchDBServerFeeds();
    await _fetchLocalFeedList();
    await _fetchServerFeeds();
    await _fetchDBServerFeeds();
    log("Images to cache: ${liImagesToCache.length}");
    await _cacheImages();
    log("Refreshed feeds");
    utils.showStatus(context, "");
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    allFeedsProvider = LocalFeedsProvider();
    newFeedsProvider = LocalFeedsProvider();
    favFeedsProvider = LocalFeedsProvider();
    api = APIService();
    databaseService = DatabaseService();
    utils = AppUtils();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.dismissed) {
          // The moment the menu is closed, it will no longer be on the screen or animatable.
          // To allow for a closing animation, we wait until our closing animation is finished before
          // we close the menu anchor.
          _menuController.close();
        } else if (!_menuController.isOpen) {
          // The menu should be open while the animation status is forward, completed, or reverse
          _menuController.open();
        }
      });

    // isWebLoading = true;
    // isLocalDBLoading = true;
    // isLocalFeedLoading = true;
    // _fetchDBServerFeeds();
    // _fetchLocalFeedList();
    // _fetchServerFeeds();
    // _cacheImages();
    refreshFeeds();
    initialBuild = false;
    super.initState();
  }

  Future<void> _fetchLocalFeedList() async {
    localAllFeeds = [];
    localNewFeeds = [];
    localFavFeeds = [];
    List<RssFeedUrl> feedList = await databaseService.rssFeeds();
    for (RssFeedUrl feed in feedList) {
      LocalFeed? localFeed = await databaseService.localFeedByUrl(feed.baseUrl);
      if (localFeed != null) {
        List<LocalArticle> allArticles = await databaseService.localArticlesByLocalFeed(localFeed);
        // localAllFeeds.add(
        //   LocalFeedEntry(
        //     feed: localFeed,
        //     feedUrl: feed,
        //     articles: allArticles,
        //     count: allArticles.length,
        //   ),
        // );
        allFeedsProvider.addFeedProvider(
          feed.baseUrl,
          IndividualLocalFeedProvider(
              feedEntry: LocalFeedEntry(
                feed: localFeed,
                feedUrl: feed,
                articles: allArticles,
                // count: allArticles.length,
              ),
              path: "all"),
        );

        List<LocalArticle> newArticles =
            await databaseService.localUnreadArticlesByLocalFeed(localFeed);
        if (newArticles.isNotEmpty || allArticles.isEmpty) {
          localNewFeeds.add(
            LocalFeedEntry(
              feed: localFeed,
              feedUrl: feed,
              articles: newArticles,
              // count: newArticles.length,
            ),
          );
          newFeedsProvider.addFeedProvider(
            feed.baseUrl,
            IndividualLocalFeedProvider(
                feedEntry: LocalFeedEntry(
                  feed: localFeed,
                  feedUrl: feed,
                  articles: newArticles,
                  // count: allArticles.length,
                ),
                path: 'new'),
          );
        }
        List<LocalArticle> starredArticles =
            await databaseService.localStarredArticlesByLocalFeed(localFeed);
        if (starredArticles.isNotEmpty) {
          localFavFeeds.add(
            LocalFeedEntry(
              feed: localFeed,
              feedUrl: feed,
              articles: starredArticles,
              // count: starredArticles.length,
            ),
          );

          favFeedsProvider.addFeedProvider(
            feed.baseUrl,
            IndividualLocalFeedProvider(
              feedEntry: LocalFeedEntry(
                feed: localFeed,
                feedUrl: feed,
                articles: allArticles,
                // count: allArticles.length,
              ),
              path: 'fav',
            ),
          );
        }
      }
    }

    // allFeedsProvider.add(IndividualLocalFeedProvider(localAllFeeds));
    // newFeedsProvider.updateCategories(localNewFeeds);
    // favFeedsProvider.updateCategories(localFavFeeds);
    // setState(() {
    //   isLocalFeedLoading = false;
    // });
  }

  Future<void> _fetchDBServerFeeds() async {
    favCategoryEntries = [];
    allCategoryEntries = [];
    newCategoryEntries = [];
    List<Server> serverList = await databaseService.servers();

    if (serverList.isNotEmpty) {
      for (Server server in serverList) {
        if (server.baseUrl != "localhost") {
          int serverId = server.id ?? 0;
          favCategoryEntries
              .addAll(await databaseService.getCategoryEntriesWithStarredArticles(serverId));
          allCategoryEntries.addAll(await databaseService.getAllCategoryEntries(serverId));
          newCategoryEntries
              .addAll(await databaseService.getCategoryEntriesWithNewArticles(serverId));
          // setState(() {
          //   isLocalDBLoading = false;
          // });
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
            utils.showStatus(context, "Fetching feeds");
            //Getting feedlist from server(s)
            List<Feed> feedList = await api.fetchFeedList(baseUrl, auth) ?? [];
            dbFeeds = await databaseService.feedsByServerId(serverId);

            dbTags = await databaseService.tagsForServer(serverId);
            dbUnreadIds = await databaseService.unreadIdsForServer(serverId);
            dbStarredIds = await databaseService.starredIdsForServer(serverId);
            dbArticles = await databaseService.articlesForServer(serverId);

            // favCategoryEntries.addAll(
            //     await databaseService.getCategoryEntriesWithStarredArticles(serverId));
            // allCategoryEntries.addAll(await databaseService.getAllCategoryEntries(serverId));
            // newCategoryEntries
            //     .addAll(await databaseService.getCategoryEntriesWithNewArticles(serverId));
            // setState(() {
            //   isLocalDBLoading = false;
            // });
            //Adding new feeds to db
            for (Feed feed in feedList) {
              //saving to DB
              feed.serverId = serverId;
              Feed? dF = await databaseService.feedByServerAndFeedId(serverId, feed.id);
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
            dbFeeds = await databaseService.feedsByServerId(serverId);
            //Removing old feeds from db
            if (dbFeeds.isNotEmpty) {
              for (Feed feed in dbFeeds) {
                if (feedList.where((x) => x.id == feed.id && x.serverId == serverId).isEmpty) {
                  await databaseService.deleteFeed(feed.id);
                }
              }
            }
            dbFeeds = await databaseService.feedsByServerId(serverId);
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
            utils.showStatus(context, "Fetching folders");
            //Getting taglist from server(s)
            List<Tag> tagList = await api.fetchTagList(baseUrl, auth) ?? [];
            //add new tags from server(s)
            for (Tag tag in tagList) {
              //saving to DB
              if (tag.type == "folder") {
                tag.serverId = serverId;
                if (dbTags.isEmpty ||
                    (dbTags.isNotEmpty &&
                        dbTags.where((x) => x.id == tag.id && x.serverId == serverId).isEmpty)) {
                  await databaseService.insertTag(tag);
                }
              }
            }
            dbTags = await databaseService.tagsForServer(serverId);
            //Removing old tags from db
            if (dbTags.isNotEmpty) {
              for (Tag tag in dbTags) {
                if (tagList.where((x) => x.id == tag.id && x.serverId == serverId).isEmpty) {
                  await databaseService.deleteTag(tag.id);
                }
              }
            }
            dbTags = await databaseService.tagsForServer(serverId);
            utils.showStatus(context, "Fetching unread items");
            //Get Unread/New Ids
            List<UnreadId> unreadIds = await api.fetchUnreadIds(baseUrl, auth) ?? [];
            //Saving newids to db
            for (UnreadId id in unreadIds) {
              //saving to DB
              id.serverId = serverId;
              if (dbUnreadIds.isEmpty ||
                  (dbUnreadIds.isNotEmpty &&
                      dbUnreadIds
                          .where((x) => x.articleId == id.articleId && x.serverId == serverId)
                          .isEmpty)) {
                await databaseService.insertUnreadId(id);
              }
            }
            dbUnreadIds = await databaseService.unreadIdsForServer(serverId);
            //Removing old ids from db
            if (dbUnreadIds.isNotEmpty) {
              for (UnreadId id in dbUnreadIds) {
                if (id.serverId != 0) {
                  if (unreadIds
                      .where((x) => x.articleId == id.articleId && x.serverId == serverId)
                      .isEmpty) {
                    await databaseService.deleteUnreadId(id.articleId);
                  }
                }
              }
            }
            dbUnreadIds = await databaseService.unreadIdsForServer(serverId);

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
              List<TaggedId>? taggedIds = await api.fetchTaggedIds(baseUrl, auth, tag.id);
              //Adding new tagged article ids to db
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
            List<StarredId> newStarredIds = await api.fetchStarredIds(baseUrl, auth) ?? [];
            //Saving new starred ids to db
            for (StarredId id in newStarredIds) {
              //saving to DB
              id.serverId = serverId;
              if (dbStarredIds.isEmpty ||
                  (dbStarredIds.isNotEmpty &&
                      dbStarredIds
                          .where((x) => x.articleId == id.articleId && x.serverId == serverId)
                          .isEmpty)) {
                await databaseService.insertStarredId(id);
              }
            }
            dbStarredIds = await databaseService.starredIdsForServer(serverId);
            //Removing old ids from db
            if (dbStarredIds.isNotEmpty) {
              for (StarredId id in dbStarredIds) {
                if (id.serverId != 0) {
                  if (newStarredIds
                      .where((x) => x.articleId == id.articleId && x.serverId == serverId)
                      .isEmpty) {
                    await databaseService.deleteStarredId(id.articleId);
                  }
                }
              }
            }
            dbStarredIds = await databaseService.starredIdsForServer(serverId);
            for (StarredId starred in dbStarredIds) {
              int id = starred.articleId;
              Article? a = await databaseService.article(id);
              if (a == null) {
                missingIds.add(id.toString());
              }
            }

            utils.showStatus(context, "Fetching all articles");
            //Fetch and insert new article contents
            if (missingIds.isNotEmpty) {
              List<Article> newArticles =
                  await api.fetchNewArticleContents(baseUrl, auth, missingIds) ?? [];
              for (Article newArticle in newArticles) {
                var document = parse(newArticle.summaryContent);
                List<dynamic> images = document.getElementsByTagName("img");
                if (images.isNotEmpty) {
                  bool firstImageSet = false;
                  for (var img in images) {
                    if (img.attributes.containsKey("src") &&
                        !img.attributes['src']!.startsWith('data:image')) {
                      String imageUrl = img.attributes['src']!;
                      // api.cacheImages(newArticle.imageUrl);
                      liImagesToCache.add(imageUrl);
                      if (!firstImageSet) {
                        newArticle.imageUrl = imageUrl;
                        firstImageSet = true; // Mark the first image as set
                      }
                    }
                  }
                }
                Feed feed = await databaseService.feed(newArticle.originStreamId);
                newArticle.feedId = feed.id2 ?? 0;
                newArticle.serverId = serverId;
                newArticle.id2 = int.parse(newArticle.id!.split("/").last, radix: 16);

                // newArticle.id2 = getId2(newArticle.id!);
                if (dbArticles.isEmpty ||
                    (dbArticles.isNotEmpty &&
                        dbArticles
                            .where((x) => x.id == newArticle.id && x.serverId == serverId)
                            .isEmpty)) {
                  // databaseService.insertArticle(newArticle);

                  List<String> articleCategories =
                      utils.castToListOfStrings(jsonDecode(newArticle.categories));
                  await databaseService.insertArticleWithCategories(newArticle, articleCategories);
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
      // List<Server> serverList = await databaseService.servers();
      // favCategoryEntries = [];
      // newCategoryEntries = [];
      // allCategoryEntries = [];
      // if (serverList.isNotEmpty) {
      //   for (Server server in serverList) {
      //     if (server.baseUrl != "localhost") {
      //       utils.showStatus(context, "Fetching all articles.");
      //       favCategoryEntries.addAll(
      //           await databaseService.getCategoryEntriesWithStarredArticles(server.id ?? 0));
      //       utils.showStatus(context, "Fetching all articles..");
      //       newCategoryEntries.addAll(
      //           await databaseService.getCategoryEntriesWithNewArticles(server.id ?? 0));
      //       utils.showStatus(context, "Fetching all articles...");
      //       allCategoryEntries
      //           .addAll(await databaseService.getAllCategoryEntries(server.id ?? 0));
      utils.showStatus(context, "");
      //     }
      //   }
      // setState(() {
      //   // isLocalDBLoading = false;
      //   isWebLoading = false;
      // });
    }
  }

  Future<void> _cacheImages() async {
    utils.showStatus(context, "Caching Images");
    await api.cacheImages(liImagesToCache.toList());
    liImagesToCache = {};
    utils.showStatus(context, "");
  }

  @override
  Widget build(BuildContext context) {
    PersistentTabController tabController;
    tabController = PersistentTabController(initialIndex: 1);

    return Selector<ThemeProvider, AppTheme>(
        selector: (_, themeProvider) => themeProvider.theme,
        builder: (_, theme, __) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                "Blaze Feeds",
                style: TextStyle(
                  color: Color(theme.primaryColor),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(10.0),
                child: Status(),
              ),
              actions: <Widget>[
                MenuAnchor(
                  controller: _menuController,
                  onClose: _animationController.reset,
                  onOpen: _animationController.forward,
                  style: MenuStyle(
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      backgroundColor: WidgetStatePropertyAll(Colors.transparent),
                      side: WidgetStatePropertyAll(
                        BorderSide(color: Color(theme.textColor).withAlpha(50)),
                      ),
                      elevation: WidgetStatePropertyAll(0),
                      padding: WidgetStatePropertyAll(EdgeInsets.zero)),
                  menuChildren: [
                    SizeTransition(
                      sizeFactor: _animationController,
                      child: FadeTransition(
                        opacity: _animationController,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Column(
                              children: <Widget>[
                                MenuItemButton(
                                  onPressed: () {
                                    HapticFeedback.mediumImpact();
                                    _dialogBuilder(context, theme);
                                  },
                                  leadingIcon: Icon(Icons.rss_feed_outlined),
                                  child: const Text('Add Feed'),
                                ),
                                Divider(
                                  height: 1,
                                  thickness: 0.5,
                                  color: Color(theme.textColor).withAlpha(50),
                                ),
                                MenuItemButton(
                                  leadingIcon: Icon(CupertinoIcons.person_add),
                                  onPressed: () {
                                    HapticFeedback.mediumImpact();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute<void>(
                                        builder: (BuildContext context) {
                                          return Scaffold(
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
                                            ),
                                            body: ServerList(),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: const Text('Add Accounts'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  child: IconButton(
                    color: Color(theme.primaryColor),
                    icon: const Icon(CupertinoIcons.add),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onPressed: () => {
                      HapticFeedback.mediumImpact(),
                      if (_animationController.status
                          case AnimationStatus.forward || AnimationStatus.completed)
                        {
                          _animationController.reverse(),
                        }
                      else
                        {
                          _animationController.forward(),
                        }
                    },
                  ),
                ),
                IconButton(
                    color: Color(theme.primaryColor),
                    icon: const Icon(Icons.sync_sharp),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      refreshFeeds();
                    }),
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
              decoration: NavBarDecoration(
                border: Border.all(width: 0.5, color: Color(theme.textColor).withAlpha(128)),
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              controller: tabController,
              screens: _buildScreens(
                refreshFeeds,
                favServerCatogoriesProvider,
                newServerCatogoriesProvider,
                allServerCatogoriesProvider,
                favFeedsProvider,
                newFeedsProvider,
                allFeedsProvider,
                api,
                databaseService,
              ),
              items: _navBarsItems(theme),
              margin: EdgeInsets.only(
                left: MediaQuery.sizeOf(context).width * 0.25,
                right: MediaQuery.sizeOf(context).width * 0.25,
                bottom: MediaQuery.sizeOf(context).height * 0.03,
              ),
              hideNavigationBarWhenKeyboardAppears: true,
              // padding: const EdgeInsets.only(bottom: 8),
              backgroundColor: Color(theme.secondaryColor),
              isVisible: true,
              animationSettings: const NavBarAnimationSettings(
                navBarItemAnimation: ItemAnimationSettings(
                  // Navigation Bar's items animation properties.
                  duration: Duration(milliseconds: 300),
                  curve: Curves.decelerate,
                ),
                screenTransitionAnimation: ScreenTransitionAnimationSettings(
                  // Screen transition animation on change of selected tab.
                  animateTabTransition: true,
                  duration: Duration(milliseconds: 300),
                  screenTransitionAnimationType: ScreenTransitionAnimationType.slide,
                ),
              ),
              // confineToSafeArea: true,
              navBarHeight: kBottomNavigationBarHeight,
              navBarStyle: NavBarStyle
                  .style12, // Choose the nav bar style with this property 3, 7, 9, 12,13 are fav
            ),
          );
        });
  }

  Future<void> _dialogBuilder(BuildContext context, AppTheme theme) {
    TextEditingController _controller = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(20),
            contentPadding: EdgeInsets.all(0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  padding: EdgeInsets.all(20),
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: Color(theme.secondaryColor).withAlpha(50),
                    border: Border.all(width: 0.5, color: Color(theme.textColor).withAlpha(128)),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  child: Text(
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(theme.primaryColor),
                    ),
                    'Subscribe',
                  ),
                  // IconButton(
                  //   onPressed: () => Navigator.pop(context),
                  //   icon: Icon(Icons.close),
                  //   highlightColor: Colors.transparent,
                  // ),
                  // ],
                ),
              ),
            ),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: Color(theme.secondaryColor).withAlpha(50),
                      border: Border.all(width: 0.5, color: Color(theme.textColor).withAlpha(128)),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(
                          color: Color(theme.primaryColor),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          child: Text('RSS FEED'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          child: TextField(
                            enableSuggestions: false,
                            controller: _controller,
                            // autofocus: true,
                            minLines: 1,
                            maxLines: 3,
                            // expands: true,
                            decoration: InputDecoration(
                              floatingLabelBehavior: FloatingLabelBehavior.never,
                              labelStyle: TextStyle(color: Color(theme.textColor).withAlpha(150)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              label: Text('example.com/rss'),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                          child: SizedBox(
                            width: MediaQuery.sizeOf(context).width,
                            child: CupertinoButton.filled(
                                child: Text('Subscribe'),
                                onPressed: () async {
                                  //TODO

                                  LocalFeed? localFeed =
                                      await databaseService.localFeedByUrl(_controller.text);
                                  try {
                                    if (localFeed == null) {
                                      var response =
                                          await api.fetchLocalFeedContents(_controller.text);
                                      if (response.statusCode == 200) {
                                        // print(json.encode(response.data));
                                        // try{
                                        String feedType = utils.detectFeedFormat(response.data);
                                        switch (feedType) {
                                          case 'Atom':
                                            await databaseService.insertRssFeed(
                                                RssFeedUrl(baseUrl: _controller.text));
                                            final channel = AtomFeed.parse(response.data);
                                            await databaseService.insertLocalFeed(LocalFeed(
                                                title: channel.title ?? "feed",
                                                categories: channel.categories.toString(),
                                                url: _controller.text,
                                                htmlUrl: channel.links.first.href ?? "",
                                                iconUrl: channel.icon ?? "",
                                                count: channel.items.length));
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: const Text('RSS Feed subscribed'),
                                                backgroundColor: Colors.greenAccent,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                              ),
                                            );
                                            break;
                                          case 'RSS 1.0':
                                            await databaseService.insertRssFeed(
                                                RssFeedUrl(baseUrl: _controller.text));
                                            final channel = Rss1Feed.parse(response.data);
                                            await databaseService.insertLocalFeed(LocalFeed(
                                                title: channel.title ?? "feed",
                                                categories: channel.dc?.subjects.toString() ?? "",
                                                url: _controller.text,
                                                htmlUrl: channel.link ?? "",
                                                iconUrl: channel.image ?? "",
                                                count: channel.items.length));
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: const Text('RSS Feed subscribed'),
                                                backgroundColor: Colors.greenAccent,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                              ),
                                            );
                                            break;
                                          case 'RSS 2.0':
                                            await databaseService.insertRssFeed(
                                                RssFeedUrl(baseUrl: _controller.text));
                                            final channel = RssFeed.parse(response.data);
                                            await databaseService.insertLocalFeed(LocalFeed(
                                                title: channel.title ?? "feed",
                                                categories: channel.categories.toString(),
                                                url: _controller.text,
                                                htmlUrl: channel.link ?? "",
                                                iconUrl: channel.image?.url ?? "",
                                                count: channel.items.length));
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: const Text('RSS Feed subscribed'),
                                                backgroundColor: Colors.greenAccent,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                              ),
                                            );
                                            break;
                                          default:
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: const Text('Unsupported feed'),
                                                backgroundColor: Colors.redAccent,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                              ),
                                            );
                                        }
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text('Feed already subscribed'),
                                          backgroundColor: Colors.redAccent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                        ),
                                      );
                                    }
                                  } on Exception catch (e) {
                                    log("Error: $e");
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Feed not supported'),
                                        backgroundColor: Colors.redAccent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                      ),
                                    );
                                  }
                                }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ]);
      },
    );
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
      // isLocalDBLoading
      //     ? const CupertinoActivityIndicator(
      //         radius: 20.0,
      //         color: Color.fromRGBO(76, 2, 232, 1),
      //       )
      //     :
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ServerCatogoriesProvider>(
            create: (_) => favCatEntriesProvider,
          ),
          ChangeNotifierProvider<LocalFeedsProvider>(
            create: (_) => localFavFeedsProvider,
          ),
          // ...List.generate(
          //   localFavFeedsProviders.,
          //   (index) => Provider<IndividualLocalFeedProvider>.value(
          //     value: localFavFeedsProviders[index],
          //   ),
          // ),
        ],
        child: TabEntry(
          refreshParent: refreshFeeds,
          path: 'fav',
          api: api,
          databaseService: databaseService,
        ),
      ),
      // isLocalDBLoading
      //     ? const CupertinoActivityIndicator(
      //         radius: 20.0,
      //         color: Color.fromRGBO(76, 2, 232, 1),
      //       )
      //     :
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ServerCatogoriesProvider>(
            create: (_) => newCatEntriesProvider,
          ),
          ChangeNotifierProvider<LocalFeedsProvider>(
            create: (_) => localNewFeedsProvider,
          ),
          // ...List.generate(
          //   localFavFeedsProviders.length,
          //   (index) =>
          //       Provider<IndividualLocalFeedProvider>.value(value: localNewFeedsProviders[index]),
          // ),
        ],
        child: TabEntry(
          refreshParent: refreshFeeds,
          path: 'new',
          api: api,
          databaseService: databaseService,
        ),
      ),
      // isLocalDBLoading
      //     ? const CupertinoActivityIndicator(
      //         radius: 20.0,
      //         color: Color.fromRGBO(76, 2, 232, 1),
      //       )
      //     :
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ServerCatogoriesProvider>(
            create: (_) => allCatEntriesProvider,
          ),
          ChangeNotifierProvider<LocalFeedsProvider>(
            create: (_) => localAllFeedsProvider,
          ),

          // Provider<List<IndividualLocalFeedProvider>>(
          //   create: (_) => List.generate(localFavFeedsProviders.length, (index) => localAllFeedsProviders[index]),
          // ),
          // ...List.generate(
          //   localFavFeedsProviders.length,
          //   (index) =>
          //       Provider<IndividualLocalFeedProvider>.value(value: localAllFeedsProviders[index]),
          // ),
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
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        opacity: 0.1,
        icon: const Icon(CupertinoIcons.star),
        title: ("Starred"),
        // onPressed: (_) => {
        //   HapticFeedback.mediumImpact(),
        // },
        activeColorPrimary: const Color.fromARGB(255, 0, 0, 0),
        inactiveColorPrimary: Color(theme.textColor),
        activeColorSecondary: Color(theme.primaryColor),
      ),
      PersistentBottomNavBarItem(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        opacity: 0.1,
        icon: const Icon(CupertinoIcons.circle),
        title: ("New"),
        activeColorPrimary: Color(theme.primaryColor),
        inactiveColorPrimary: Color(theme.textColor),
        activeColorSecondary: Color(theme.primaryColor),
        // onPressed: (_) => {
        //   HapticFeedback.mediumImpact(),
        //   // onItem
        // },
        // routeAndNavigatorSettings: const RouteAndNavigatorSettings(
        //   initialRoute: "/new",
        // ),
      ),
      PersistentBottomNavBarItem(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        opacity: 0.1,
        icon: const Icon(CupertinoIcons.line_horizontal_3_decrease),
        title: ("All"),
        activeColorPrimary: const Color.fromARGB(255, 0, 0, 0),
        inactiveColorPrimary: Color(theme.textColor),
        activeColorSecondary: Color(theme.primaryColor),
        // onPressed: (_) => {
        //   HapticFeedback.mediumImpact(),
        // },
        // routeAndNavigatorSettings: const RouteAndNavigatorSettings(
        //   initialRoute: "/new",
        // ),
      ),
    ];
  }
}
