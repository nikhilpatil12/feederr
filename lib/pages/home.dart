import 'dart:convert';
import 'package:feederr/models/article.dart';
import 'package:feederr/models/feed.dart';
import 'package:feederr/models/categoryentry.dart';
import 'package:feederr/models/tagged_id.dart';
import 'package:feederr/models/unread.dart';
import 'package:feederr/models/server.dart';
import 'package:feederr/models/starred.dart';
import 'package:feederr/models/tag.dart';
import 'package:feederr/pages/add_server.dart';
import 'package:feederr/pages/article_tab.dart';
import 'package:feederr/utils/api_utils.dart';
import 'package:feederr/utils/dbhelper.dart';
import 'package:feederr/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html/parser.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:feederr/pages/settings.dart';

bool isWebLoading = false;
bool isLocalLoading = false;
String status = "";

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.title,
  });
  final String title;
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

  DatabaseService databaseService = DatabaseService();
  void showStatus(String newStatus) async {
    status = newStatus;
    // Remove the overlay after 100 milliseconds
    // Future.delayed(Duration(milliseconds: 200), () {
    //   status = "";
    // });
  }

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
      //TODO: remove
      if (serverList.isEmpty) {
        await databaseService.insertServer(Server(
            baseUrl: "https://rss2.nikpatil.com",
            userName: "nikhil",
            password: "iamnik12@",
            auth: "nikhil/144d26452b66538e16d0d26b01e0382ab0da7b3b"));
        serverList = await databaseService.servers();
      }

      if (serverList.isNotEmpty) {
        String baseUrl = serverList[0].baseUrl;
        String auth = serverList[0].auth ?? '';
        int serverId = serverList[0].id ?? 0;
        showStatus("Fetching feeds");
        //Getting feedlist from server(s)
        List<Feed> feedList = await fetchFeedList(baseUrl, auth) ?? [];
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
          isLocalLoading = false;
        });
        //Adding new feeds to db
        for (Feed feed in feedList) {
          //saving to DB
          feed.serverId = serverId;
          Feed? dF =
              await databaseService.feedByServerAndFeedId(serverId, feed.id);
          if (dF == null) {
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
        List<UnreadId> unreadIds = await fetchUnreadIds(baseUrl, auth) ?? [];
        //Saving newids to db
        for (UnreadId id in unreadIds) {
          //saving to DB
          id.serverId = serverId;
          if (dbUnreadIds.isEmpty ||
              (dbUnreadIds.isNotEmpty &&
                  dbUnreadIds
                      .where((x) =>
                          x.articleId == id.articleId && x.serverId == serverId)
                      .isEmpty)) {
            await databaseService.insertUnreadId(id);
          }
        }
        dbUnreadIds = await databaseService.unreadIds();
        //Removing old ids from db
        if (dbUnreadIds.isNotEmpty) {
          for (UnreadId id in dbUnreadIds) {
            if (unreadIds
                .where((x) =>
                    x.articleId == id.articleId && x.serverId == serverId)
                .isEmpty) {
              await databaseService.deleteUnreadId(id.articleId);
            }
          }
        }
        dbUnreadIds = await databaseService.unreadIds();
        //Add missing IDs from database to the API query sring
        String missingIds = '';
        for (UnreadId unreadId in dbUnreadIds) {
          int id = unreadId.articleId;
          Article? a = await databaseService.article(id);
          if (a == null) {
            missingIds += "i=$id&";
          }
        }

        for (Tag tag in dbTags) {
          List<TaggedId>? taggedIds =
              await fetchTaggedIds(baseUrl, auth, tag.id);
          //Adding new tagged ids to db
          for (TaggedId taggedId in taggedIds!) {
            int id = taggedId.articleId;
            Article? a = await databaseService.article(id);
            if (a == null) {
              missingIds += "i=$id&";
            }
          }
        }
        // _showOverlay("Fetching new articles...");
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
            await databaseService.insertStarredId(id);
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
              await databaseService.deleteStarredId(id.articleId);
            }
          }
        }
        dbStarredIds = await databaseService.starredIds();
        for (StarredId starred in dbStarredIds) {
          int id = starred.articleId;
          Article? a = await databaseService.article(id);
          if (a == null) {
            missingIds += "i=$id&";
          }
        }

        showStatus("Fetching all articles");
        //Fetch and insert new article contents
        if (missingIds != '') {
          List<Article> newArticles =
              await fetchNewArticleContents(baseUrl, auth, missingIds) ?? [];
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
            Feed feed = await databaseService.feed(newArticle.originStreamId);
            newArticle.feedId = feed.id2 ?? 0;
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
              await databaseService.insertArticleWithCategories(
                  newArticle, articleCategories);
            }
          }
        }

        favCategoryEntries =
            await databaseService.getCategoryEntriesWithStarredArticles();
        allCategoryEntries = await databaseService.getCategoryEntries();
        newCategoryEntries =
            await databaseService.getCategoryEntriesWithNewArticles();

        showStatus("");
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10.0),
          child: Text(status),
        ),
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
        screens: _buildScreens(refreshFeeds, favCategoryEntries,
            newCategoryEntries, allCategoryEntries),
        items: _navBarsItems(),
        hideNavigationBarWhenKeyboardAppears: true,
        padding: const EdgeInsets.only(top: 8),
        backgroundColor: const Color.fromARGB(255, 0, 0, 20),
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
        navBarStyle: NavBarStyle
            .style12, // Choose the nav bar style with this property 7,12,13 are fav
      ),
    );
  }
}

List<Widget> _buildScreens(
  VoidCallback refreshFeeds,
  List<CategoryEntry> favCatEntries,
  List<CategoryEntry> newCatEntries,
  List<CategoryEntry> allCatEntries,
) {
  return [
    isLocalLoading
        ? const CupertinoActivityIndicator(
            radius: 20.0,
            color: Color.fromRGBO(76, 2, 232, 1),
          )
        : StarredArticleList(
            refreshParent: refreshFeeds,
            categories: favCatEntries,
            path: 'fav',
          ),
    isLocalLoading
        ? const CupertinoActivityIndicator(
            radius: 20.0,
            color: Color.fromRGBO(76, 2, 232, 1),
          )
        : StarredArticleList(
            refreshParent: refreshFeeds,
            categories: newCatEntries,
            path: 'new',
          ),
    isLocalLoading
        ? const CupertinoActivityIndicator(
            radius: 20.0,
            color: Color.fromRGBO(76, 2, 232, 1),
          )
        : StarredArticleList(
            refreshParent: refreshFeeds,
            categories: allCatEntries,
            path: 'all',
          ),
  ];
}

List<PersistentBottomNavBarItem> _navBarsItems() {
  return [
    PersistentBottomNavBarItem(
      icon: const Icon(CupertinoIcons.star),
      title: ("Starred"),
      onSelectedTabPressWhenNoScreensPushed: () => {
        HapticFeedback.mediumImpact(),
      },
      activeColorPrimary: const Color.fromARGB(255, 0, 0, 0),
      inactiveColorPrimary: CupertinoColors.systemGrey,
      activeColorSecondary: const Color.fromRGBO(76, 2, 232, 1),
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(CupertinoIcons.circle),
      title: ("New"),
      activeColorPrimary: const Color.fromARGB(255, 0, 0, 0),
      inactiveColorPrimary: CupertinoColors.systemGrey,
      activeColorSecondary: const Color.fromRGBO(76, 2, 232, 1),
      // routeAndNavigatorSettings: const RouteAndNavigatorSettings(
      //   initialRoute: "/new",
      // ),
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(CupertinoIcons.line_horizontal_3_decrease),
      title: ("All"),
      activeColorPrimary: const Color.fromARGB(255, 0, 0, 0),
      inactiveColorPrimary: CupertinoColors.systemGrey,
      activeColorSecondary: const Color.fromRGBO(76, 2, 232, 1),
      // routeAndNavigatorSettings: const RouteAndNavigatorSettings(
      //   initialRoute: "/new",
      // ),
    ),
  ];
}

// final currentRoutes = {
//   "/fav": (final context) => const StarredArticleList(refreshParent: refresh,),
//   "/all": (final context) => const AllArticleList(),
//   "/new": (final context) => const NewArticleList(),
// };

