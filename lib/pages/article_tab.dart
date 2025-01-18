import 'package:feederr/models/app_theme.dart';
import 'package:feederr/models/article.dart';
import 'package:feederr/models/feedentry.dart';
import 'package:feederr/models/font_settings.dart';
import 'package:feederr/models/smart_categoryentry.dart';
import 'package:feederr/models/categoryentry.dart';
import 'package:feederr/utils/apiservice.dart';
import 'package:feederr/utils/dbhelper.dart';
import 'package:feederr/utils/themeprovider.dart';
import 'package:feederr/utils/utils.dart';
import 'package:feederr/widgets/category.dart';
import 'package:feederr/widgets/smart_category.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class TabEntry extends StatefulWidget {
  final VoidCallback refreshParent;
  final List<CategoryEntry> categories;
  final String path;
  final APIService api;
  final DatabaseService databaseService;
  const TabEntry({
    super.key,
    required this.refreshParent,
    required this.path,
    required this.categories,
    required this.api,
    required this.databaseService,
  });

  @override
  State<TabEntry> createState() => _TabEntryState();
}

class _TabEntryState extends State<TabEntry> {
  final ScrollController _scrollController = ScrollController();
  // DatabaseService databaseService = DatabaseService();
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
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return RawScrollbar(
        interactive: true,
        thumbColor: Color(themeProvider.theme.primaryColor),
        thickness: 2,
        radius: const Radius.circular(2),
        controller: _scrollController,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: CustomScrollView(
            controller: _scrollController,
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
                      child: Text(
                        "SMART VIEWS",
                        style: TextStyle(
                          color: Color(themeProvider.theme.textColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) => SmartCategoryListItem(
                    category: smartCategories[index],
                    api: widget.api,
                    databaseService: widget.databaseService,
                  ),
                  childCount: smartCategories.length,
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        "FOLDERS",
                        style: TextStyle(
                          color: Color(themeProvider.theme.textColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) => CategoryListItem(
                    category: widget.categories[index],
                    api: widget.api,
                    databaseService: widget.databaseService,
                  ),
                  childCount: widget.categories.length,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
