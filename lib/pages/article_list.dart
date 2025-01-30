import 'dart:developer';
import 'dart:ui';

import 'package:feederr/models/article.dart';
import 'package:feederr/models/server.dart';
import 'package:feederr/models/starred.dart';
import 'package:feederr/models/unread.dart';
import 'package:feederr/utils/apiservice.dart';
import 'package:feederr/utils/dbhelper.dart';
import 'package:feederr/providers/theme_provider.dart';
import 'package:feederr/widgets/article.dart';
import 'package:feederr/widgets/article_preview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class ArticleList extends StatefulWidget {
  final VoidCallback refreshParent;
  final List<Article> articles;
  final APIService api;
  final DatabaseService databaseService;
  final String title;
  const ArticleList({
    super.key,
    required this.refreshParent,
    required this.articles,
    required this.api,
    required this.databaseService,
    required this.title,
  });

  @override
  _ArticleListState createState() => _ArticleListState();
}

// const List<String> liOrderBy = <String>['By Date', 'By Title'];
// const List<String> liSortOrder = <String>['Ascending', 'Descending'];

enum SortBy { date, title }

Set<SortBy> sortBy = <SortBy>{
  SortBy.date,
  SortBy.title,
};

enum SortOrder { ascending, descending }

Set<SortOrder> sortOrder = <SortOrder>{
  SortOrder.ascending,
  SortOrder.descending,
};

class _ArticleListState extends State<ArticleList> {
  bool isLoading = false;
  bool isMenuVisible = false;
  SortOrder valueSortOrder = SortOrder.ascending;
  SortBy valueOrderBy = SortBy.date;
  bool isSortMenuVisible = false;
  int unRead = 0;
  final ScrollController _controller = ScrollController();
  // DatabaseService databaseService = DatabaseService();
  bool isInitialBuild = true;
  @override
  void initState() {
    super.initState();
    sortArticles();
    isInitialBuild = false;
    unRead = widget.articles.length;
  }

  void onReturnToPage(int lastArticleId) async {
    // log("Last index: $lastArticleId, ${lastArticleId / widget.articles.length}, ${_controller.position}");
    // log("Last index: ${_controller.position.minScrollExtent}");
    // var minValue = _controller.position.minScrollExtent;
    var maxValue = _controller.position.maxScrollExtent;
    double newPosition = lastArticleId / widget.articles.length * maxValue;
    // log("Last index: ${newPosition}");
    // log("Last index: $lastArticleId, ${lastArticleId / widget.articles.length}, ${_controller.position.}");
    _controller.animateTo(newPosition, duration: Durations.medium1, curve: Curves.decelerate);
    // Logic to handle when returning to MyPage
    // print("Returned to Article List Page");
    await sortArticles();

    // Set<int> liServers = {};
    // List<UnreadId> dbUnreadIds = await widget.databaseService.unreadIds();
    // for (UnreadId unreadId in dbUnreadIds) {
    //   if (unreadId.serverId != 0 && !liServers.contains(unreadId.serverId)) {
    //     liServers.add(unreadId.serverId);
    //   }
    // }
    // for (int serverId in liServers) {
    //   Server server = await widget.databaseService.server(serverId);
    //   List<int> readIds = [];

    //   // var unreads = await widget.databaseService.getArticlesNotInUnreadByServer(serverId);
    //   var unreadIds =
    //   readIds.addAll(unreads);
    //   await widget.api.markIdsAsRead(server.baseUrl, server.auth, readIds);
    // }

    // liServers = {};
    // List<StarredId> dbStarredIds = await widget.databaseService.starredIds();
    // for (StarredId starredId in dbStarredIds) {
    //   if (starredId.serverId != 0 && !liServers.contains(starredId.serverId)) {
    //     liServers.add(starredId.serverId);
    //   }
    // }
    // for (int serverId in liServers) {
    //   Server server = await widget.databaseService.server(serverId);
    //   List<int> starredIds = [];
    //   var sIds = await widget.databaseService.getArticlesToStarByServer(serverId);
    //   starredIds.addAll(sIds);
    //   await widget.api.markIdsAsStarred(server.baseUrl, server.auth, starredIds);
    // }
    // await  widget.api.markAsRead(widget.);
    // await markArticlesRead();
    // await markArticlesFav();
    // await markArticlesUnFav();
  }

  Future<void> sortArticles() async {
    if (valueOrderBy == SortBy.date) {
      if (valueSortOrder == SortOrder.ascending) {
        widget.articles.sort((b, a) => a.published.compareTo(b.published));
      } else {
        widget.articles.sort((a, b) => a.published.compareTo(b.published));
      }
    }
    if (valueOrderBy == SortBy.title) {
      if (valueSortOrder == SortOrder.ascending) {
        widget.articles.sort((a, b) => a.title.compareTo(b.title));
      } else {
        widget.articles.sort((b, a) => a.title.compareTo(b.title));
      }
    }
    log("Sorting Articles");
    if (!isInitialBuild) {
      log("Marking read and syncing with database");

      Map<int, List<int>> liIdsToMarkRead = {};
      Map<int, List<int>> liIdsToMarkUnRead = {};
      List<UnreadId> liUnreadId = await widget.databaseService.unreadIds();
      final unreadIdSet = liUnreadId.map((unread) => unread.articleId).toSet();

      Map<int, List<int>> liIdsToMarkStarred = {};
      Map<int, List<int>> liIdsToMarkNotStarred = {};
      List<StarredId> liStarredId = await widget.databaseService.starredIds();
      final starredIdSet = liStarredId.map((starred) => starred.articleId).toSet();
      int newUnread = 0;

      for (var article in widget.articles) {
        article.isRead = !unreadIdSet.contains(article.id2);
        article.isStarred = starredIdSet.contains(article.id2);
        if (!article.isRead) {
          newUnread += 1;
        }
        if (article.serverId != 0) {
          if (!article.isRead) {
            // Not read, add to unread
            if (liIdsToMarkUnRead.containsKey(article.serverId)) {
              liIdsToMarkUnRead[article.serverId]?.add(article.id2 ?? 0);
            } else {
              liIdsToMarkUnRead[article.serverId] = [article.id2 ?? 0];
            }
            newUnread += 1;
          } else {
            // read, add to read
            if (liIdsToMarkRead.containsKey(article.serverId)) {
              liIdsToMarkRead[article.serverId]?.add(article.id2 ?? 0);
            } else {
              liIdsToMarkRead[article.serverId] = [article.id2 ?? 0];
            }
          }
          if (article.isStarred) {
            //Starred, add to starred
            if (liIdsToMarkStarred.containsKey(article.serverId)) {
              liIdsToMarkStarred[article.serverId]?.add(article.id2 ?? 0);
            } else {
              liIdsToMarkStarred[article.serverId] = [article.id2 ?? 0];
            }
          } else {
            // Not Starred, add to Not Starred
            if (liIdsToMarkNotStarred.containsKey(article.serverId)) {
              liIdsToMarkNotStarred[article.serverId]?.add(article.id2 ?? 0);
            } else {
              liIdsToMarkNotStarred[article.serverId] = [article.id2 ?? 0];
            }
          }
        }
      }
      for (int serverId in liIdsToMarkRead.keys) {
        Server server = await widget.databaseService.server(serverId);
        if (serverId != 0) {
          await widget.api
              .markIdsAsRead(server.baseUrl, server.auth, liIdsToMarkRead[serverId] ?? []);
        }
      }
      for (int serverId in liIdsToMarkStarred.keys) {
        Server server = await widget.databaseService.server(serverId);
        if (serverId != 0) {
          await widget.api
              .markIdsAsStarred(server.baseUrl, server.auth, liIdsToMarkStarred[serverId] ?? []);
        }
      }

      for (int serverId in liIdsToMarkUnRead.keys) {
        Server server = await widget.databaseService.server(serverId);
        if (serverId != 0) {
          await widget.api
              .markAsUnread(server.baseUrl, server.auth, liIdsToMarkUnRead[serverId] ?? []);
        }
      }
      for (int serverId in liIdsToMarkNotStarred.keys) {
        Server server = await widget.databaseService.server(serverId);
        if (serverId != 0) {
          await widget.api
              .markAsNotStarred(server.baseUrl, server.auth, liIdsToMarkNotStarred[serverId] ?? []);
        }
      }
      // for (UnreadId unreadId in dbUnreadIds) {
      //   if (unreadId.serverId != 0 && !liServers.contains(unreadId.serverId)) {
      //     liServers.add(unreadId.serverId);
      //   }
      // }
      // for (int serverId in liServers) {
      //   Server server = await widget.databaseService.server(serverId);
      //   List<int> readIds = [];

      // await widget.api.markIdsAsRead(baseUrl, auth, liIdsToMarkRead);

      setState(() {
        unRead = newUnread;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.sizeOf(context).width;
    var screenHeight = MediaQuery.sizeOf(context).height;
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        actions: [
          Container(
            padding: EdgeInsets.all(20),
            child: Text(
              unRead.toString(),
            ),
          ),
        ],
        // backgroundColor: Color(themeProvider.theme.surfaceColor).withAlpha(56),
        elevation: 0,
        title: Text(
          widget.title,
          style: TextStyle(
              // color: Color(themeProvider.theme.textColor),
              ),
          overflow: TextOverflow.fade,
        ),
        // flexibleSpace: ClipRect(
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
      body: Stack(
        children: [
          RawScrollbar(
            interactive: true,
            thumbColor: Color(themeProvider.theme.primaryColor),
            thickness: 4,
            radius: const Radius.circular(1),
            thumbVisibility: true,
            controller: _controller,
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: CustomScrollView(
                controller: _controller,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: <Widget>[
                  CupertinoSliverRefreshControl(
                    onRefresh: () async {
                      log("trying refresh");
                      widget.refreshParent();
                    },
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) => CupertinoContextMenu.builder(
                        enableHapticFeedback: true,
                        actions: <Widget>[
                          CupertinoContextMenuAction(
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: widget.articles[index].canonical));
                              Navigator.pop(context);
                            },
                            isDefaultAction: true,
                            trailingIcon: CupertinoIcons.doc_on_clipboard_fill,
                            child: const Text('Copy'),
                          ),
                          CupertinoContextMenuAction(
                            onPressed: () {
                              Share.shareUri(Uri.parse(widget.articles[index].canonical));
                              Navigator.pop(context);
                            },
                            trailingIcon: CupertinoIcons.share,
                            child: const Text('Share'),
                          ),
                          CupertinoContextMenuAction(
                            onPressed: () {
                              //TODO: add to favorite
                              Navigator.pop(context);
                            },
                            trailingIcon: CupertinoIcons.heart,
                            child: const Text('Favorite'),
                          ),
                        ],
                        builder: (context, animation) {
                          if (animation.value > 0.35) {
                            return Material(
                              child: Center(
                                child: ArticlePreView(
                                  article: widget.articles[index],
                                  articleIndex: index,
                                  api: widget.api,
                                  databaseService: widget.databaseService,
                                ),
                              ),
                            );
                          } else {
                            return Material(
                              child: ArticleListItem(
                                articles: widget.articles,
                                articleIndex: index,
                                api: widget.api,
                                databaseService: widget.databaseService,
                                onReturn: (lastIndex) => onReturnToPage(lastIndex),
                              ),
                            );
                          }
                        },
                      ),
                      childCount: widget.articles.length,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                    color: Color(themeProvider.theme.primaryColor),
                    border: Border.all(width: 1),
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: Wrap(
                  children: [
                    IconButton(
                      highlightColor: Colors.transparent,
                      color: Colors.black,
                      onPressed: () => {
                        HapticFeedback.lightImpact(),
                        setState(() {
                          isSortMenuVisible = !isSortMenuVisible;
                          if (isSortMenuVisible) isMenuVisible = false;
                        })
                      },
                      icon: const Icon(Icons.sort_rounded),
                    ),
                    IconButton(
                      highlightColor: Colors.transparent,
                      color: Colors.black,
                      onPressed: () => {
                        HapticFeedback.lightImpact(),
                        setState(() {
                          isMenuVisible = !isMenuVisible;

                          if (isMenuVisible) isSortMenuVisible = false;
                        })
                      },
                      icon: const Icon(Icons.check),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutBack,
            bottom: isMenuVisible ? 0 : -screenHeight,
            left: 0,
            child: GestureDetector(
              onTap: () => {
                setState(() {
                  isMenuVisible = false;
                }),
              },
              child: Container(
                width: screenWidth,
                height: screenHeight,
                color: Colors.transparent,
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: isMenuVisible ? 5 : 0, sigmaY: isMenuVisible ? 5 : 0),
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 100),
                    color: Colors.black.withAlpha(51),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: screenWidth * 0.9,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: Color(themeProvider.theme.surfaceColor),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                color: Color(themeProvider.theme.primaryColor),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Mark all as read",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Color(themeProvider.theme.textColor),
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        highlightColor: Colors.transparent,
                                        onPressed: (() {
                                          setState(() {
                                            isMenuVisible = false;
                                          });
                                        }),
                                        icon: Icon(
                                          Icons.close,
                                          color: Color(themeProvider.theme.textColor),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  "Are you sure to mark all articles as read?",
                                  style: TextStyle(
                                    color: Color(themeProvider.theme.textColor),
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                                child: SizedBox(
                                  width: screenWidth,
                                  child: CupertinoButton(
                                    color: Color(themeProvider.theme.primaryColor).withAlpha(102),
                                    child: Text(
                                      "Yes",
                                      style: TextStyle(
                                        color: Color(themeProvider.theme.textColor),
                                      ),
                                    ),
                                    onPressed: () => {
                                      //TODO: Mark all as read
                                    },
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                                child: SizedBox(
                                  width: screenWidth,
                                  child: CupertinoButton(
                                    color: const Color(0xFF333333),
                                    child: const Text(
                                      "No",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    onPressed: () => {
                                      setState(() {
                                        isMenuVisible = false;
                                      }),
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutBack,
            // bottom: isSortMenuVisible ? 100 : -500,
            // left: (screenWidth - screenWidth * 0.9) / 2,
            bottom: isSortMenuVisible ? 0 : -screenHeight,
            left: 0,
            child: GestureDetector(
              onTap: () => {
                setState(() {
                  isSortMenuVisible = false;
                }),
              },
              child: Container(
                width: screenWidth,
                height: screenHeight,
                color: Colors.transparent,
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: isSortMenuVisible ? 5 : 0, sigmaY: isSortMenuVisible ? 5 : 0),
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 100),
                    color: Colors.black.withOpacity(0.2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: screenWidth * 0.9,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: Color(themeProvider.theme.surfaceColor),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                color: Color(themeProvider.theme.primaryColor),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Article Sorting",
                                        style: TextStyle(
                                            color: Color(themeProvider.theme.textColor),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        highlightColor: Colors.transparent,
                                        onPressed: () => {
                                          setState(
                                            () {
                                              isSortMenuVisible = false;
                                            },
                                          ),
                                        },
                                        icon: Icon(
                                          Icons.close,
                                          color: Color(themeProvider.theme.textColor),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                child: Row(
                                  children: [
                                    Text(
                                      "Sort Articles By",
                                      style: TextStyle(
                                        color: Color(themeProvider.theme.textColor),
                                      ),
                                    ),
                                    const Spacer(),
                                    CupertinoSlidingSegmentedControl<SortBy>(
                                        groupValue: valueOrderBy,
                                        // Callback that sets the selected segmented control.
                                        onValueChanged: (SortBy? value) {
                                          if (value != null) {
                                            setState(() {
                                              valueOrderBy = value;
                                              sortArticles();
                                            });
                                          }
                                        },
                                        children: const <SortBy, Widget>{
                                          SortBy.date: Text(
                                            'By Date',
                                            style: TextStyle(color: CupertinoColors.white),
                                          ),
                                          SortBy.title: Text(
                                            'By Title',
                                            style: TextStyle(color: CupertinoColors.white),
                                          ),
                                        }),
                                    // DropdownButton<String>(
                                    //   style: TextStyle(
                                    //     color: Color(widget
                                    //         .themeProvider.theme.textColor),
                                    //   ),
                                    //   value: valueOrderBy,
                                    //   icon: Icon(
                                    //     Icons.arrow_downward,
                                    //     color: Color(widget
                                    //         .themeProvider.theme.textColor),
                                    //   ),
                                    //   elevation: 0,
                                    //   dropdownColor: Color(widget
                                    //           .themeProvider.theme.primaryColor)
                                    //       .withAlpha(234),
                                    //   borderRadius: const BorderRadius.all(
                                    //       Radius.circular(20)),
                                    //   // style: const TextStyle(color: Colors.deepPurple),
                                    //   // underline: Container(
                                    //   //   height: 2,
                                    //   //   color: Colors.deepPurpleAccent,
                                    //   // ),
                                    //   onChanged: (String? value) {
                                    //     // This is called when the user selects an item.
                                    //     setState(() {
                                    //       valueOrderBy = value!;
                                    //       sortArticles();
                                    //     });
                                    //   },
                                    //   items: liOrderBy
                                    //       .map<DropdownMenuItem<String>>(
                                    //           (String value) {
                                    //     return DropdownMenuItem<String>(
                                    //       value: value,
                                    //       child: Text(value),
                                    //     );
                                    //   }).toList(),
                                    // ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                child: Row(
                                  children: [
                                    Text(
                                      "Sort Order",
                                      style: TextStyle(
                                        color: Color(themeProvider.theme.textColor),
                                      ),
                                    ),
                                    const Spacer(),
                                    CupertinoSlidingSegmentedControl<SortOrder>(
                                        groupValue: valueSortOrder,
                                        // Callback that sets the selected segmented control.
                                        onValueChanged: (SortOrder? value) {
                                          if (value != null) {
                                            setState(() {
                                              valueSortOrder = value;
                                              sortArticles();
                                            });
                                          }
                                        },
                                        children: const <SortOrder, Widget>{
                                          SortOrder.ascending: Text(
                                            'Ascending',
                                            style: TextStyle(color: CupertinoColors.white),
                                          ),
                                          SortOrder.descending: Text(
                                            'Descending',
                                            style: TextStyle(color: CupertinoColors.white),
                                          ),
                                        }),
                                    // DropdownButton<String>(
                                    //   value: valueSortOrder,
                                    //   style: TextStyle(
                                    //     color: Color(widget
                                    //         .themeProvider.theme.textColor),
                                    //   ),
                                    //   icon: Icon(
                                    //     Icons.arrow_downward,
                                    //     color: Color(widget
                                    //         .themeProvider.theme.textColor),
                                    //   ),
                                    //   elevation: 0,
                                    //   dropdownColor: Color(widget
                                    //           .themeProvider.theme.primaryColor)
                                    //       .withAlpha(234),
                                    //   borderRadius: const BorderRadius.all(
                                    //       Radius.circular(20)),
                                    //   // style: const TextStyle(color: Colors.deepPurple),
                                    //   // underline: Container(
                                    //   //   height: 2,
                                    //   //   color: Colors.deepPurpleAccent,
                                    //   // ),
                                    //   onChanged: (String? value) {
                                    //     // This is called when the user selects an item.
                                    //     setState(() {
                                    //       valueSortOrder = value!;
                                    //       sortArticles();
                                    //     });
                                    //   },
                                    //   items: liSortOrder
                                    //       .map<DropdownMenuItem<String>>(
                                    //           (String value) {
                                    //     return DropdownMenuItem<String>(
                                    //       value: value,
                                    //       child: Text(
                                    //         value,
                                    //       ),
                                    //     );
                                    //   }).toList(),
                                    // ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
