import 'package:cached_network_image/cached_network_image.dart';
import 'package:feederr/models/app_theme.dart';
import 'package:feederr/models/article.dart';
import 'package:feederr/pages/article_view.dart';
import 'package:feederr/utils/apiservice.dart';
import 'package:feederr/utils/dbhelper.dart';
import 'package:feederr/utils/providers/themeprovider.dart';
import 'package:feederr/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ArticleListItem extends StatefulWidget {
  const ArticleListItem({
    super.key,
    required this.articles,
    required this.articleIndex,
    required this.api,
    required this.databaseService,
    required this.onReturn,
  });

  final List<Article> articles;
  final int articleIndex;
  final APIService api;
  final DatabaseService databaseService;
  final VoidCallback onReturn;

  @override
  State<ArticleListItem> createState() => _ArticleListItemState();
}

class _ArticleListItemState extends State<ArticleListItem> {
  Color _color = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    return Selector<ThemeProvider, AppTheme>(
        selector: (_, themeProvider) => themeProvider.theme,
        builder: (_, theme, __) {
          return GestureDetector(
            onTap: () async {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) {
                    return ArticleView(
                      articles: widget.articles,
                      articleIndex: widget.articleIndex,
                      api: widget.api,
                      databaseService: widget.databaseService,
                    );
                  },
                ),
              ).then((_) {
                // This will be called after Navigator.pop() on NextPage
                // print("Returned to Article List");
                widget.onReturn();
                // onReturnToPage();
              });
            },
            onTapDown: (tapDetails) => {
              setState(() {
                _color = Color(theme.primaryColor).withAlpha(90);
              })
            },
            onTapUp: (tapDetails) => {
              Future.delayed(const Duration(milliseconds: 200), () {
                setState(() {
                  _color = const Color.fromARGB(0, 0, 0, 0);
                  // code to be executed after 2 seconds
                });
              })
            },
            onTapCancel: () => {
              Future.delayed(const Duration(milliseconds: 200), () {
                setState(() {
                  _color = const Color.fromARGB(0, 0, 0, 0);
                  // code to be executed after 2 seconds
                });
              })
            },
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: widget.articles[widget.articleIndex].isRead
                    ? Color(theme.primaryColor).withAlpha(50)
                    : _color,
              ),
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: _ArticleDetails(
                      article: widget.articles[widget.articleIndex],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      child: _showImage(
                          widget.articles[widget.articleIndex].imageUrl),
                      // Image.network(
                      //   widget.article.imageUrl,
                      //   errorBuilder: (context, exception, stackTrace) {
                      //     return const SizedBox(height: 40);
                      //   },
                      // ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _showImage(String src) {
    if (src == "") {
      return Container();
    }
    if (src.startsWith('data:image/')) {
      return Container();
      // Handle Base64 image
      // final base64Data = src.split(',').last;
      // final imageBytes = base64Decode(base64Data);
      // return GestureDetector(
      //   child: Image.memory(Uint8List.fromList(imageBytes)),
      // );
    } else {
      return GestureDetector(
        child: CachedNetworkImage(
          imageUrl: src,
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              const CupertinoActivityIndicator(),
          errorWidget: (context, url, error) => Container(),
        ),
        // child: Image.network(
        //   widget.article.imageUrl,
        //   errorBuilder: (context, exception, stackTrace) {
        //     return const SizedBox(height: 40);
        //   },
        // ),
      );
    }
  }
}

class _ArticleDetails extends StatelessWidget {
  const _ArticleDetails({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    return Selector<ThemeProvider, AppTheme>(
        selector: (_, themeProvider) => themeProvider.theme,
        builder: (_, theme, __) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  article.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14.0,
                    color: Color(theme.textColor),
                  ),
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
                Text(
                  article.originTitle,
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Color(theme.primaryColor),
                  ),
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 1.0)),
                Text(
                  timeAgo(article.published),
                  style: TextStyle(
                    fontSize: 10.0,
                    color: Color(theme.textColor),
                  ),
                ),
              ],
            ),
          );
          // });
        });
  }
}
