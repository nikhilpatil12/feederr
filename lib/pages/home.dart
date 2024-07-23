import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:feederr/pages/all_articles.dart';
import 'package:feederr/pages/fav_articles.dart';
import 'package:feederr/pages/new_articles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'settings.dart';
import 'article_list.dart';
// import '../utils/dbhelper.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    PersistentTabController controller;
    controller = PersistentTabController(initialIndex: 0);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          GestureDetector(
            child: const Icon(CupertinoIcons.add_circled),
            onTap: () {
              //TODO: Add feeds
              // userLogin(); CustomListItemApp
              Navigator.push(context, MaterialPageRoute<void>(
                //TODO: Settings
                builder: (BuildContext context) {
                  return Scaffold(
                    appBar: AppBar(
                      title: const Text('Articles'),
                    ),
                    body: const ArticleList(),
                  );
                },
              ));
            },
          ),
          GestureDetector(
            child: const Padding(
              padding: EdgeInsets.all(10.0),
              child: Icon(CupertinoIcons.settings_solid),
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute<void>(
                //TODO: Settings
                builder: (BuildContext context) {
                  return Scaffold(
                    appBar: AppBar(
                      title: const Text('Next page'),
                    ),
                    body: const Settings(),
                  );
                },
              ));
            },
          ),
        ],
      ),
      body: PersistentTabView(
        context,
        controller: controller,
        screens: _buildScreens(),
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

List<Widget> _buildScreens() {
  return [
    const FavArticleList(),
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
      routeAndNavigatorSettings: RouteAndNavigatorSettings(
        initialRoute: "/new",
        routes: currentRoutes,
      ),
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(CupertinoIcons.circle),
      title: ("New"),
      activeColorPrimary: const Color.fromARGB(255, 0, 0, 0),
      inactiveColorPrimary: CupertinoColors.systemGrey,
      activeColorSecondary: const Color.fromRGBO(76, 2, 232, 1),
      routeAndNavigatorSettings: RouteAndNavigatorSettings(
        initialRoute: "/new",
        routes: currentRoutes,
      ),
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(CupertinoIcons.line_horizontal_3_decrease),
      title: ("All"),
      activeColorPrimary: const Color.fromARGB(255, 0, 0, 0),
      inactiveColorPrimary: CupertinoColors.systemGrey,
      activeColorSecondary: const Color.fromRGBO(76, 2, 232, 1),
      routeAndNavigatorSettings: RouteAndNavigatorSettings(
        initialRoute: "/new",
        routes: currentRoutes,
      ),
    ),
  ];
}

final currentRoutes = {
  "/all": (final context) => const AllArticleList(),
  "/new": (final context) => const NewArticleList(),
  "/fav": (final context) => const FavArticleList(),
};

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
      print(json.encode(response.data));
      return json.encode(response.data);
    } else {
      print(response.statusMessage);
    }
  } on DioException catch (e) {
    if (e.response != null) {
      print(e.response?.data);
      print(e.response?.headers);
      print(e.response?.requestOptions);
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      print(e.requestOptions);
      print(e.message);
    }
  }
  return "404";
}
