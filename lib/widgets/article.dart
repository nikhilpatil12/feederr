import 'package:feederr/models/article.dart';
import 'package:feederr/pages/article_view.dart';
import 'package:feederr/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ArticleListItem extends StatefulWidget {
  const ArticleListItem({
    super.key,
    required this.article,
  });

  final Article article;

  @override
  State<ArticleListItem> createState() => _ArticleListItemState();
}

void setActiveColor() {}

class _ArticleListItemState extends State<ArticleListItem> {
  Color _color = Colors.transparent;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return Scaffold(
                appBar: AppBar(
                  leading: Container(),
                  flexibleSpace: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          CupertinoButton(
                            child: const Row(
                              children: [
                                Icon(
                                  CupertinoIcons.back,
                                ),
                                Text('Back')
                              ],
                            ),
                            onPressed: () => {
                              Navigator.of(context, rootNavigator: true).pop(),
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                body: ArticleView(
                  article: widget.article,
                ),
              );
            },
          ),
        ),
      },
      onTapDown: (tapDetails) => {
        setState(() {
          _color = Color.fromRGBO(75, 2, 232, 0.186);
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
          color: _color,
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 3,
              child: _ArticleDetails(
                article: widget.article,
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
                child: Image.network(widget.article.imageUrl),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticleDetails extends StatelessWidget {
  const _ArticleDetails({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            article.title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14.0,
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
          Text(
            article.originTitle,
            style: const TextStyle(
              fontSize: 12.0,
              color: Color.fromRGBO(76, 2, 232, 1),
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 1.0)),
          Text(
            timeAgo(article.published),
            style: const TextStyle(fontSize: 10.0),
          ),
        ],
      ),
    );
  }
}
