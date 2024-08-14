import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
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

class _ArticleListItemState extends State<ArticleListItem> {
  Color _color = Colors.transparent;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute<void>(
            // fullscreenDialog: true,
            builder: (BuildContext context) {
              return Scaffold(
                  appBar: AppBar(
                    // forceMaterialTransparency: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    flexibleSpace: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
                        child: SafeArea(
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
                                      Text('Back'),
                                    ],
                                  ),
                                  onPressed: () => {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop(),
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    leading: Container(),
                  ),
                  body: ArticleView(article: widget.article));
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
          mainAxisSize: MainAxisSize.min,
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
                child: _showImage(widget.article.imageUrl),
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
