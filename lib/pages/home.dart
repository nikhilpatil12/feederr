import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:feederr/main.dart';
import 'package:feederr/models/article.dart';
import 'package:feederr/models/feed.dart';
import 'package:feederr/models/tagged_id.dart';
import 'package:feederr/models/new.dart';
import 'package:feederr/models/server.dart';
import 'package:feederr/models/starred.dart';
import 'package:feederr/models/tag.dart';
import 'package:feederr/pages/add_server.dart';
import 'package:feederr/pages/all_articles.dart';
import 'package:feederr/pages/fav_articles.dart';
import 'package:feederr/pages/new_articles.dart';
import 'package:feederr/pages/starred_articles.dart';
import 'package:feederr/utils/api_utils.dart';
import 'package:feederr/utils/dbhelper.dart';
import 'package:feederr/utils/utils.dart';
import 'package:feederr/widgets/loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:feederr/pages/settings.dart';

bool isWebLoading = false;
bool isLocalLoading = false;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});
  final String title;
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<Feed> dbFeeds = [];
  List<Tag> dbTags = [];
  List<NewId> dbNewIds = [];
  List<StarredId> dbStarredIds = [];
  List<TaggedId> dbTaggedIds = [];
  List<Article> dbArticles = [];

  DatabaseService databaseService = DatabaseService();

  void refreshFeeds() async {
    await _fetchFeedList();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _fetchFeedList();
  }

  Future<void> _fetchFeedList() async {
    setState(() {
      isLocalLoading = true;
      isWebLoading = true;
    });
    try {
      //Getting Server list
      List<Server> serverList = await databaseService.servers();
      if (serverList.isNotEmpty) {
        String baseUrl = serverList[0].baseUrl;
        String auth = serverList[0].auth ?? '';
        int serverId = serverList[0].id ?? 0;

        //Getting feedlist from server(s)
        List<Feed> feedList = await fetchFeedList(baseUrl, auth) ?? [];
        dbFeeds = await databaseService.feeds();
        dbTags = await databaseService.tags();
        dbNewIds = await databaseService.newIds();
        dbStarredIds = await databaseService.starredIds();
        dbArticles = await databaseService.articles();
        setState(() {
          isLocalLoading = false;
        });
        //Adding new feeds to db
        for (Feed feed in feedList) {
          //saving to DB
          feed.serverId = serverId;
          if (dbFeeds.isEmpty ||
              (dbFeeds.isNotEmpty &&
                  dbFeeds
                      .where((x) => x.id == feed.id && x.serverId == serverId)
                      .isEmpty)) {
            databaseService.insertFeed(feed);
          }
        }
        dbFeeds = await databaseService.feeds();
        //Removing old feeds from db
        if (dbFeeds.isNotEmpty) {
          for (Feed feed in dbFeeds) {
            if (feedList
                .where((x) => x.id == feed.id && x.serverId == serverId)
                .isEmpty) {
              databaseService.deleteFeed(feed.id);
            }
          }
        }
        dbFeeds = await databaseService.feeds();
        for (Feed feed in dbFeeds) {
          List<String> categories = [];
          var feedCategories = jsonDecode(jsonDecode(feed.categories));

          if (feedCategories is List) {
            for (var feedCategory in feedCategories) {
              if (feedCategory is Map && feedCategory.containsKey('id')) {
                categories.add(feedCategory['id']);
              }
            }
          }
          databaseService.insertFeedWithCategories(feed, categories);
        }

        //Getting taglist from server(s)
        List<Tag> tagList = await fetchTagList(baseUrl, auth) ?? [];
        //add new tags from server(s)
        for (Tag tag in tagList) {
          //saving to DB
          if (tag.type == "folder") {
            tag.serverId = serverId;
            if (dbTags.isEmpty ||
                (dbTags.isNotEmpty &&
                    dbTags
                        .where((x) => x.id == tag.id && x.serverId == serverId)
                        .isEmpty)) {
              databaseService.insertTag(tag);
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
              databaseService.deleteTag(tag.id);
            }
          }
        }
        dbTags = await databaseService.tags();

        //Get Unread/New Ids
        List<NewId> unreadIds = await fetchUnreadIds(baseUrl, auth) ?? [];
        //Saving newids to db
        for (NewId id in unreadIds) {
          //saving to DB
          id.serverId = serverId;
          if (dbNewIds.isEmpty ||
              (dbNewIds.isNotEmpty &&
                  dbNewIds
                      .where((x) =>
                          x.articleId == id.articleId && x.serverId == serverId)
                      .isEmpty)) {
            databaseService.insertNewId(id);
          }
        }
        dbNewIds = await databaseService.newIds();
        //Removing old ids from db
        if (dbNewIds.isNotEmpty) {
          for (NewId id in dbNewIds) {
            if (unreadIds
                .where((x) =>
                    x.articleId == id.articleId && x.serverId == serverId)
                .isEmpty) {
              databaseService.deleteNewId(id.articleId);
            }
          }
        }
        dbNewIds = await databaseService.newIds();

        //Get stearred Ids
        List<StarredId> newStarredIds =
            await fetchStarredIds(baseUrl, auth) ?? [];
        //Saving new starred ids to db
        for (StarredId id in newStarredIds) {
          //saving to DB
          id.serverId = serverId;
          if (dbStarredIds.isEmpty ||
              (dbStarredIds.isNotEmpty &&
                  dbStarredIds
                      .where((x) =>
                          x.articleId == id.articleId && x.serverId == serverId)
                      .isEmpty)) {
            databaseService.insertStarredId(id);
          }
        }
        dbStarredIds = await databaseService.starredIds();
        //Removing old ids from db
        if (dbStarredIds.isNotEmpty) {
          for (StarredId id in dbStarredIds) {
            if (newStarredIds
                .where((x) =>
                    x.articleId == id.articleId && x.serverId == serverId)
                .isEmpty) {
              databaseService.deleteStarredId(id.articleId);
            }
          }
        }
        dbStarredIds = await databaseService.starredIds();

        //Getting for each tag/folder
        for (Tag t in dbTags) {
          dbTaggedIds = await databaseService.taggedIdsByTag(t.id);
          //Adding new tagged ids to db
          List<TaggedId> newTaggedIds =
              await fetchTaggedIds(baseUrl, auth, t.id) ?? [];
          for (TaggedId id in newTaggedIds) {
            id.serverId = serverId;
            id.tag = t.id;
            if (dbTaggedIds.isEmpty ||
                (dbTaggedIds.isNotEmpty &&
                    dbTaggedIds
                        .where((x) =>
                            x.articleId == id.articleId &&
                            x.serverId == serverId)
                        .isEmpty)) {
              databaseService.insertTaggedId(id);
            }
          }
          //Removing old ids from db
          dbTaggedIds = await databaseService.taggedIdsByTag(t.id);
          if (dbTaggedIds.isNotEmpty) {
            for (TaggedId id in dbTaggedIds) {
              if (newTaggedIds
                  .where((x) =>
                      x.articleId == id.articleId && x.serverId == serverId)
                  .isEmpty) {
                databaseService.deleteTaggedId(id.articleId);
              }
            }
          }
          dbTaggedIds = await databaseService.taggedIdsByTag(t.id);
          //TODO: Prepare data for tabs
          List<Article> s = await databaseService.allArticlesByTag(t.id);
          print(s.length);
        }

        //Fetch and insert new article contents
        if (dbNewIds.isNotEmpty) {
          String data = '';
          for (NewId id in dbNewIds) {
            String idString = id.articleId.toString();
            data += "i=$idString&";
          }
          List<Article> newArticles =
              await fetchNewArticleContents(baseUrl, auth, data) ?? [];
          for (Article newArticle in newArticles) {
            var document = parse(newArticle.summaryContent);
            List<dynamic> images = document.getElementsByTagName("img");
            if (images.isNotEmpty && images[0].attributes.containsKey("src")) {
              newArticle.imageUrl = images[0].attributes['src']!;
              newArticle.serverId = serverId;
              newArticle.id2 =
                  int.parse(newArticle.id!.split("/").last, radix: 16);
              if (dbArticles.isEmpty ||
                  (dbArticles.isNotEmpty &&
                      dbArticles
                          .where((x) =>
                              x.id == newArticle.id && x.serverId == serverId)
                          .isEmpty)) {
                // databaseService.insertArticle(newArticle);

                List<String> articleCategories =
                    castToListOfStrings(jsonDecode(newArticle.categories));
                databaseService.insertArticleWithCategories(
                    newArticle, articleCategories);
              }
            }
          }

          dbArticles = await databaseService.articles();
          //TODO: Sort Implementation, maybe lazy loading/pagination?
          dbArticles.sort((b, a) => a.published.compareTo(b.published));
          // print(dbArticles.length);
        }
      }
    } on Exception catch (e) {
      // Handle error
    } finally {
      setState(() {
        isLocalLoading = false;
        isWebLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    PersistentTabController controller;
    controller = PersistentTabController(initialIndex: 0);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(CupertinoIcons.add),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) {
                    return Scaffold(
                      appBar: AppBar(
                        title: const Text('Add Servers'),
                      ),
                      body: const ServerList(),
                    );
                  },
                ),
              ),
            },
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.settings_solid),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) {
                    return Scaffold(
                      appBar: AppBar(
                        title: const Text('Settings'),
                      ),
                      body: const Settings(),
                    );
                  },
                ),
              ),
            },
          ),
        ],
      ),
      body: PersistentTabView(
        context,
        controller: controller,
        screens: _buildScreens(refreshFeeds, dbArticles, dbTags, dbFeeds),
        items: _navBarsItems(),
        handleAndroidBackButtonPress: true, // Default is true.
        resizeToAvoidBottomInset:
            true, // This needs to be true if you want to move up the screen on a non-scrollable screen when keyboard appears. Default is true.
        stateManagement: true, // Default is true.
        hideNavigationBarWhenKeyboardAppears: true,
        padding: const EdgeInsets.only(top: 8),
        backgroundColor: const Color.fromARGB(255, 31, 31, 31),
        isVisible: true,
        animationSettings: const NavBarAnimationSettings(
          navBarItemAnimation: ItemAnimationSettings(
            // Navigation Bar's items animation properties.
            duration: Duration(milliseconds: 400),
            curve: Curves.ease,
          ),
          screenTransitionAnimation: ScreenTransitionAnimationSettings(
            // Screen transition animation on change of selected tab.
            animateTabTransition: true,
            duration: Duration(milliseconds: 200),
            screenTransitionAnimationType: ScreenTransitionAnimationType.fadeIn,
          ),
        ),
        confineToSafeArea: true,
        navBarHeight: kBottomNavigationBarHeight,
        navBarStyle:
            NavBarStyle.style7, // Choose the nav bar style with this property
      ),
    );
  }
}

List<Widget> _buildScreens(VoidCallback refreshFeeds,
    List<Article> starredArticles, List<Tag> tags, List<Feed> feeds) {
  return [
    // FavArticleList(
    //   refreshParent: refreshFeeds,
    //   articles: articles,
    // ),
    isLocalLoading
        ? const CupertinoActivityIndicator(
            radius: 20.0,
            color: Color.fromRGBO(76, 2, 232, 1),
          )
        : StarredArticleList(
            refreshParent: refreshFeeds,
            path: 'fav',
          ),
    isLocalLoading
        ? const CupertinoActivityIndicator(
            radius: 20.0,
            color: Color.fromRGBO(76, 2, 232, 1),
          )
        : FavArticleList(
            refreshParent: refreshFeeds,
            articles: starredArticles,
          ),
    // isLocalLoading
    //     ? const CupertinoActivityIndicator(
    //         radius: 20.0,
    //         color: Color.fromRGBO(76, 2, 232, 1),
    //       )
    //     : StarredArticleList(
    //         refreshParent: refreshFeeds,
    //         path: 'new',
    //       ),
    const AllArticleList()
  ];
}

List<PersistentBottomNavBarItem> _navBarsItems() {
  return [
    PersistentBottomNavBarItem(
      icon: const Icon(CupertinoIcons.star),
      title: ("Starred"),
      activeColorPrimary: const Color.fromARGB(255, 0, 0, 0),
      inactiveColorPrimary: CupertinoColors.systemGrey,
      activeColorSecondary: const Color.fromRGBO(76, 2, 232, 1),
      routeAndNavigatorSettings: const RouteAndNavigatorSettings(
        initialRoute: "/new",
      ),
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(CupertinoIcons.circle),
      title: ("New"),
      activeColorPrimary: const Color.fromARGB(255, 0, 0, 0),
      inactiveColorPrimary: CupertinoColors.systemGrey,
      activeColorSecondary: const Color.fromRGBO(76, 2, 232, 1),
      routeAndNavigatorSettings: const RouteAndNavigatorSettings(
        initialRoute: "/new",
      ),
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(CupertinoIcons.line_horizontal_3_decrease),
      title: ("All"),
      activeColorPrimary: const Color.fromARGB(255, 0, 0, 0),
      inactiveColorPrimary: CupertinoColors.systemGrey,
      activeColorSecondary: const Color.fromRGBO(76, 2, 232, 1),
      routeAndNavigatorSettings: const RouteAndNavigatorSettings(
        initialRoute: "/new",
      ),
    ),
  ];
}

// final currentRoutes = {
//   "/all": (final context) => const AllArticleList(),
//   "/new": (final context) => const NewArticleList(),
//   "/fav": (final context) => const FavArticleList(refreshParent: refresh,),
// };

void _showOverlay(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: 50,
      child: Center(
        child: Container(
          color: Colors.transparent,
          width: 500,
          height: 100,
          child: Center(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ),
      ),
    ),
  );

  // Insert the overlay entry into the Overlay
  overlay?.insert(overlayEntry);

  // Remove the overlay after 100 milliseconds
  // Future.delayed(Duration(milliseconds: 100), () {
  //   overlayEntry.remove();
  // });
}
