import 'package:cached_network_image/cached_network_image.dart';
import 'package:blazefeeds/models/app_theme.dart';
import 'package:blazefeeds/models/article.dart';
import 'package:blazefeeds/pages/article_view.dart';
import 'package:blazefeeds/providers/latest_article_provider.dart';
import 'package:blazefeeds/utils/apiservice.dart';
import 'package:blazefeeds/utils/dbhelper.dart';
import 'package:blazefeeds/providers/theme_provider.dart';
import 'package:blazefeeds/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:provider/provider.dart';

class ArticleListItem extends StatefulWidget {
  ArticleListItem({
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
  final void Function(int) onReturn;
  final AppUtils utils = AppUtils();

  @override
  State<ArticleListItem> createState() => _ArticleListItemState();
}

class _ArticleListItemState extends State<ArticleListItem> {
  Color _color = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return GestureDetector(
      onTap: () async {
        Provider.of<LatestArticleNotifier>(context, listen: false).updateValue(widget.articleIndex);
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
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
          int currentArticle = Provider.of<LatestArticleNotifier>(context, listen: false).id;
          widget.onReturn(currentArticle);
        });
      },
      onTapDown: (tapDetails) => {
        setState(() {
          _color = (theme.primaryColor).withAlpha(90);
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
              ? (theme.primaryColor).withAlpha(50)
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
                utils: widget.utils,
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
                child: _showImage(widget.articles[widget.articleIndex].imageUrl),
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
          cacheManager: widget.api.cacheManager,
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              const CupertinoActivityIndicator(),
          errorWidget: (context, url, error) => Container(),
        ),
      );
    }
  }
}

class _ArticleDetails extends StatelessWidget {
  const _ArticleDetails({required this.article, required this.utils});

  final Article article;
  final AppUtils utils;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 2.0, 5.0, 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            article.title,
            style: TextStyle(
              // fontWeight: FontWeight.w700,
              fontVariations: [FontVariation.weight(600)],
              fontSize: 17.0,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
          RichText(
            text: TextSpan(
              text: article.originTitle,
              style: TextStyle(
                fontSize: 15.0,
                color: theme.primaryColor,
                fontVariations: [FontVariation.weight(300)],
              ),
              children: [
                TextSpan(
                  text: ' ◦ By ${article.author} ◦ ${utils.timeAgo(article.published)}',
                  style: TextStyle(
                    fontSize: 15.0,
                    fontVariations: [FontVariation.weight(300)],
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 1.0)),
          Builder(
            builder: (context) {
              final parsedText = parse(article.summaryContent).body!.text.replaceAll("\n", "");
              if (parsedText.length < 100) {
                return const Text("");
              }
              return Text(
                parsedText.isNotEmpty ? "${parsedText.substring(0, 100)}..." : "",
                style: TextStyle(
                  fontSize: 15.0,
                  fontVariations: [FontVariation.weight(300)],
                  color: theme.colorScheme.onSurface,
                ),
              );
            },
          ),
          // Divider(
          //   thickness: 0.1,
          //   height: 0.1,
          // )
        ],
      ),
    );
  }
}
