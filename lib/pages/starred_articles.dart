import 'package:feederr/models/article.dart';
import 'package:feederr/models/tag.dart';
import 'package:feederr/widgets/article.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StarredArticles extends StatefulWidget {
  final VoidCallback refreshParent;
  final List<Tag> tags;
  const StarredArticles({
    super.key,
    required this.refreshParent,
    required this.tags,
  });

  @override
  State<StarredArticles> createState() => _StarredArticlesState();
}

class _StarredArticlesState extends State<StarredArticles> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
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
                ArticleListItem(article: widget.articles[index]),
            childCount: widget.articles.length,
          ),
        ),
      ],
    );
  }
}
