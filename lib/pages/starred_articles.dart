import 'dart:convert';
import 'dart:ffi';

import 'package:feederr/models/article.dart';
import 'package:feederr/models/feed.dart';
import 'package:feederr/models/new.dart';
import 'package:feederr/models/server.dart';
import 'package:feederr/models/starred.dart';
import 'package:feederr/models/tag.dart';
import 'package:feederr/models/tagentry.dart';
import 'package:feederr/utils/dbhelper.dart';
import 'package:feederr/widgets/article.dart';
import 'package:feederr/widgets/tag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StarredArticleList extends StatefulWidget {
  final VoidCallback refreshParent;
  final List<TagEntry> tags = [];
  final String path;
  StarredArticleList({
    super.key,
    required this.refreshParent,
    required this.path,
  });

  @override
  State<StarredArticleList> createState() => _StarredArticleListState();
}

class _StarredArticleListState extends State<StarredArticleList> {
  DatabaseService databaseService = DatabaseService();
  bool isLocalLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchFeedList();
  }

  Future<void> _fetchFeedList() async {
    setState(() {
      isLocalLoading = true;
    });
    try {
      //Getting Server list
      List<Server> serverList = await databaseService.servers();
      if (serverList.isNotEmpty) {
        List<Feed> dbFeeds = await databaseService.feeds();
        List<Tag> dbTags = await databaseService.tags();
        List<NewId> dbNewIds = await databaseService.newIds();
        List<StarredId> dbStarredIds = await databaseService.starredIds();
        List<Article> dbArticles = await databaseService.articles();

        for (Tag tag in dbTags) {
          for (Feed feed in dbFeeds) {
            //Left yestereday
            List<Article> tagArticles =
                await databaseService.allArticlesByTag(tag.id);

            List<Article> filteredArticles = tagArticles.where((article) {
              var articleCategories =
                  jsonDecode(jsonDecode(article.categories));
              var feedCategories = jsonDecode(jsonDecode(feed.categories));

              if (feedCategories is List) {
                for (var feedCategory in feedCategories) {
                  if (feedCategory is Map && feedCategory.containsKey('id')) {
                    String feedCategoryId = feedCategory['id'];
                    for (var articleCategory in articleCategories) {
                      if (articleCategory == feedCategoryId) {
                        return true;
                      }
                      // if (articleCategory is Map &&
                      //     articleCategory.containsKey('id')) {
                      //   if (articleCategory['id'] == feedCategoryId) {
                      //     return true;
                      //   }
                      // }
                    }
                  }
                }
              }

              return false;
            }).toList();

            print(tag.id);
            print(feed.title);
            print(filteredArticles.length);
          }
        }
        // switch (widget.path) {
        //   case 'fav':
        //   case 'new':
        //   case 'all':
        // }
      }
    } on Exception catch (e) {
      // Handle error
    } finally {
      setState(() {
        isLocalLoading = false;
      });
    }
  }

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
                TagListItem(tag: widget.tags[index]),
            childCount: widget.tags.length,
          ),
        ),
      ],
    );
  }
}
