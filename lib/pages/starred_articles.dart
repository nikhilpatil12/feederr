import 'package:feederr/models/article.dart';
import 'package:feederr/models/feedentry.dart';
import 'package:feederr/models/smart_categoryentry.dart';
import 'package:feederr/models/categoryentry.dart';
import 'package:feederr/utils/dbhelper.dart';
import 'package:feederr/utils/utils.dart';
import 'package:feederr/widgets/category.dart';
import 'package:feederr/widgets/smart_category.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StarredArticleList extends StatefulWidget {
  final VoidCallback refreshParent;
  final List<CategoryEntry> categories;
  final String path;
  StarredArticleList({
    super.key,
    required this.refreshParent,
    required this.path,
    required this.categories,
  });

  @override
  State<StarredArticleList> createState() => _StarredArticleListState();
}

class _StarredArticleListState extends State<StarredArticleList> {
  DatabaseService databaseService = DatabaseService();
  bool isLocalLoading = false;
  List<SmartCategoryEntry> smartCategories = [];

  @override
  void initState() {
    super.initState();
    _createSmartViews();
  }

  Future<void> _createSmartViews() async {
    List<Article> liTodayArticles = [];
    List<Article> liAllArticles = [];
    SmartCategoryEntry liTodayFeedEntries;
    SmartCategoryEntry liAllFeedEntries;
    List<FeedEntry> tempTodayFeedEntries = [];
    List<FeedEntry> tempAllFeedEntries = [];
    for (CategoryEntry categoryEntry in widget.categories) {
      for (FeedEntry feedEntry in categoryEntry.feedEntry) {
        List<Article> tempTodayArticles = [];
        List<Article> tempAllArticles = [];
        for (Article article in feedEntry.articles) {
          if (isWithin24Hours(article.published)) {
            liTodayArticles.add(article);
            tempTodayArticles.add(article);
          }
          liAllArticles.add(article);
          tempAllArticles.add(article);
        }
        if (tempTodayArticles.isNotEmpty) {
          tempTodayFeedEntries.add(
            FeedEntry(
                feed: feedEntry.feed,
                articles: tempTodayArticles,
                count: tempTodayArticles.length),
          );
        }
        if (tempAllArticles.isNotEmpty) {
          tempAllFeedEntries.add(FeedEntry(
              feed: feedEntry.feed,
              articles: tempAllArticles,
              count: tempAllArticles.length));
        }
      }
    }
    if (tempAllFeedEntries.isNotEmpty) {
      liAllFeedEntries = SmartCategoryEntry(
          title: "All Articles",
          articles: liAllArticles,
          feeds: tempAllFeedEntries);
      smartCategories.add(liAllFeedEntries);
      if (tempTodayFeedEntries.isNotEmpty) {
        liTodayFeedEntries = SmartCategoryEntry(
            title: "Today",
            articles: liTodayArticles,
            feeds: tempTodayFeedEntries);
        smartCategories.add(liTodayFeedEntries);
      }
    }
    print(smartCategories.length);
    // widget.smartCategories.add(
    //   CategoryEntry(
    //       category: Category(name: "All articles"),
    //       feedEntry: [],
    //       articles: [],
    //       count: 10),
    // );
    // widget.smartCategories.add(
    //   CategoryEntry(
    //       category: Category(name: "Today"),
    //       feedEntry: [],
    //       articles: [],
    //       count: 10),
    // );
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
          delegate: SliverChildListDelegate(
            [
              Container(
                padding: const EdgeInsets.all(10),
                child: const Text("SMART VIEWS"),
              ),
            ],
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) => SmartCategoryListItem(
              category: smartCategories[index],
            ),
            childCount: smartCategories.length,
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            [
              Container(
                padding: const EdgeInsets.all(10),
                child: const Text("FOLDERS"),
              ),
            ],
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) =>
                CategoryListItem(category: widget.categories[index]),
            childCount: widget.categories.length,
          ),
        ),
      ],
    );
  }
}
