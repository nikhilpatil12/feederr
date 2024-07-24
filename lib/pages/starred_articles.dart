import 'package:feederr/models/article.dart';
import 'package:feederr/models/feed.dart';
import 'package:feederr/models/tag.dart';
import 'package:feederr/widgets/article.dart';
import 'package:feederr/widgets/tag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StarredArticleList extends StatefulWidget {
  final VoidCallback refreshParent;
  final List<Tag> tags;
  final List<Article> articles;
  final List<Feed> feeds;
  const StarredArticleList({
    super.key,
    required this.refreshParent,
    required this.tags,
    required this.feeds,
    required this.articles,
  });

  @override
  State<StarredArticleList> createState() => _StarredArticleListState();
}

class _StarredArticleListState extends State<StarredArticleList> {
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
            (BuildContext context, int index) => TagListItem(
              tag: widget.tags[index],
              feeds: widget.feeds,
              articles: widget.articles,
            ),
            childCount: widget.tags.length,
          ),
        ),
      ],
    );
  }
}
