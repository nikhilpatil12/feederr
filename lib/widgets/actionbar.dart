import 'dart:developer';
import 'dart:ui';

import 'package:blazefeeds/models/app_theme.dart';
import 'package:blazefeeds/models/article.dart';
import 'package:blazefeeds/models/starred.dart';
import 'package:blazefeeds/models/unread.dart';
import 'package:blazefeeds/utils/apiservice.dart';
import 'package:blazefeeds/utils/dbhelper.dart';
import 'package:blazefeeds/providers/font_provider.dart';
import 'package:blazefeeds/providers/theme_provider.dart';
import 'package:blazefeeds/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class ActionBar extends StatefulWidget {
  final Article article;
  final DatabaseService databaseService;
  final APIService api;
  final PageController pageController;

  ActionBar({
    super.key,
    required this.article,
    required this.databaseService,
    required this.api,
    required this.pageController,
  });

  @override
  State<ActionBar> createState() => _ActionBarState();
}

class _ActionBarState extends State<ActionBar> {
  List<String> fonts = [];
  late final AppUtils utils;
  late bool isRead;

  @override
  void initState() {
    super.initState();
    isRead = widget.article.isRead;
    utils = AppUtils(); // Using singleton instance
    initializeFonts();
  }

  Future<void> initializeFonts() async {
    try {
      List<String> loadedFonts = await utils.loadFonts();
      setState(() {
        fonts = loadedFonts; // Update UI after loading fonts
      });
    } catch (e) {
      // Handle the exception, e.g., log it or show a message to the user
      fonts = [];
      log('Failed to load fonts: $e');
    }
  }

  void toggleReadStatus() {
    setState(() {
      isRead = !isRead;
    });
  }

  Future<void> _markArticleAsRead(int articleId, int serverId, bool isLocal) async {
    // setState(() {});
    try {
      //Getting Server list
      await widget.databaseService.deleteUnreadId(articleId);
      // if (!isLocal) {
      //   Server server = await widget.databaseService.server(serverId);
      //   await widget.api.markAsRead(server.baseUrl, server.auth, articleId);
      // }
    } on Exception {
      // Handle error
    } finally {
      // setState(() {});
    }
  }

  Future<void> _markArticleAsUnread(int articleId, int serverId, bool isLocal) async {
    // setState(() {});
    try {
      //Getting Server list
      await widget.databaseService
          .insertUnreadId(UnreadId(articleId: articleId, serverId: serverId));
      // if (!isLocal) {
      //   Server server = await widget.databaseService.server(serverId);
      //   await widget.api.markAsUnread(server.baseUrl, server.auth, articleId);
      // }
    } on Exception {
      // Handle error
    } finally {
      // setState(() {});
    }
  }

  Future<void> _markArticleAsStarred(int articleId, int serverId, bool isLocal) async {
    // setState(() {});
    try {
      //Getting Server list
      await widget.databaseService
          .insertStarredId(StarredId(articleId: articleId, serverId: serverId));
      // if (!isLocal) {
      //   Server server = await widget.databaseService.server(serverId);
      //   await widget.api.markAsStarred(server.baseUrl, server.auth, articleId);
      // }
    } on Exception {
      // Handle error
    } finally {
      // setState(() {});
    }
  }

  Future<void> _markArticleAsNotStarred(int articleId, int serverId, bool isLocal) async {
    // setState(() {});
    try {
      //Getting Server list
      await widget.databaseService.deleteStarredId(articleId);
      // if (!isLocal) {
      //   Server server = await widget.databaseService.server(serverId);
      //   await widget.api
      //       .markAsNotStarred(server.baseUrl, server.auth, articleId);
      // }
    } on Exception {
      // Handle error
    } finally {
      // setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (_, themeProvider, __) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding: EdgeInsets.all(2),
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Color(themeProvider.theme.secondaryColor).withAlpha(50),
                  border: Border.all(
                      width: 0.5, color: Color(themeProvider.theme.textColor).withAlpha(128)),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
                child: Wrap(
                  children: [
                    IconButton(
                      highlightColor: Colors.transparent,
                      color: Color(themeProvider.theme.textColor),
                      onPressed: () => {
                        HapticFeedback.lightImpact(),
                        Share.shareUri(Uri.parse(widget.article.canonical)),
                      },
                      icon: const Icon(CupertinoIcons.share),
                    ),
                    VerticalDivider(
                      width: 10,
                      thickness: 1,
                      color: Color(themeProvider.theme.textColor),
                    ),
                    IconButton(
                      color: Color(themeProvider.theme.textColor),
                      onPressed: () => {
                        setState(() {
                          widget.article.isRead
                              ? {
                                  _markArticleAsUnread(widget.article.id2 ?? 0,
                                      widget.article.serverId, widget.article.isLocal),
                                  widget.article.isRead = false,
                                }
                              : {
                                  _markArticleAsRead(widget.article.id2 ?? 0,
                                      widget.article.serverId, widget.article.isLocal),
                                  widget.article.isRead = true,
                                };
                        }),
                      },
                      icon: !(widget.article.isRead)
                          ? Icon(CupertinoIcons.circle_fill)
                          : Icon(CupertinoIcons.circle),
                    ),
                    IconButton(
                      color: Color(themeProvider.theme.textColor),
                      onPressed: () => {
                        setState(() {
                          !(widget.article.isStarred)
                              ? _markArticleAsStarred(widget.article.id2 ?? 0,
                                  widget.article.serverId, widget.article.isLocal)
                              : _markArticleAsNotStarred(widget.article.id2 ?? 0,
                                  widget.article.serverId, widget.article.isLocal);
                          widget.article.isStarred = !(widget.article.isStarred);
                        }),
                      },
                      icon: !(widget.article.isStarred)
                          ? Icon(CupertinoIcons.star)
                          : Icon(CupertinoIcons.star_fill),
                    ),
                    VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: Color(themeProvider.theme.textColor),
                    ),
                    IconButton(
                      color: Color(themeProvider.theme.textColor),
                      onPressed: () => {
                        HapticFeedback.mediumImpact(),
                        widget.pageController.nextPage(
                          curve: Curves.decelerate,
                          duration: Durations.short3,
                        ),
                      },
                      icon: const Icon(CupertinoIcons.chevron_right),
                    ),
                    VerticalDivider(
                      color: Color(themeProvider.theme.textColor),
                      width: 10,
                      thickness: 1,
                      indent: 20,
                    ),
                    IconButton(
                      highlightColor: Colors.transparent,
                      color: Color(themeProvider.theme.textColor),
                      onPressed: () => {
                        HapticFeedback.lightImpact(),
                        // showCupertinoSheet(
                        // barrierColor: Color(themeProvider.theme.primaryColor).withAlpha(128),
                        // backgroundColor: Colors.transparent,
                        // shape: const RoundedRectangleBorder(
                        //   borderRadius: BorderRadius.all(
                        //     Radius.circular(20),
                        //   ),
                        // ),
                        // useSafeArea: true,
                        // scrollControlDisabledMaxHeightRatio: 0.8,
                        // showDragHandle: true,
                        // isScrollControlled: true,
                        // useRootNavigator: true,
                        // clipBehavior: Clip.hardEdge,
                        // isDismissible: false,
                        // context: context,
                        // enableDrag: true,
                        // elevation: 80,
                        // pageBuilder: (context) =>

                        Navigator.of(context).push(
                          CupertinoSheetRoute<void>(
                            builder: (context) => Scaffold(
                              // extendBody: true,
                              // navigationBar: CupertinoNavigationBar(
                              //   // toolbarHeight: 0,
                              //   // titleSpacing: 0,
                              //   middle: Text('Style'),
                              //   // toolbarHeight: 0,
                              //   // flexibleSpace: SizedBox(
                              //   //   width: 0,
                              //   //   height: 0,
                              //   // ),
                              //   // bottom: PreferredSize(
                              //   //   preferredSize: Size(0, 0),
                              //   //   child: Container(),
                              //   // ),
                              // ),
                              body: Consumer<FontProvider>(builder: (_, fontProvider, __) {
                                return Container(
                                  padding: EdgeInsets.all(5),
                                  // clipBehavior: Clip.hardEdge,
                                  // decoration: BoxDecoration(
                                  //   // color:
                                  //   //     Color(themeProvider.theme.secondaryColor).withAlpha(128),
                                  //   border: Border.all(
                                  //       width: 0.5,
                                  //       color: Color(themeProvider.theme.textColor).withAlpha(128)),
                                  //   borderRadius: const BorderRadius.all(
                                  //     Radius.circular(20),
                                  //   ),
                                  // ),
                                  child: Stack(children: [
                                    SingleChildScrollView(
                                      padding: EdgeInsets.only(top: 50),
                                      // controller: controller,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          // Divider(
                                          //   height: 5,
                                          //   thickness: 0.1,
                                          //   indent: 4,
                                          //   endIndent: 4,
                                          //   color: Color(themeProvider.theme.textColor),
                                          // ),
                                          Column(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                    vertical: 10, horizontal: 20),
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  "THEME",
                                                  style: TextStyle(
                                                    color: Color(themeProvider.theme.textColor),
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [
                                                  CupertinoButton(
                                                    child: Icon(
                                                      Icons.dark_mode,
                                                      color: Color(themeProvider.theme.textColor),
                                                    ),
                                                    onPressed: () async {
                                                      HapticFeedback.lightImpact();

                                                      themeProvider.updateTheme(
                                                          'surfaceColor', 0xff000000);
                                                      themeProvider.updateTheme(
                                                          'textColor', 0xffffffff);
                                                      themeProvider.updateTheme(
                                                          'secondaryColor', 0xff000000);
                                                      // setState(() {
                                                      //   themeProvider
                                                      //           .theme
                                                      //           .surfaceColor =
                                                      //       0xff000000;
                                                      //   themeProvider
                                                      //           .theme
                                                      //           .textColor =
                                                      //       0xffffffff;
                                                      //   themeProvider
                                                      //           .theme
                                                      //           .secondaryColor =
                                                      //       0xff000000;
                                                      // });
                                                    },
                                                  ),
                                                  CupertinoButton(
                                                    child: Icon(
                                                      Icons.cloud,
                                                      color: Color(themeProvider.theme.textColor),
                                                    ),
                                                    onPressed: () async {
                                                      HapticFeedback.lightImpact();
                                                      themeProvider.updateTheme(
                                                          'surfaceColor', 0xff1f1f1f);
                                                      themeProvider.updateTheme(
                                                          'textColor', 0xffffffff);
                                                      themeProvider.updateTheme(
                                                          'secondaryColor', 0xff000000);
                                                    },
                                                  ),
                                                  CupertinoButton(
                                                    child: Icon(
                                                      Icons.light_mode,
                                                      color: Color(themeProvider.theme.textColor),
                                                    ),
                                                    onPressed: () async {
                                                      HapticFeedback.lightImpact();
                                                      themeProvider.updateTheme(
                                                          'surfaceColor', 0xffffffff);
                                                      themeProvider.updateTheme(
                                                          'textColor', 0xff1f1f1f);
                                                      themeProvider.updateTheme(
                                                          'secondaryColor', 0xffffffff);
                                                    },
                                                  ),
                                                  // CupertinoButton(
                                                  //   child: Icon(
                                                  //     Icons.dashboard_customize,
                                                  //     color: Color(
                                                  //         themeProvider.theme.textColor),
                                                  //   ),
                                                  //   onPressed: () {},
                                                  // ),
                                                  // Container(
                                                  //   width: 40,
                                                  //   height: 40,
                                                  //   color: Colors.amber,
                                                  // ),
                                                  // Container(
                                                  //   width: 40,
                                                  //   height: 40,
                                                  //   color: Colors.green,
                                                  // ),
                                                  // Container(
                                                  //   width: 40,
                                                  //   height: 40,
                                                  //   color: Colors.red,
                                                  // ),
                                                  // Container(
                                                  //   width: 40,
                                                  //   height: 40,
                                                  //   color: const Color.fromARGB(
                                                  //       255, 7, 255, 90),
                                                  // ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Divider(
                                            height: 5,
                                            thickness: 0.1,
                                            indent: 4,
                                            endIndent: 4,
                                            color: Color(themeProvider.theme.textColor),
                                          ),
                                          Column(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                    vertical: 10, horizontal: 20),
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  "TITLE",
                                                  style: TextStyle(
                                                    color: Color(themeProvider.theme.textColor),
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [
                                                  CupertinoButton(
                                                    onPressed: () async {
                                                      HapticFeedback.lightImpact();
                                                      final newTitleFontSize =
                                                          fontProvider.fontSettings.titleFontSize -
                                                              0.5;
                                                      fontProvider.updateSetting(
                                                          'titleFontSize', newTitleFontSize);
                                                    },
                                                    child: Icon(
                                                      Icons.text_decrease,
                                                      color: Color(themeProvider.theme.textColor),
                                                    ),
                                                  ),
                                                  CupertinoButton(
                                                    onPressed: () async {
                                                      HapticFeedback.lightImpact();
                                                      final newTitleFontSize =
                                                          fontProvider.fontSettings.titleFontSize +
                                                              0.5;
                                                      fontProvider.updateSetting(
                                                          'titleFontSize', newTitleFontSize);
                                                    },
                                                    child: Icon(
                                                      Icons.text_increase,
                                                      color: Color(themeProvider.theme.textColor),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [
                                                  CupertinoButton(
                                                    onPressed: () async {
                                                      HapticFeedback.lightImpact();
                                                      // setState(() {
                                                      //   themeProvider
                                                      //           .fontSettings
                                                      //           .titleAlignment =
                                                      //       TextAlign.left;
                                                      // });
                                                      fontProvider.updateSetting(
                                                          'titleAlignment', 'left');
                                                    },
                                                    child: Icon(
                                                      CupertinoIcons.text_alignleft,
                                                      color: Color(themeProvider.theme.textColor),
                                                    ),
                                                  ),
                                                  CupertinoButton(
                                                    onPressed: () async {
                                                      HapticFeedback.lightImpact();
                                                      // setState(() {
                                                      //   themeProvider
                                                      //           .fontSettings
                                                      //           .titleAlignment =
                                                      //       TextAlign.center;
                                                      // });
                                                      fontProvider.updateSetting(
                                                          'titleAlignment', 'center');
                                                    },
                                                    child: Icon(
                                                      CupertinoIcons.text_aligncenter,
                                                      color: Color(themeProvider.theme.textColor),
                                                    ),
                                                  ),
                                                  CupertinoButton(
                                                    onPressed: () async {
                                                      HapticFeedback.lightImpact();
                                                      // setState(() {
                                                      //   themeProvider
                                                      //           .fontSettings
                                                      //           .titleAlignment =
                                                      //       TextAlign.right;
                                                      // });
                                                      fontProvider.updateSetting(
                                                          'titleAlignment', 'right');
                                                    },
                                                    child: Icon(
                                                      CupertinoIcons.text_alignright,
                                                      color: Color(themeProvider.theme.textColor),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Divider(
                                            height: 5,
                                            thickness: 0.1,
                                            indent: 4,
                                            endIndent: 4,
                                            color: Color(themeProvider.theme.textColor),
                                          ),
                                          Column(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                    vertical: 10, horizontal: 20),
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  "ARTICLE",
                                                  style: TextStyle(
                                                    color: Color(themeProvider.theme.textColor),
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [
                                                  CupertinoButton(
                                                    onPressed: () async {
                                                      HapticFeedback.lightImpact();
                                                      final newArticleFontSize = fontProvider
                                                              .fontSettings.articleFontSize -
                                                          0.5;
                                                      fontProvider.updateSetting(
                                                          'articleFontSize', newArticleFontSize);
                                                    },
                                                    child: Icon(
                                                      Icons.text_decrease,
                                                      color: Color(themeProvider.theme.textColor),
                                                    ),
                                                  ),
                                                  CupertinoButton(
                                                    onPressed: () async {
                                                      HapticFeedback.lightImpact();
                                                      final newArticleFontSize = fontProvider
                                                              .fontSettings.articleFontSize +
                                                          0.5;
                                                      fontProvider.updateSetting(
                                                          'articleFontSize', newArticleFontSize);
                                                    },
                                                    child: Icon(
                                                      Icons.text_increase,
                                                      color: Color(themeProvider.theme.textColor),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(
                                                    vertical: 0, horizontal: 20),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    CupertinoButton(
                                                      onPressed: () async {
                                                        HapticFeedback.lightImpact();
                                                        fontProvider.updateSetting(
                                                            'articleAlignment', 'left');
                                                      },
                                                      child: Icon(
                                                        CupertinoIcons.text_alignleft,
                                                        color: Color(themeProvider.theme.textColor),
                                                      ),
                                                    ),
                                                    CupertinoButton(
                                                      onPressed: () async {
                                                        HapticFeedback.lightImpact();
                                                        // setState(() {
                                                        //   themeProvider
                                                        //           .fontSettings
                                                        //           .articleAlignment =
                                                        //       TextAlign
                                                        //           .center;
                                                        // });
                                                        fontProvider.updateSetting(
                                                            'articleAlignment', 'center');
                                                      },
                                                      child: Icon(
                                                        CupertinoIcons.text_aligncenter,
                                                        color: Color(themeProvider.theme.textColor),
                                                      ),
                                                    ),
                                                    CupertinoButton(
                                                      onPressed: () async {
                                                        HapticFeedback.lightImpact();
                                                        // setState(() {
                                                        //   themeProvider
                                                        //           .fontSettings
                                                        //           .articleAlignment =
                                                        //       TextAlign.right;
                                                        // });
                                                        fontProvider.updateSetting(
                                                            'articleAlignment', 'right');
                                                      },
                                                      child: Icon(
                                                        CupertinoIcons.text_alignright,
                                                        color: Color(themeProvider.theme.textColor),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(
                                                    vertical: 10, horizontal: 20),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.all(10),
                                                          child: Icon(
                                                            Icons.height,
                                                            color: Color(
                                                                themeProvider.theme.textColor),
                                                          ),
                                                        ),
                                                        Text(
                                                          "Line Spacing",
                                                          style: TextStyle(
                                                            color: Color(
                                                                themeProvider.theme.textColor),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Color(themeProvider.theme.primaryColor),
                                                        borderRadius: const BorderRadius.all(
                                                          Radius.circular(10),
                                                        ),
                                                        border: Border.all(
                                                          color:
                                                              Color(themeProvider.theme.textColor),
                                                        ),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          CupertinoButton(
                                                              padding: const EdgeInsets.all(0),
                                                              child: Icon(
                                                                Icons.remove,
                                                                color: Color(
                                                                    themeProvider.theme.textColor),
                                                              ),
                                                              onPressed: () async {
                                                                HapticFeedback.lightImpact();
                                                                final newLineSpacing = fontProvider
                                                                        .fontSettings
                                                                        .articleLineSpacing -
                                                                    0.2;

                                                                // Ensure the value remains above 1.5
                                                                if (newLineSpacing >= 1.5 &&
                                                                    newLineSpacing <= 4.8) {
                                                                  // Update using the provider method
                                                                  await themeProvider.updateTheme(
                                                                      'articleLineSpacing',
                                                                      newLineSpacing);
                                                                }
                                                              }),
                                                          CupertinoButton(
                                                            padding: const EdgeInsets.all(0),
                                                            child: Icon(
                                                              Icons.add,
                                                              color: Color(
                                                                  themeProvider.theme.textColor),
                                                            ),
                                                            onPressed: () async {
                                                              HapticFeedback.lightImpact();
                                                              final newLineSpacing = fontProvider
                                                                      .fontSettings
                                                                      .articleLineSpacing +
                                                                  0.2;

                                                              // Ensure the value remains above 1.5
                                                              if (newLineSpacing >= 1.5 &&
                                                                  newLineSpacing <= 4.8) {
                                                                // Update using the provider method
                                                                await themeProvider.updateTheme(
                                                                    'articleLineSpacing',
                                                                    newLineSpacing);
                                                              }
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(
                                                    vertical: 10, horizontal: 20),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.all(10),
                                                          child: Icon(
                                                            Icons.width_wide,
                                                            color: Color(
                                                                themeProvider.theme.textColor),
                                                          ),
                                                        ),
                                                        Text(
                                                          "Content Width",
                                                          style: TextStyle(
                                                            color: Color(
                                                                themeProvider.theme.textColor),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Color(themeProvider.theme.primaryColor),
                                                        borderRadius: const BorderRadius.all(
                                                          Radius.circular(10),
                                                        ),
                                                        border: Border.all(
                                                          color:
                                                              Color(themeProvider.theme.textColor),
                                                        ),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          CupertinoButton(
                                                            padding: const EdgeInsets.all(0),
                                                            child: Icon(
                                                              Icons.remove,
                                                              color: Color(
                                                                  themeProvider.theme.textColor),
                                                            ),
                                                            onPressed: () async {
                                                              HapticFeedback.lightImpact();
                                                              final articleContentWidth =
                                                                  fontProvider.fontSettings
                                                                          .articleContentWidth +
                                                                      5;
                                                              fontProvider.updateSetting(
                                                                  'articleContentWidth',
                                                                  articleContentWidth);
                                                            },
                                                          ),
                                                          CupertinoButton(
                                                            padding: const EdgeInsets.all(0),
                                                            child: Icon(
                                                              Icons.add,
                                                              color: Color(
                                                                  themeProvider.theme.textColor),
                                                            ),
                                                            onPressed: () async {
                                                              HapticFeedback.lightImpact();
                                                              final articleContentWidth =
                                                                  fontProvider.fontSettings
                                                                          .articleContentWidth -
                                                                      5;
                                                              if (fontProvider.fontSettings
                                                                      .articleContentWidth >=
                                                                  5) {
                                                                fontProvider.updateSetting(
                                                                    'articleContentWidth',
                                                                    articleContentWidth);
                                                              }
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Divider(
                                            height: 5,
                                            thickness: 0.1,
                                            indent: 4,
                                            endIndent: 4,
                                            color: Color(themeProvider.theme.textColor),
                                          ),
                                          Column(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                    vertical: 10, horizontal: 20),
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  "FONTS",
                                                  style: TextStyle(
                                                    color: Color(themeProvider.theme.textColor),
                                                  ),
                                                ),
                                              ),
                                              ...List.generate(
                                                fonts.length,
                                                (index) => Container(
                                                  alignment: Alignment.centerLeft,
                                                  padding: const EdgeInsets.all(20),
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      HapticFeedback.lightImpact();
                                                      // setState(
                                                      //   () {
                                                      //     themeProvider
                                                      //             .fontSettings
                                                      //             .articleFont =
                                                      //         fonts[index];
                                                      //   },
                                                      // );
                                                      final newFont = fonts[index];
                                                      fontProvider.updateSetting(
                                                          'articleFont', newFont);
                                                    },
                                                    child: Text(
                                                      fonts[index],
                                                      style: TextStyle(
                                                        fontFamily: fonts[index],
                                                        color: Color(themeProvider.theme.textColor),
                                                        fontSize: fontProvider
                                                            .fontSettings.articleFontSize,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(padding: EdgeInsets.all(50))
                                            ],
                                          ),
                                          // ElevatedButton(
                                          //   child: const Text('Close'),
                                          //   onPressed: () => Navigator.pop(context),
                                          // ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(themeProvider.theme.surfaceColor),
                                          // borderRadius: BorderRadius.only(
                                          //   topRight: Radius.circular(20),
                                          //   topLeft: Radius.circular(20),
                                          // ),
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Color(themeProvider.theme.textColor)
                                                  .withAlpha(128),
                                              width: 0.5,
                                            ),
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(10),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Positioned(
                                              right: 0,
                                              child: IconButton(
                                                icon: Icon(Icons.close),
                                                onPressed: () {
                                                  HapticFeedback.mediumImpact();
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              // GestureDetector(
                                              //   onTap: () {
                                              //     HapticFeedback.mediumImpact();
                                              //     Navigator.pop(context);
                                              //   },
                                              //   child: Padding(
                                              //     padding: EdgeInsets.only(left: 20, right: 20),
                                              //     child: Icon(
                                              //       Icons.close,
                                              //       color: Color(themeProvider.theme.textColor),
                                              //     ),
                                              //   ),
                                              // ),
                                            ),
                                            Text(
                                              'Style',
                                              style: TextStyle(
                                                fontSize: fontProvider.fontSettings.articleFontSize,
                                                fontWeight: FontWeight.w600,
                                                color: Color(themeProvider.theme.textColor),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ]),
                                );
                              }),
                            ),
                          ),
                        ),
                      },
                      icon: const Icon(CupertinoIcons.textformat),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
