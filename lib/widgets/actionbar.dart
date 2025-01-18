import 'package:feederr/models/article.dart';
import 'package:feederr/models/server.dart';
import 'package:feederr/models/starred.dart';
import 'package:feederr/models/unread.dart';
import 'package:feederr/utils/apiservice.dart';
import 'package:feederr/utils/dbhelper.dart';
import 'package:feederr/utils/themeprovider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class ActionBar extends StatefulWidget {
  final Article article;
  final DatabaseService databaseService;
  final APIService api;
  final ThemeProvider themeProvider;
  final PageController pageController;

  ActionBar({
    super.key,
    required this.article,
    required this.databaseService,
    required this.api,
    required this.themeProvider,
    required this.pageController,
  });

  final List<String> fonts = [
    "Cabinet Grotesk",
    "Chillax",
    "Comico",
    "Clash Grotesk",
    "General Sans",
    "New Title",
    "Supreme"
  ];
  @override
  State<ActionBar> createState() => _ArticleReadToggleState();
}

class _ArticleReadToggleState extends State<ActionBar> {
  late bool isRead;

  @override
  void initState() {
    super.initState();
    isRead = widget.article.isRead ?? false;
  }

  void toggleReadStatus() {
    setState(() {
      isRead = !isRead;
    });

    // Call the callback to perform any external actions (e.g., server updates).
    // widget.onToggleRead(widget.article.id2 ?? 0, isRead);
  }

  Future<void> _markArticleAsRead(int articleId, int serverId) async {
    // setState(() {});
    try {
      //Getting Server list
      await widget.databaseService.deleteUnreadId(articleId);
      Server server = await widget.databaseService.server(serverId);
      await widget.api.markAsRead(server.baseUrl, server.auth, articleId);
    } on Exception {
      // Handle error
    } finally {
      // setState(() {});
    }
  }

  Future<void> _markArticleAsUnread(int articleId, int serverId) async {
    // setState(() {});
    try {
      //Getting Server list
      await widget.databaseService
          .insertUnreadId(UnreadId(articleId: articleId, serverId: serverId));
      Server server = await widget.databaseService.server(serverId);
      await widget.api.markAsUnread(server.baseUrl, server.auth, articleId);
    } on Exception {
      // Handle error
    } finally {
      // setState(() {});
    }
  }

  Future<void> _markArticleAsStarred(int articleId, int serverId) async {
    // setState(() {});
    try {
      //Getting Server list
      await widget.databaseService
          .insertStarredId(StarredId(articleId: articleId, serverId: serverId));
      Server server = await widget.databaseService.server(serverId);
      await widget.api.markAsStarred(server.baseUrl, server.auth, articleId);
    } on Exception {
      // Handle error
    } finally {
      // setState(() {});
    }
  }

  Future<void> _markArticleAsNotStarred(int articleId, int serverId) async {
    // setState(() {});
    try {
      //Getting Server list
      await widget.databaseService.deleteStarredId(articleId);
      Server server = await widget.databaseService.server(serverId);
      await widget.api.markAsNotStarred(server.baseUrl, server.auth, articleId);
    } on Exception {
      // Handle error
    } finally {
      // setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Color(widget.themeProvider.theme.primaryColor),
            borderRadius: const BorderRadius.all(
              Radius.circular(5),
            ),
          ),
          child: Wrap(
            children: [
              IconButton(
                highlightColor: Colors.transparent,
                color: Color(widget.themeProvider.theme.surfaceColor),
                onPressed: () => {
                  HapticFeedback.lightImpact(),
                  Share.shareUri(Uri.parse(widget.article.canonical)),
                },
                icon: const Icon(CupertinoIcons.share),
              ),
              VerticalDivider(
                width: 10,
                thickness: 1,
                indent: 20,
                color: Color(widget.themeProvider.theme.surfaceColor),
              ),
              IconButton(
                color: Color(widget.themeProvider.theme.surfaceColor),
                onPressed: () => {
                  setState(() {
                    widget.article.isRead ?? true
                        ? {
                            _markArticleAsUnread(widget.article.id2 ?? 0,
                                widget.article.serverId),
                            widget.article.isRead = false,
                          }
                        : {
                            _markArticleAsRead(widget.article.id2 ?? 0,
                                widget.article.serverId),
                            widget.article.isRead = true,
                          };
                  }),
                },
                icon: !(widget.article.isRead ?? false)
                    ? Icon(CupertinoIcons.circle_fill)
                    : Icon(CupertinoIcons.circle),
              ),
              IconButton(
                color: Color(widget.themeProvider.theme.surfaceColor),
                onPressed: () => {
                  setState(() {
                    !(widget.article.isStarred ?? false)
                        ? _markArticleAsStarred(
                            widget.article.id2 ?? 0, widget.article.serverId)
                        : _markArticleAsNotStarred(
                            widget.article.id2 ?? 0, widget.article.serverId);
                    widget.article.isStarred =
                        !(widget.article.isStarred ?? false);
                  }),
                },
                icon: !(widget.article.isStarred ?? false)
                    ? Icon(CupertinoIcons.star)
                    : Icon(CupertinoIcons.star_fill),
              ),
              VerticalDivider(
                width: 10,
                thickness: 1,
                color: Color(widget.themeProvider.theme.surfaceColor),
                indent: 20,
              ),
              IconButton(
                color: Color(widget.themeProvider.theme.surfaceColor),
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
                color: Color(widget.themeProvider.theme.surfaceColor),
                width: 10,
                thickness: 1,
                indent: 20,
              ),
              IconButton(
                highlightColor: Colors.transparent,
                color: Color(widget.themeProvider.theme.surfaceColor),
                onPressed: () => {
                  HapticFeedback.lightImpact(),
                  showModalBottomSheet(
                    shape: const BeveledRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    useSafeArea: true,
                    scrollControlDisabledMaxHeightRatio: 0.8,
                    // showDragHandle: true,
                    isScrollControlled: true,
                    useRootNavigator: true,
                    isDismissible: false,
                    context: context,
                    enableDrag: true,
                    elevation: 100,
                    builder: (context) {
                      return DraggableScrollableSheet(
                        expand: false,
                        snap: true,
                        builder: (_, controller) {
                          return SingleChildScrollView(
                            controller: controller,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  color: Color(
                                      widget.themeProvider.theme.surfaceColor),
                                  padding: const EdgeInsets.all(10),
                                  child: Center(
                                    child: Text(
                                      'Style',
                                      style: TextStyle(
                                        fontSize: widget.themeProvider
                                            .fontSettings.articleFontSize,
                                        fontWeight: FontWeight.w600,
                                        color: Color(widget
                                            .themeProvider.theme.textColor),
                                      ),
                                    ),
                                  ),
                                ),
                                Divider(
                                  height: 5,
                                  thickness: 0.1,
                                  indent: 4,
                                  endIndent: 4,
                                  color: Color(
                                      widget.themeProvider.theme.textColor),
                                ),
                                Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 20),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "THEME",
                                        style: TextStyle(
                                          color: Color(widget
                                              .themeProvider.theme.textColor),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      color: Color(widget
                                          .themeProvider.theme.surfaceColor),
                                      child: CupertinoFormRow(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            CupertinoButton(
                                              child: Icon(
                                                Icons.dark_mode,
                                                color: Color(widget
                                                    .themeProvider
                                                    .theme
                                                    .textColor),
                                              ),
                                              onPressed: () async {
                                                HapticFeedback.lightImpact();

                                                widget.themeProvider
                                                    .updateSetting(
                                                        'surfaceColor',
                                                        0xff000000);
                                                widget.themeProvider
                                                    .updateSetting('textColor',
                                                        0xffffffff);
                                                widget.themeProvider
                                                    .updateSetting(
                                                        'secondaryColor',
                                                        0xff000000);
                                                // setState(() {
                                                //   widget.themeProvider
                                                //           .theme
                                                //           .surfaceColor =
                                                //       0xff000000;
                                                //   widget.themeProvider
                                                //           .theme
                                                //           .textColor =
                                                //       0xffffffff;
                                                //   widget.themeProvider
                                                //           .theme
                                                //           .secondaryColor =
                                                //       0xff000000;
                                                // });
                                              },
                                            ),
                                            CupertinoButton(
                                              child: Icon(
                                                Icons.cloud,
                                                color: Color(widget
                                                    .themeProvider
                                                    .theme
                                                    .textColor),
                                              ),
                                              onPressed: () async {
                                                HapticFeedback.lightImpact();
                                                widget.themeProvider
                                                    .updateSetting(
                                                        'surfaceColor',
                                                        0xff1f1f1f);
                                                widget.themeProvider
                                                    .updateSetting('textColor',
                                                        0xffffffff);
                                                widget.themeProvider
                                                    .updateSetting(
                                                        'secondaryColor',
                                                        0xff000000);
                                              },
                                            ),
                                            CupertinoButton(
                                              child: Icon(
                                                Icons.light_mode,
                                                color: Color(widget
                                                    .themeProvider
                                                    .theme
                                                    .textColor),
                                              ),
                                              onPressed: () async {
                                                HapticFeedback.lightImpact();
                                                widget.themeProvider
                                                    .updateSetting(
                                                        'surfaceColor',
                                                        0xffffffff);
                                                widget.themeProvider
                                                    .updateSetting('textColor',
                                                        0xff1f1f1f);
                                                widget.themeProvider
                                                    .updateSetting(
                                                        'secondaryColor',
                                                        0xffffffff);
                                              },
                                            ),
                                            // CupertinoButton(
                                            //   child: Icon(
                                            //     Icons.dashboard_customize,
                                            //     color: Color(
                                            //         widget.themeProvider.theme.textColor),
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
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(
                                  height: 5,
                                  thickness: 0.1,
                                  indent: 4,
                                  endIndent: 4,
                                  color: Color(
                                      widget.themeProvider.theme.textColor),
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
                                          color: Color(widget
                                              .themeProvider.theme.textColor),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        CupertinoButton(
                                          onPressed: () async {
                                            HapticFeedback.lightImpact();
                                            // setState(() {
                                            //   widget.themeProvider
                                            //           .fontSettings
                                            //           .titleFontSize =
                                            //       double.parse(
                                            //     (widget.themeProvider
                                            //                 .fontSettings
                                            //                 .titleFontSize -
                                            //             0.5)
                                            //         .toStringAsFixed(
                                            //             2),
                                            //   );
                                            // });
                                            final newTitleFontSize = widget
                                                    .themeProvider
                                                    .fontSettings
                                                    .titleFontSize -
                                                0.5;
                                            widget.themeProvider.updateSetting(
                                                'titleFontSize',
                                                newTitleFontSize);
                                          },
                                          child: Icon(
                                            Icons.text_decrease,
                                            color: Color(widget
                                                .themeProvider.theme.textColor),
                                          ),
                                        ),
                                        CupertinoButton(
                                          onPressed: () async {
                                            HapticFeedback.lightImpact();
                                            // setState(() {
                                            //   widget.themeProvider
                                            //           .fontSettings
                                            //           .titleFontSize =
                                            //       double.parse((widget.themeProvider
                                            //                   .fontSettings
                                            //                   .titleFontSize +
                                            //               0.5)
                                            //           .toStringAsFixed(
                                            //               2));
                                            // });
                                            final newTitleFontSize = widget
                                                    .themeProvider
                                                    .fontSettings
                                                    .titleFontSize +
                                                0.5;
                                            widget.themeProvider.updateSetting(
                                                'titleFontSize',
                                                newTitleFontSize);
                                          },
                                          child: Icon(
                                            Icons.text_increase,
                                            color: Color(widget
                                                .themeProvider.theme.textColor),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        CupertinoButton(
                                          onPressed: () async {
                                            HapticFeedback.lightImpact();
                                            // setState(() {
                                            //   widget.themeProvider
                                            //           .fontSettings
                                            //           .titleAlignment =
                                            //       TextAlign.left;
                                            // });
                                            widget.themeProvider.updateSetting(
                                                'titleAlignment', 'left');
                                          },
                                          child: Icon(
                                            CupertinoIcons.text_alignleft,
                                            color: Color(widget
                                                .themeProvider.theme.textColor),
                                          ),
                                        ),
                                        CupertinoButton(
                                          onPressed: () async {
                                            HapticFeedback.lightImpact();
                                            // setState(() {
                                            //   widget.themeProvider
                                            //           .fontSettings
                                            //           .titleAlignment =
                                            //       TextAlign.center;
                                            // });
                                            widget.themeProvider.updateSetting(
                                                'titleAlignment', 'center');
                                          },
                                          child: Icon(
                                            CupertinoIcons.text_aligncenter,
                                            color: Color(widget
                                                .themeProvider.theme.textColor),
                                          ),
                                        ),
                                        CupertinoButton(
                                          onPressed: () async {
                                            HapticFeedback.lightImpact();
                                            // setState(() {
                                            //   widget.themeProvider
                                            //           .fontSettings
                                            //           .titleAlignment =
                                            //       TextAlign.right;
                                            // });
                                            widget.themeProvider.updateSetting(
                                                'titleAlignment', 'right');
                                          },
                                          child: Icon(
                                            CupertinoIcons.text_alignright,
                                            color: Color(widget
                                                .themeProvider.theme.textColor),
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
                                  color: Color(
                                      widget.themeProvider.theme.textColor),
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
                                          color: Color(widget
                                              .themeProvider.theme.textColor),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        CupertinoButton(
                                          onPressed: () async {
                                            HapticFeedback.lightImpact();
                                            // setState(() {
                                            //   widget.themeProvider
                                            //           .fontSettings
                                            //           .articleFontSize =
                                            //       double.parse((widget.themeProvider
                                            //                   .fontSettings
                                            //                   .articleFontSize -
                                            //               0.5)
                                            //           .toStringAsFixed(
                                            //               2));
                                            // });
                                            final newArticleFontSize = widget
                                                    .themeProvider
                                                    .fontSettings
                                                    .articleFontSize -
                                                0.5;
                                            widget.themeProvider.updateSetting(
                                                'articleFontSize',
                                                newArticleFontSize);
                                          },
                                          child: Icon(
                                            Icons.text_decrease,
                                            color: Color(widget
                                                .themeProvider.theme.textColor),
                                          ),
                                        ),
                                        CupertinoButton(
                                          onPressed: () async {
                                            HapticFeedback.lightImpact();
                                            // setState(() {
                                            //   widget.themeProvider
                                            //           .fontSettings
                                            //           .articleFontSize =
                                            //       double.parse((widget.themeProvider
                                            //                   .fontSettings
                                            //                   .articleFontSize +
                                            //               0.5)
                                            //           .toStringAsFixed(
                                            //               2));
                                            // });
                                            final newArticleFontSize = widget
                                                    .themeProvider
                                                    .fontSettings
                                                    .articleFontSize +
                                                0.5;
                                            widget.themeProvider.updateSetting(
                                                'articleFontSize',
                                                newArticleFontSize);
                                          },
                                          child: Icon(
                                            Icons.text_increase,
                                            color: Color(widget
                                                .themeProvider.theme.textColor),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 20),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          CupertinoButton(
                                            onPressed: () async {
                                              HapticFeedback.lightImpact();
                                              //   setState(() {
                                              //     widget.themeProvider
                                              //             .fontSettings
                                              //             .articleAlignment =
                                              //         TextAlign.left;
                                              //   });
                                              widget.themeProvider
                                                  .updateSetting(
                                                      'articleAlignment',
                                                      'left');
                                            },
                                            child: Icon(
                                              CupertinoIcons.text_alignleft,
                                              color: Color(widget.themeProvider
                                                  .theme.textColor),
                                            ),
                                          ),
                                          CupertinoButton(
                                            onPressed: () async {
                                              HapticFeedback.lightImpact();
                                              // setState(() {
                                              //   widget.themeProvider
                                              //           .fontSettings
                                              //           .articleAlignment =
                                              //       TextAlign
                                              //           .center;
                                              // });
                                              widget.themeProvider
                                                  .updateSetting(
                                                      'articleAlignment',
                                                      'center');
                                            },
                                            child: Icon(
                                              CupertinoIcons.text_aligncenter,
                                              color: Color(widget.themeProvider
                                                  .theme.textColor),
                                            ),
                                          ),
                                          CupertinoButton(
                                            onPressed: () async {
                                              HapticFeedback.lightImpact();
                                              // setState(() {
                                              //   widget.themeProvider
                                              //           .fontSettings
                                              //           .articleAlignment =
                                              //       TextAlign.right;
                                              // });
                                              widget.themeProvider
                                                  .updateSetting(
                                                      'articleAlignment',
                                                      'right');
                                            },
                                            child: Icon(
                                              CupertinoIcons.text_alignright,
                                              color: Color(widget.themeProvider
                                                  .theme.textColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 20),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: Icon(
                                                  Icons.height,
                                                  color: Color(widget
                                                      .themeProvider
                                                      .theme
                                                      .textColor),
                                                ),
                                              ),
                                              Text(
                                                "Line Spacing",
                                                style: TextStyle(
                                                  color: Color(widget
                                                      .themeProvider
                                                      .theme
                                                      .textColor),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Color(widget.themeProvider
                                                  .theme.primaryColor),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                Radius.circular(10),
                                              ),
                                              border: Border.all(
                                                color: Color(widget
                                                    .themeProvider
                                                    .theme
                                                    .textColor),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                CupertinoButton(
                                                    padding:
                                                        const EdgeInsets.all(0),
                                                    child: Icon(
                                                      Icons.remove,
                                                      color: Color(widget
                                                          .themeProvider
                                                          .theme
                                                          .textColor),
                                                    ),
                                                    onPressed: () async {
                                                      HapticFeedback
                                                          .lightImpact();
                                                      // setState(
                                                      //   () async {
                                                      final newLineSpacing = widget
                                                              .themeProvider
                                                              .fontSettings
                                                              .articleLineSpacing -
                                                          0.2;

                                                      // Ensure the value remains above 1.5
                                                      if (newLineSpacing >=
                                                              1.5 &&
                                                          newLineSpacing <=
                                                              4.8) {
                                                        // Update using the provider method
                                                        await widget
                                                            .themeProvider
                                                            .updateSetting(
                                                                'articleLineSpacing',
                                                                newLineSpacing);
                                                      }
                                                    }),
                                                CupertinoButton(
                                                  padding:
                                                      const EdgeInsets.all(0),
                                                  child: Icon(
                                                    Icons.add,
                                                    color: Color(widget
                                                        .themeProvider
                                                        .theme
                                                        .textColor),
                                                  ),
                                                  onPressed: () async {
                                                    HapticFeedback
                                                        .lightImpact();
                                                    final newLineSpacing = widget
                                                            .themeProvider
                                                            .fontSettings
                                                            .articleLineSpacing +
                                                        0.2;

                                                    // Ensure the value remains above 1.5
                                                    if (newLineSpacing >= 1.5 &&
                                                        newLineSpacing <= 4.8) {
                                                      // Update using the provider method
                                                      await widget.themeProvider
                                                          .updateSetting(
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: Icon(
                                                  Icons.width_wide,
                                                  color: Color(widget
                                                      .themeProvider
                                                      .theme
                                                      .textColor),
                                                ),
                                              ),
                                              Text(
                                                "Content Width",
                                                style: TextStyle(
                                                  color: Color(widget
                                                      .themeProvider
                                                      .theme
                                                      .textColor),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Color(widget.themeProvider
                                                  .theme.primaryColor),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                Radius.circular(10),
                                              ),
                                              border: Border.all(
                                                color: Color(widget
                                                    .themeProvider
                                                    .theme
                                                    .textColor),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                CupertinoButton(
                                                  padding:
                                                      const EdgeInsets.all(0),
                                                  child: Icon(
                                                    Icons.remove,
                                                    color: Color(widget
                                                        .themeProvider
                                                        .theme
                                                        .textColor),
                                                  ),
                                                  onPressed: () async {
                                                    HapticFeedback
                                                        .lightImpact();
                                                    // setState(
                                                    //   () {
                                                    //     widget.themeProvider
                                                    //         .fontSettings
                                                    //         .articleContentWidth += 5;
                                                    //   },
                                                    // );
                                                    final articleContentWidth =
                                                        widget
                                                                .themeProvider
                                                                .fontSettings
                                                                .articleContentWidth +
                                                            5;
                                                    widget.themeProvider
                                                        .updateSetting(
                                                            'articleContentWidth',
                                                            articleContentWidth);
                                                  },
                                                ),
                                                CupertinoButton(
                                                  padding:
                                                      const EdgeInsets.all(0),
                                                  child: Icon(
                                                    Icons.add,
                                                    color: Color(widget
                                                        .themeProvider
                                                        .theme
                                                        .textColor),
                                                  ),
                                                  onPressed: () async {
                                                    HapticFeedback
                                                        .lightImpact();
                                                    // setState(
                                                    //   () {
                                                    //     if (widget.themeProvider
                                                    //             .fontSettings
                                                    //             .articleContentWidth >=
                                                    //         5) {
                                                    //       widget.themeProvider
                                                    //           .fontSettings
                                                    //           .articleContentWidth -= 5;
                                                    //     }
                                                    //   },
                                                    // );
                                                    final articleContentWidth =
                                                        widget
                                                                .themeProvider
                                                                .fontSettings
                                                                .articleContentWidth -
                                                            5;
                                                    if (widget
                                                            .themeProvider
                                                            .fontSettings
                                                            .articleContentWidth >=
                                                        5) {
                                                      widget.themeProvider
                                                          .updateSetting(
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
                                  color: Color(
                                      widget.themeProvider.theme.textColor),
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
                                          color: Color(widget
                                              .themeProvider.theme.textColor),
                                        ),
                                      ),
                                    ),
                                    ...List.generate(
                                      widget.fonts.length,
                                      (index) => Container(
                                        alignment: Alignment.centerLeft,
                                        padding: const EdgeInsets.all(20),
                                        child: GestureDetector(
                                          onTap: () async {
                                            HapticFeedback.lightImpact();
                                            // setState(
                                            //   () {
                                            //     widget.themeProvider
                                            //             .fontSettings
                                            //             .articleFont =
                                            //         fonts[index];
                                            //   },
                                            // );
                                            final newFont = widget.fonts[index];
                                            widget.themeProvider.updateSetting(
                                                'articleFont', newFont);
                                          },
                                          child: Text(
                                            widget.fonts[index],
                                            style: TextStyle(
                                              fontFamily: widget.fonts[index],
                                              color: Color(widget.themeProvider
                                                  .theme.textColor),
                                              fontSize: widget.themeProvider
                                                  .fontSettings.articleFontSize,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  child: const Text('Close'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  )
                },
                icon: const Icon(CupertinoIcons.textformat),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
