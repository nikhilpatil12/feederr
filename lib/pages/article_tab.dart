import 'dart:async';

import 'package:blazefeeds/models/article.dart';
import 'package:blazefeeds/models/feedentry.dart';
import 'package:blazefeeds/models/local_feeds/local_article.dart';
import 'package:blazefeeds/models/local_feeds/local_feed.dart';
import 'package:blazefeeds/models/local_feeds/local_feedentry.dart';
import 'package:blazefeeds/models/categories/smart_categoryentry.dart';
import 'package:blazefeeds/models/categories/categoryentry.dart';
import 'package:blazefeeds/pages/article_list.dart';
import 'package:blazefeeds/providers/individual_local_feed_provider.dart';
import 'package:blazefeeds/providers/server_categories_provider.dart';
import 'package:blazefeeds/utils/apiservice.dart';
import 'package:blazefeeds/utils/dbhelper.dart';
import 'package:blazefeeds/utils/utils.dart';
import 'package:blazefeeds/widgets/article.dart';
import 'package:blazefeeds/widgets/category.dart';
import 'package:blazefeeds/widgets/feed.dart';
import 'package:blazefeeds/widgets/local_feed.dart';
import 'package:blazefeeds/widgets/smart_category.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Debouncer {
  final Duration duration;
  Timer? _timer;
  int _currentVersion = 0;

  Debouncer({int milliseconds = 300}) : duration = Duration(milliseconds: milliseconds);

  void run(VoidCallback action) {
    _timer?.cancel();
    final version = ++_currentVersion;

    _timer = Timer(duration, () {
      if (!_timer!.isActive && version == _currentVersion) {
        action();
      }
    });
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    _currentVersion = 0;
  }
}

class ArticleSearchDelegate extends SearchDelegate<String> {
  final List<Article> articles;
  final Debouncer _debouncer;
  final APIService api;
  final DatabaseService databaseService;
  List<Article>? _cachedResults;
  String? _lastQuery;

  // Pre-compile regex patterns for better performance
  final RegExp _whitespaceRegex = RegExp(r'\s+');

  ArticleSearchDelegate({required this.articles, required this.api, required this.databaseService})
      : _debouncer = Debouncer(milliseconds: 300);

  @override
  void close(BuildContext context, String result) {
    _debouncer.dispose();
    super.close(context, result);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            _cachedResults = [];
            if (context.mounted) showSuggestions(context);
          },
        ),
    ];
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    // Cache theme values to avoid repeated lookups
    final secondaryColor = theme.colorScheme.secondary;
    final onSurfaceVariantColor = theme.colorScheme.onSurfaceVariant;

    return theme.copyWith(
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: secondaryColor,
        prefixIconColor: onSurfaceVariantColor,
        suffixIconColor: onSurfaceVariantColor,
        hintStyle: TextStyle(
          color: onSurfaceVariantColor,
          fontSize: 16,
        ),
      ),
      textTheme: theme.textTheme.copyWith(
        titleLarge: TextStyle(
          color: theme.colorScheme.onSurface,
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  List<Article> _filterAndSortArticles(String queryText) {
    // Return early if query is empty or cached results exist
    if (queryText.isEmpty) return [];
    if (queryText == _lastQuery && _cachedResults != null) {
      return _cachedResults!;
    }

    // Normalize query text by removing extra whitespace
    final queryLower = queryText.trim().toLowerCase().replaceAll(_whitespaceRegex, ' ');

    // Use Set for faster lookups during filtering
    final Set<Article> results = {};

    // Implement efficient filtering
    for (final article in articles) {
      if (article.title.toLowerCase().contains(queryLower) ||
          article.summaryContent.toLowerCase().contains(queryLower) ||
          article.alternate.toLowerCase().contains(queryLower) ||
          article.author.toLowerCase().contains(queryLower)) {
        results.add(article);
      }
    }

    // Convert to list and sort
    final sortedResults = results.toList()
      ..sort((a, b) {
        // Optimize sorting by reducing string operations
        final aTitleMatch = a.title.toLowerCase().contains(queryLower);
        final bTitleMatch = b.title.toLowerCase().contains(queryLower);

        if (aTitleMatch != bTitleMatch) return aTitleMatch ? -1 : 1;
        return b.published.compareTo(a.published);
      });

    _lastQuery = queryText;
    _cachedResults = sortedResults;
    return sortedResults;
  }

  @override
  Widget buildResults(BuildContext context) => _buildArticleList(_filterAndSortArticles(query));

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      _cachedResults = [];
      return const SizedBox.shrink();
    }

    _debouncer.run(() {
      if (!context.mounted) return;
      final suggestions = _filterAndSortArticles(query);
      if (_cachedResults != suggestions) {
        _cachedResults = suggestions;
        showSuggestions(context);
      }
    });

    return _cachedResults == null
        ? const Center(child: CircularProgressIndicator())
        : _buildArticleList(_cachedResults!);
  }

  Widget _buildArticleList(List<Article> items) {
    return ListView.builder(
      itemCount: items.length,
      // Add cacheExtent to improve scrolling performance
      cacheExtent: 100,
      itemBuilder: (context, index) => ArticleListItem(
        articles: items,
        articleIndex: index,
        api: api,
        databaseService: databaseService,
        onReturn: (_) {},
      ),
    );
  }
}

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
      List<CategoryEntry> categories, List<LocalFeedEntry> feedEntries) async {
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

    for (var feedEntry in feedEntries) {
      // LocalFeedEntry feedEntry = entry;
      // Now you can use `key` and `provider`

      // for (LocalFeedEntry feedEntry in localFeeds) {
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
      _createSmartViews(sCatogoriesProvider.categoryEntries, localFeeds.getAllFeedEntries());
      ThemeData theme = Theme.of(context);
      return RawScrollbar(
        interactive: true,
        thumbColor: theme.primaryColor,
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
              // SliverToBoxAdapter(
              //   child: SizedBox(height: 150),
              // ),
              CupertinoSliverRefreshControl(
                onRefresh: () async {
                  widget.refreshParent();
                },
              ),
              // SliverAppBar(
              //   floating: true,
              //   // Use a Material design search bar
              //   title: TextField(
              //     controller: _searchController,
              //     decoration: InputDecoration(
              //       hintText: 'Search...',
              //       // Add a clear button to the search bar
              //       suffixIcon: IconButton(
              //         icon: Icon(
              //           Icons.clear,
              //           color: Colors.black,
              //         ),
              //         onPressed: () => _searchController.clear(),
              //       ),
              //     ),
              //   ),
              // ),
              SliverToBoxAdapter(
                child: IconButton.filledTonal(
                  icon: Icon(Icons.search),
                  onPressed: () => showSearch(
                      useRootNavigator: true,
                      context: context,
                      delegate: ArticleSearchDelegate(
                          articles: smartCategories.isNotEmpty
                              ? smartCategories
                                  .where((category) => category.title == "All Articles")
                                  .expand((category) => category.articles)
                                  .toList()
                              : [],
                          api: widget.api,
                          databaseService: widget.databaseService)),
                ),
                // child: SearchAnchor(

                //   // isFullScreen: true,
                //   builder: (context, controller) {
                //     return IconButton.outlined(
                //       icon: Icon(Icons.search),
                //       autofocus: false,
                //       onPressed: () => controller.openView(),
                //       // textInputAction: TextInputAction.search,
                //       // controller: controller,
                //       // decoration: InputDecoration(
                //       //   hintText: 'Search...',
                //       //   prefixIcon: Icon(Icons.search),
                //       //   // suffixIcon: IconButton(
                //       //   //   icon: Icon(Icons.clear),
                //       //   //   onPressed: () {
                //       //   //     controller.clear();
                //       //   //   },
                //       //   // ),
                //       // ),
                //     );
                //     // TextField(
                //     //   autofocus: false,
                //     //   onTap: () => controller.openView(),
                //     //   textInputAction: TextInputAction.search,
                //     //   controller: controller,
                //     //   decoration: InputDecoration(
                //     //     hintText: 'Search...',
                //     //     prefixIcon: Icon(Icons.search),
                //     //     // suffixIcon: IconButton(
                //     //     //   icon: Icon(Icons.clear),
                //     //     //   onPressed: () {
                //     //     //     controller.clear();
                //     //     //   },
                //     //     // ),
                //     //   ),
                //     // );
                //   },
                // //   viewElevation: 0,
                // //   // useRootNavigator: true,
                // //   suggestionsBuilder: (context, controller) async {
                // //     final String searchText = controller.text;
                // //     List<Article> articles = smartCategories.isNotEmpty
                // //         ? smartCategories
                // //             .where((category) => category.title == "All Articles")
                // //             .expand((category) => category.articles)
                // //             .toList()
                // //         : [];

                // //     if (searchText.isEmpty) return [];

                // //     final searchLower = searchText.toLowerCase();
                // //     var results = articles.where((article) {
                // //       final titleLower = article.title.toLowerCase();
                // //       final authorLower = article.author.toLowerCase();
                // //       final summaryLower = article.summaryContent.toLowerCase();

                // //       return titleLower.contains(searchLower) ||
                // //           authorLower.contains(searchLower) ||
                // //           summaryLower.contains(searchLower);
                // //     }).toList();

                // //     results.sort((a, b) {
                // //       // Priority scoring
                // //       int scoreA = 0, scoreB = 0;

                // //       // Title matches (highest priority)
                // //       if (a.title.toLowerCase().contains(searchLower)) scoreA += 100;
                // //       if (b.title.toLowerCase().contains(searchLower)) scoreB += 100;

                // //       // Author matches (medium priority)
                // //       if (a.author.toLowerCase().contains(searchLower)) scoreA += 50;
                // //       if (b.author.toLowerCase().contains(searchLower)) scoreB += 50;

                // //       // If scores are equal, sort by timestamp
                // //       if (scoreA == scoreB) {
                // //         return b.published.compareTo(a.published);
                // //       }

                // //       return scoreB - scoreA;
                // //     });

                // //     return results
                // //         .map((article) => ArticleListItem(
                // //               articles: results,
                // //               articleIndex: results.indexOf(article),
                // //               api: widget.api,
                // //               databaseService: widget.databaseService,
                // //               onReturn: (_) {},
                // //             ))
                // //         .toList();
                // //   },
                // ),
              ),
              // Expanded(
              //   child: ListView.builder(
              //     itemCount: smartCategories.isEmpty
              //         ? 0
              //         : smartCategories[0].articles.length,
              //     itemBuilder: (context, index) {
              //       final article = smartCategories[0].articles[index];
              //       return ArticleListItem(
              //         articles: smartCategories[0].articles,
              //         articleIndex: index,
              //         api: widget.api,
              //         databaseService: widget.databaseService,
              //         onReturn: (_) {},
              //       );
              //     },
              //   ),
              // ),

              //     ),
              //   ),
              // );
              // showSearch(
              //   context: context,
              //   // useRootNavigator: true,
              //   delegate: ArticleSearchDelegate(
              //     articles: smartCategories.isNotEmpty
              //         ? smartCategories
              //             .where((category) => category.title == "All Articles")
              //             .expand((category) => category.articles)
              //             .toList()
              //         : [],
              //     api: widget.api,
              //     databaseService: widget.databaseService,
              //   ),
              // );
              // },
              // child: Container(
              //   margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              //   decoration: BoxDecoration(
              //     color: Theme.of(context).colorScheme.secondary,
              //     borderRadius: BorderRadius.circular(28),
              //   ),
              //   child: Padding(
              //     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              //     child: Row(
              //       children: [
              //         Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant),
              //         SizedBox(width: 12),
              //         Text(
              //           'Search',
              //           style: TextStyle(
              //             color: Theme.of(context).colorScheme.onSurfaceVariant,
              //             fontVariations: [FontVariation.weight(500)],
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              //   ),
              // ),

              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: smartCategories.isNotEmpty
                          ? Text(
                              "Smart Views",
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
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
              // SliverToBoxAdapter(
              //   child: Divider(
              //     color: theme.dividerColor,
              //     height: 0.1,
              //     thickness: 0.1,
              //   ),
              // ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Container(
                      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 25),
                      child: sCatogoriesProvider.isNotEmpty
                          ? Text(
                              "Folders",
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
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
                  ),
                  childCount: sCatogoriesProvider.length,
                ),
              ),
              // SliverToBoxAdapter(
              //   child: Divider(
              //     color: theme.dividerColor,
              //     height: 0.1,
              //     thickness: 0.1,
              //   ),
              // ),

              // Local Articles
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Container(
                      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 25),
                      child: localFeeds.isNotEmpty
                          ? Text(
                              "Local Feeds",
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : Container(),
                    ),
                  ],
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    String feedId = localFeeds.getAllFeedProviders().keys.elementAt(index);
                    IndividualLocalFeedProvider feedProvider =
                        localFeeds.getSingleFeedProvider(feedId);

                    return ChangeNotifierProvider(
                      create: (_) => feedProvider,
                      child: LocalFeedListItem(
                        feed: feedProvider.feed,
                        api: widget.api,
                        databaseService: widget.databaseService,
                        callback: widget.refreshParent,
                      ),
                    );
                  },
                  childCount: localFeeds.length,
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      );
    });
  }
}
