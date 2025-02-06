import 'package:cached_network_image/cached_network_image.dart';
import 'package:blazefeeds/models/app_theme.dart';
import 'package:blazefeeds/models/local_feeds/local_article.dart';
import 'package:blazefeeds/models/local_feeds/local_feedentry.dart';
import 'package:blazefeeds/pages/article_list.dart';
import 'package:blazefeeds/providers/individual_local_feed_provider.dart';
import 'package:blazefeeds/utils/apiservice.dart';
import 'package:blazefeeds/utils/dbhelper.dart';
import 'package:blazefeeds/providers/theme_provider.dart';
import 'package:blazefeeds/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

// class LocalFeedListView extends StatefulWidget {
//   const LocalFeedListView({
//     super.key,
//     required this.feeds,
//     // required this.articles,
//     // required this.count,
//     required this.api,
//     required this.databaseService,
//     required this.refreshAllCallback,
//   });

//   final List<LocalFeedEntry> feeds;
//   // final List<LocalArticle> articles;
//   // final int count;
//   final APIService api;
//   final DatabaseService databaseService;
//   final VoidCallback refreshAllCallback;

//   @override
//   State<LocalFeedListView> createState() => _LocalFeedListViewState();
// }

// class _LocalFeedListViewState extends State<LocalFeedListView> {
//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       padding: const EdgeInsets.all(0),
//       itemCount: widget.feeds.length,
//       itemBuilder: (context, index) {
//         final feed = widget.feeds[index];
//         // final articles = widget.articles;
//         // final count = widget.count;
//         return LocalFeedListItem(
//           feed: feed,
//           // articles: articles,
//           // count: count,
//           api: widget.api,
//           databaseService: widget.databaseService,
//           callback: widget.refreshAllCallback,
//         );
//       },
//     );
//   }
// }

class LocalFeedListItem extends StatefulWidget {
  const LocalFeedListItem({
    super.key,
    required this.feed,
    // required this.articles,
    // required this.count,
    required this.api,
    required this.databaseService,
    required this.callback,
  });
  final LocalFeedEntry feed;
  // final List<LocalArticle> articles;
  // final int count;
  final APIService api;
  final DatabaseService databaseService;
  final VoidCallback callback;

  @override
  State<LocalFeedListItem> createState() => _LocalFeedListItemState();
}

class _LocalFeedListItemState extends State<LocalFeedListItem> {
  final ValueNotifier<Color> _colorNotifier = ValueNotifier<Color>(Colors.transparent);
  late final AppUtils utils;

  @override
  void initState() {
    super.initState();
    utils = AppUtils();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<LocalFeedsProvider, IndividualLocalFeedProvider>(
        selector: (_, localFeedsProvider) =>
            localFeedsProvider.getSingleFeedProvider(widget.feed.feedUrl.baseUrl),
        builder: (_, localFeedProvider, __) {
          return Selector<ThemeProvider, AppTheme>(
            selector: (_, themeProvider) => themeProvider.theme,
            builder: (_, theme, __) {
              return localFeedProvider.feed.articles.isNotEmpty
                  ? GestureDetector(
                      onTap: () => {
                        showFeed(
                          context,
                          localFeedProvider.feed,
                          widget.api,
                          widget.databaseService,
                          widget.callback,
                        )
                      },
                      onTapDown: (tapDetails) => {
                        _colorNotifier.value = Color(theme.primaryColor).withAlpha(90),
                      },
                      onTapUp: (tapDetails) => {
                        Future.delayed(const Duration(milliseconds: 200), () {
                          _colorNotifier.value = const Color.fromARGB(0, 0, 0, 0);
                        })
                      },
                      onTapCancel: () => {
                        Future.delayed(const Duration(milliseconds: 200), () {
                          _colorNotifier.value = const Color.fromARGB(0, 0, 0, 0);
                        })
                      },
                      child: Slidable(
                        key: Key(localFeedProvider.feed.feedUrl.baseUrl),
                        // Specify a key if the Slidable is dismissible.
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            Theme(
                              data: Theme.of(context).copyWith(
                                outlinedButtonTheme: OutlinedButtonThemeData(
                                  style: ButtonStyle(
                                    iconColor: WidgetStatePropertyAll(
                                      Color(theme.textColor),
                                    ),
                                  ),
                                ),
                              ),
                              child: SlidableAction(
                                onPressed: (_) => {
                                  showFeed(context, localFeedProvider.feed, widget.api,
                                      widget.databaseService, widget.callback),
                                },
                                backgroundColor: Color(theme.primaryColor).withAlpha(180),
                                icon: CupertinoIcons.news,
                              ),
                            ),
                            Theme(
                              data: Theme.of(context).copyWith(
                                outlinedButtonTheme: OutlinedButtonThemeData(
                                  style: ButtonStyle(
                                    iconColor: WidgetStatePropertyAll(
                                      Color(theme.textColor),
                                    ),
                                  ),
                                ),
                              ),
                              child: SlidableAction(
                                onPressed: (_) => {
                                  //TODO: DELETE FEED
                                  widget.databaseService
                                      .deleteLocalFeed(localFeedProvider.feed.feed.id ?? 0),
                                },
                                padding: EdgeInsets.all(10),
                                backgroundColor: Colors.deepOrange,
                                icon: CupertinoIcons.delete,
                              ),
                            ),
                          ],
                        ),
                        child: ValueListenableBuilder<Color>(
                          valueListenable: _colorNotifier,
                          builder: (context, color, child) {
                            return Container(
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: color,
                                //   borderRadius: const BorderRadius.all(
                                //     Radius.circular(10),
                                // ),
                              ),
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: child,
                            );
                          },
                          child: _FeedDetails(
                            feed: localFeedProvider.feed,
                            api: widget.api,
                          ),
                        ),
                      ),
                    )
                  : Container();
            },
          );
        });
  }
}

class _FeedDetails extends StatelessWidget {
  const _FeedDetails({required this.feed, required this.api});

  final LocalFeedEntry feed;
  final APIService api;

  @override
  Widget build(BuildContext context) {
    return Selector<ThemeProvider, AppTheme>(
        selector: (_, themeProvider) => themeProvider.theme,
        builder: (_, theme, __) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  fit: FlexFit.tight,
                  child: FutureBuilder(
                    future: _loadImage(feed.feed.iconUrl, theme),
                    builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Image.asset(
                          "assets/rss-16.png",
                          color: Color(theme.textColor),
                        );
                      } else if (snapshot.hasError) {
                        return Image.asset("assets/rss-16.png", color: Color(theme.textColor));
                      } else if (snapshot.hasData) {
                        return snapshot.data!; // The built widget
                      } else {
                        return Image.asset("assets/rss-16.png", color: Color(theme.textColor));
                      }
                    },
                  ),
                ),
                const Padding(padding: EdgeInsets.only(left: 10)),
                Flexible(
                  flex: 10,
                  fit: FlexFit.tight,
                  child: Text(
                    feed.feed.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14.0,
                      color: Color(theme.textColor),
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 4, 4, 4),
                  child: Wrap(
                    children: [
                      Text(
                        feed.articles.length.toString(),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Color(theme.primaryColor),
                        ),
                      ),
                      Icon(
                        size: 20,
                        CupertinoIcons.right_chevron,
                        color: Color(theme.primaryColor),
                      ),
                    ],
                  ),
                ),
              ],
              // Icon(
              //   CupertinoIcons.right_chevron,
              //   color: const Color.fromRGBO(76, 2, 232, 1),
              // ),
            ),
          );
        });
  }

  Future<Widget> _loadImage(String src, AppTheme theme) async {
    try {
      var response = await http.get(Uri.parse(src));
      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'];
        if (contentType?.startsWith('image/svg') ?? false) {
          return SvgPicture.memory(response.bodyBytes);
        } else {
          return CachedNetworkImage(
            cacheManager: api.cacheManager,
            width: 20,
            height: 20,
            imageUrl: feed.feed.iconUrl,
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                const CupertinoActivityIndicator(),
            errorWidget: (context, url, error) =>
                Image.asset("assets/rss-16.png", color: Color(theme.textColor)),
          );
        }
      } else {
        // Handle error
        return Image.asset("assets/rss-16.png", color: Color(theme.textColor));
      }
    } catch (error) {
      // Handle error
      return Image.asset("assets/rss-16.png", color: Color(theme.textColor));
    }
  }
}

Future<void> onReturnToHome(LocalFeedsProvider localFeedsProvider, LocalFeedEntry feed) async {
  localFeedsProvider.updateFeedProvider(feed.feedUrl.baseUrl, feed);
}

void showFeed(
  BuildContext context,
  LocalFeedEntry feed,
  APIService api,
  DatabaseService databaseService,
  VoidCallback refreshAllCallback,
) {
  HapticFeedback.mediumImpact();
  Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute<void>(
      builder: (BuildContext context) {
        return ArticleList(
          refreshParent: refreshAllCallback,
          articles: convertLocalArticlesToArticles(feed.articles),
          api: api,
          databaseService: databaseService,
          title: feed.feed.title,
        );
      },
    ),
  ).then((_) {
    // This will be called after Navigator.pop() on NextPage
    LocalFeedsProvider localFeedsProvider = Provider.of<LocalFeedsProvider>(context, listen: false);
    onReturnToHome(localFeedsProvider, feed);
  });
}
