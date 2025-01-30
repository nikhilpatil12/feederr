import 'package:feederr/models/app_theme.dart';
import 'package:feederr/models/article.dart';
import 'package:feederr/models/feedentry.dart';
import 'package:feederr/models/local_feeds/local_article.dart';
import 'package:feederr/models/local_feeds/local_feed.dart';
import 'package:feederr/models/local_feeds/local_feedentry.dart';
import 'package:feederr/models/categories/smart_categoryentry.dart';
import 'package:feederr/models/categories/categoryentry.dart';
import 'package:feederr/providers/local_feed_provider.dart';
import 'package:feederr/providers/server_categories_provider.dart';
import 'package:feederr/utils/apiservice.dart';
import 'package:feederr/utils/dbhelper.dart';
import 'package:feederr/providers/theme_provider.dart';
import 'package:feederr/utils/utils.dart';
import 'package:feederr/widgets/category.dart';
import 'package:feederr/widgets/local_feed.dart';
import 'package:feederr/widgets/smart_category.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class TabEntry extends StatefulWidget {
  final VoidCallback refreshParent;
  final String path;
  final APIService api;
  final DatabaseService databaseService;
  final AppUtils utils = AppUtils();
  TabEntry({
    super.key,
    required this.refreshParent,
    required this.path,
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
  }

  Future<void> _createSmartViews(
      List<CategoryEntry> categories, List<LocalFeedEntry> localFeeds) async {
    smartCategories = [];
    List<Article> liTodayArticles = [];
    List<Article> liAllArticles = [];
    SmartCategoryEntry liTodayFeedEntries;
    SmartCategoryEntry liAllFeedEntries;
    List<FeedEntry> tempTodayFeedEntries = [];
    List<FeedEntry> tempAllFeedEntries = [];
    for (CategoryEntry categoryEntry in categories) {
      for (FeedEntry feedEntry in categoryEntry.feedEntry) {
        List<Article> tempTodayArticles = [];
        List<Article> tempAllArticles = [];
        for (Article article in feedEntry.articles) {
          if (widget.utils.isWithin24Hours(article.published)) {
            liTodayArticles.add(article);
            tempTodayArticles.add(article);
          }
          liAllArticles.add(article);
          tempAllArticles.add(article);
        }
        if (tempTodayArticles.isNotEmpty) {
          tempTodayFeedEntries.add(
            FeedEntry(
                feed: feedEntry.feed, articles: tempTodayArticles, count: tempTodayArticles.length),
          );
        }
        if (tempAllArticles.isNotEmpty) {
          tempAllFeedEntries.add(FeedEntry(
              feed: feedEntry.feed, articles: tempAllArticles, count: tempAllArticles.length));
        }
      }
    }
    for (LocalFeedEntry feedEntry in localFeeds) {
      List<Article> tempTodayArticles = [];
      List<Article> tempAllArticles = [];
      for (LocalArticle localArticle in feedEntry.articles) {
        Article article = localArticle.toArticle();
        if (widget.utils.isWithin24Hours(article.published)) {
          liTodayArticles.add(article);
          tempTodayArticles.add(article);
        }
        liAllArticles.add(article);
        tempAllArticles.add(article);
      }
      if (tempTodayArticles.isNotEmpty) {
        tempTodayFeedEntries.add(
          FeedEntry(
              feed: feedEntry.feed.toFeed(),
              articles: tempTodayArticles,
              count: tempTodayArticles.length),
        );
      }
      if (tempAllArticles.isNotEmpty) {
        tempAllFeedEntries.add(FeedEntry(
            feed: feedEntry.feed.toFeed(),
            articles: tempAllArticles,
            count: tempAllArticles.length));
      }
    }

    if (tempAllFeedEntries.isNotEmpty) {
      liAllFeedEntries = SmartCategoryEntry(
          title: "All Articles", articles: liAllArticles, feeds: tempAllFeedEntries);
      smartCategories.add(liAllFeedEntries);
      if (tempTodayFeedEntries.isNotEmpty) {
        liTodayFeedEntries = SmartCategoryEntry(
            title: "Today", articles: liTodayArticles, feeds: tempTodayFeedEntries);
        smartCategories.add(liTodayFeedEntries);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localFeeds = Provider.of<LocalFeedsProvider>(context);
    return Consumer<ServerCatogoriesProvider>(builder: (_, sCatogoriesProvider, __) {
      _createSmartViews(sCatogoriesProvider.categoryEntries, localFeeds.feeds);
      return Selector<ThemeProvider, AppTheme>(
          selector: (_, themeProvider) => themeProvider.theme,
          builder: (_, theme, __) {
            return RawScrollbar(
              interactive: true,
              thumbColor: Color(theme.primaryColor),
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
                            child: smartCategories.isNotEmpty
                                ? Text(
                                    "SMART VIEWS",
                                    style: TextStyle(
                                      color: Color(theme.textColor),
                                    ),
                                  )
                                : Container(),
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
                          refreshAllCallback: widget.refreshParent,
                        ),
                        childCount: smartCategories.length,
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Container(
                            padding: const EdgeInsets.all(10),
                            child: sCatogoriesProvider.isNotEmpty
                                ? Text(
                                    "FOLDERS",
                                    style: TextStyle(
                                      color: Color(theme.textColor),
                                    ),
                                  )
                                : Container(),
                          ),
                        ],
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) => CategoryListItem(
                          refreshAllCallback: widget.refreshParent,
                          category: sCatogoriesProvider.categoryEntries[index],
                          api: widget.api,
                          databaseService: widget.databaseService,
                        ),
                        childCount: sCatogoriesProvider.length,
                      ),
                    ),

                    // Local Articles
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Container(
                            padding: const EdgeInsets.all(10),
                            child: localFeeds.isNotEmpty
                                ? Text(
                                    "LOCAL FEEDS",
                                    style: TextStyle(
                                      color: Color(theme.textColor),
                                    ),
                                  )
                                : Container(),
                          ),
                        ],
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) => LocalFeedListItem(
                          count: localFeeds.feeds[index].articles.length,
                          articles: localFeeds.feeds[index].articles,
                          feed: localFeeds.feeds[index],
                          api: widget.api,
                          databaseService: widget.databaseService,
                          callback: widget.refreshParent,
                        ),
                        childCount: localFeeds.length,
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
    });
  }
}
