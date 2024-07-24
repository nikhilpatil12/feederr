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
import 'package:feederr/utils/api_utils.dart';
import 'package:feederr/utils/dbhelper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:feederr/pages/settings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});
  final String title;
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<Feed> feeds = [];
  List<Tag> tags = [];
  List<NewId> newIds = [];
  List<StarredId> starredIds = [];
  List<TaggedId> taggedIds = [];
  List<Article> articles = [];
  bool isLoading = false;
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
      isLoading = true;
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
        for (Feed feed in feedList) {
          //saving to DB
          feed.serverId = serverId;
          databaseService.insertFeed(feed);
        }
        feeds = await databaseService.feeds();

        //Getting feedlist from server(s)
        List<Tag> tagList = await fetchTagList(baseUrl, auth) ?? [];
        for (Tag tag in tagList) {
          //saving to DB
          tag.serverId = serverId;
          databaseService.insertTag(tag);
        }
        tags = await databaseService.tags();

        //Get Unread/New Ids
        List<NewId> unreadIds = await fetchUnreadIds(baseUrl, auth) ?? [];
        for (NewId id in unreadIds) {
          //saving to DB
          id.serverId = serverId;
          databaseService.insertNewId(id);
        }
        newIds = await databaseService.newIds();
        for (NewId id in newIds) {
          //Unread
        }
        print(newIds.length);
        //Get Unread/New Ids
        List<StarredId> newStarredIds =
            await fetchStarredIds(baseUrl, auth) ?? [];
        for (StarredId id in newStarredIds) {
          //saving to DB
          id.serverId = serverId;
          databaseService.insertStarredId(id);
        }
        starredIds = await databaseService.starredIds();
        for (StarredId id in starredIds) {
          //Unread
        }
        print(starredIds.length);

        //Getting for each tag/folder
        for (Tag t in tags) {
          if (t.type == "folder") {
            //TODO: Add to UI, and get count
            List<TaggedId> newTaggedIds =
                await fetchTaggedIds(baseUrl, auth, t.id) ?? [];
            for (TaggedId id in newTaggedIds) {
              id.serverId = serverId;
              id.tag = t.id;
              databaseService.insertTaggedId(id);
            }
            taggedIds = await databaseService.taggedIdsByTag(t.id);

            print(t.id);
            print(taggedIds.length);
          }
        }

        //TODO: Fetch new articlecontents
        //temp: change data
        if (newIds.isNotEmpty) {
          String data = '';
          for (NewId id in newIds) {
            String idString = id.articleId.toString();
            data += "i=$idString&";
          }
          List<Article> newArticles =
              await fetchNewArticleContents(baseUrl, auth, data) ?? [];
          for (Article nA in newArticles) {
            var document = parse(nA.summaryContent);
            var images = document.getElementsByTagName("img");
            if (images.isNotEmpty && images[0].attributes.containsKey("src")) {
              nA.imageUrl = images[0].attributes['src']!;
            }
          }
          articles = newArticles;
          print(articles.length);
        }
      }

      //Getting Label list(folders)

      // print(feeds.length);
    } on DioException catch (e) {
      // Handle error
    } finally {
      setState(() {
        isLoading = false;
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
                  //TODO: Settings
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
                  //TODO: Settings
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
        screens: _buildScreens(refreshFeeds, articles),
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

List<Widget> _buildScreens(VoidCallback refreshFeeds, List<Article> articles) {
  return [
    FavArticleList(
      refreshParent: refreshFeeds,
      articles: articles,
    ),
    const NewArticleList(),
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

Future<String> userLogin() async {
  try {
    var dio = Dio();
    var response = await dio.request(
      'http://rss.nikpatil.com/api/greader.php/accounts/ClientLogin?Email=nikhil&Passwd=Iamnik12@',
      options: Options(
        method: 'GET',
      ),
    );
    if (response.statusCode == 200) {
      // print(json.encode(response.data));
      return json.encode(response.data);
    } else {
      // print(response.statusMessage);
    }
  } on DioException catch (e) {
    if (e.response != null) {
      // print(e.response?.data);
      // print(e.response?.headers);
      // print(e.response?.requestOptions);
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      // print(e.requestOptions);
      // print(e.message);
    }
  }
  return "404";
}

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
