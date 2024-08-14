import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:feederr/models/article.dart';
import 'package:feederr/pages/article_view.dart';
import 'package:feederr/utils/dbhelper.dart';
import 'package:feederr/widgets/article.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class ArticleList extends StatefulWidget {
  final VoidCallback refreshParent;
  final List<Article> articles;
  const ArticleList({
    super.key,
    required this.refreshParent,
    required this.articles,
  });

  @override
  ArticleListState createState() => ArticleListState();
}

const List<String> liOrderBy = <String>['By Date', 'By Title'];
const List<String> liSortOrder = <String>['Ascending', 'Descending'];

class ArticleListState extends State<ArticleList> {
  bool isLoading = false;
  bool isMenuVisible = false;
  String dropdownAscending = "Ascending";
  String dropdownOrder = "By Date";
  bool isSortMenuVisible = false;
  final ScrollController _controller = ScrollController();
  DatabaseService databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    sortArticles();
  }

  void sortArticles() {
    if (dropdownOrder == 'By Date') {
      if (dropdownAscending == "Ascending") {
        widget.articles.sort((b, a) => a.published.compareTo(b.published));
      } else {
        widget.articles.sort((a, b) => a.published.compareTo(b.published));
      }
    }
    if (dropdownOrder == 'By Title') {
      if (dropdownAscending == "Ascending") {
        widget.articles.sort((a, b) => a.title.compareTo(b.title));
      } else {
        widget.articles.sort((b, a) => a.title.compareTo(b.title));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.sizeOf(context).width;
    var screenHeight = MediaQuery.sizeOf(context).height;
    return Stack(
      children: [
        Scrollbar(
          thumbVisibility: true,
          controller: _controller,
          child: CustomScrollView(
            controller: _controller,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: <Widget>[
              CupertinoSliverRefreshControl(
                onRefresh: () async {
                  widget.refreshParent();
                },
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) =>
                      CupertinoContextMenu.builder(
                    enableHapticFeedback: true,
                    actions: <Widget>[
                      CupertinoContextMenuAction(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(
                              text: widget.articles[index].canonical));
                          Navigator.pop(context);
                        },
                        isDefaultAction: true,
                        trailingIcon: CupertinoIcons.doc_on_clipboard_fill,
                        child: const Text('Copy'),
                      ),
                      CupertinoContextMenuAction(
                        onPressed: () {
                          Share.shareUri(
                              Uri.parse(widget.articles[index].canonical));
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
                      // return ArticleListItem(article: widget.articles[index]);
                      if (animation.value > 0.7) {
                        return Material(
                            child:
                                ArticleView(article: widget.articles[index]));
                      } else {
                        return Material(
                            child: ArticleListItem(
                                article: widget.articles[index]));
                      }
                    },
                    // child: ArticleListItem(article: widget.articles[index]),
                  ),
                  childCount: widget.articles.length,
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                  color: Color.fromARGB(255, 82, 82, 82),
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
                  // Container(
                  //   clipBehavior: Clip.antiAlias,
                  //   decoration: BoxDecoration(
                  //       color: Color.fromARGB(255, 0, 132, 93),
                  //       border: Border.all(width: 1),
                  //       borderRadius: BorderRadius.all(Radius.circular(10))),
                  //   child: Wrap(
                  //     children: [
                  //       IconButton(
                  //         color: Colors.black,
                  //         onPressed: () => {},
                  //         icon: Icon(CupertinoIcons.star),
                  //       ),
                  //       IconButton(
                  //         color: Colors.black,
                  //         onPressed: () => {},
                  //         icon: Icon(CupertinoIcons.circle),
                  //       ),
                  //       IconButton(
                  //         color: Colors.black,
                  //         onPressed: () => {},
                  //         icon: Icon(CupertinoIcons.line_horizontal_3_decrease),
                  //       ),
                  //     ],
                  //   ),
                  // ),
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
                    sigmaX: isMenuVisible ? 5 : 0,
                    sigmaY: isMenuVisible ? 5 : 0),
                child: Container(
                  padding: const EdgeInsets.only(bottom: 100),
                  color: Colors.black.withOpacity(0.2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: screenWidth * 0.9,
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 16, 0, 51),
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              color: const Color.fromARGB(255, 32, 0, 120),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 10, 10, 10),
                                child: Row(
                                  children: [
                                    const Text(
                                      "Mark all as read",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
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
                                        icon: const Icon(Icons.close))
                                  ],
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                "Are you sure to mark all articles as read?",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                              child: SizedBox(
                                width: screenWidth,
                                child: CupertinoButton(
                                  color: const Color.fromARGB(255, 34, 34, 34),
                                  child: const Text("Yes"),
                                  onPressed: () => {},
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                              child: SizedBox(
                                width: screenWidth,
                                child: CupertinoButton(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  child: const Text("No"),
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
                    sigmaX: isSortMenuVisible ? 5 : 0,
                    sigmaY: isSortMenuVisible ? 5 : 0),
                child: Container(
                  padding: EdgeInsets.only(bottom: 100),
                  color: Colors.black.withOpacity(0.2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: screenWidth * 0.9,
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 16, 0, 51),
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              color: const Color.fromARGB(255, 32, 0, 120),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 10, 10, 10),
                                child: Row(
                                  children: [
                                    const Text(
                                      "Article Sorting",
                                      style: TextStyle(
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
                                      icon: const Icon(Icons.close),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 5),
                              child: Row(
                                children: [
                                  const Text("Sort Articles By"),
                                  const Spacer(),
                                  DropdownButton<String>(
                                    value: dropdownOrder,
                                    icon: const Icon(Icons.arrow_downward),
                                    elevation: 0,
                                    dropdownColor:
                                        const Color.fromARGB(255, 19, 0, 97),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(20)),
                                    // style: const TextStyle(color: Colors.deepPurple),
                                    // underline: Container(
                                    //   height: 2,
                                    //   color: Colors.deepPurpleAccent,
                                    // ),
                                    onChanged: (String? value) {
                                      // This is called when the user selects an item.
                                      setState(() {
                                        dropdownOrder = value!;
                                        sortArticles();
                                      });
                                    },
                                    items: liOrderBy
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 5),
                              child: Row(
                                children: [
                                  const Text("Sort Order"),
                                  const Spacer(),
                                  DropdownButton<String>(
                                    value: dropdownAscending,
                                    icon: const Icon(Icons.arrow_downward),
                                    elevation: 0,
                                    dropdownColor:
                                        const Color.fromARGB(255, 19, 0, 97),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(20)),
                                    // style: const TextStyle(color: Colors.deepPurple),
                                    // underline: Container(
                                    //   height: 2,
                                    //   color: Colors.deepPurpleAccent,
                                    // ),
                                    onChanged: (String? value) {
                                      // This is called when the user selects an item.
                                      setState(() {
                                        dropdownAscending = value!;
                                        sortArticles();
                                      });
                                    },
                                    items: liSortOrder
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
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
    );
  }
}
