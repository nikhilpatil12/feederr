import 'package:feederr/models/article.dart';
import 'package:feederr/widgets/article.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FavArticleList extends StatefulWidget {
  final VoidCallback refreshParent;
  final List<Article> articles;
  const FavArticleList({
    super.key,
    required this.refreshParent,
    required this.articles,
  });

  @override
  State<FavArticleList> createState() => _FavArticleListState();
}

class _FavArticleListState extends State<FavArticleList> {
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
