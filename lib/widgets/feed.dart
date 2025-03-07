import 'package:cached_network_image/cached_network_image.dart';
import 'package:blazefeeds/models/app_theme.dart';
import 'package:blazefeeds/models/article.dart';
import 'package:blazefeeds/models/feedentry.dart';
import 'package:blazefeeds/pages/article_list.dart';
import 'package:blazefeeds/utils/apiservice.dart';
import 'package:blazefeeds/utils/dbhelper.dart';
import 'package:blazefeeds/providers/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class FeedListView extends StatefulWidget {
  const FeedListView({
    super.key,
    required this.feeds,
    required this.articles,
    required this.count,
    required this.api,
    required this.databaseService,
    required this.refreshAllCallback,
  });

  final List<FeedEntry> feeds;
  final List<Article> articles;
  final int count;
  final APIService api;
  final DatabaseService databaseService;
  final VoidCallback refreshAllCallback;

  @override
  State<FeedListView> createState() => _FeedListViewState();
}

class _FeedListViewState extends State<FeedListView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 0),
        itemCount: widget.feeds.length,
        itemBuilder: (context, index) {
          final feed = widget.feeds[index];
          final articles = widget.articles;
          final count = widget.count;
          return FeedListItem(
            feed: feed,
            articles: articles,
            count: count,
            refreshAllCallback: widget.refreshAllCallback,
          );
        },
      ),
    );
  }
}

class FeedListItem extends StatefulWidget {
  const FeedListItem({
    super.key,
    required this.feed,
    required this.articles,
    required this.count,
    required this.refreshAllCallback,
  });
  final FeedEntry feed;
  final List<Article> articles;
  final int count;
  final VoidCallback refreshAllCallback;

  @override
  State<FeedListItem> createState() => _FeedListItemState();
}

class _FeedListItemState extends State<FeedListItem> {
  late final APIService api;
  late final DatabaseService databaseService;
  final ValueNotifier<BoxDecoration> _decorationNotifier = ValueNotifier<BoxDecoration>(
    BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
    ),
  );

  @override
  void initState() {
    super.initState();
    api = APIService();
    databaseService = DatabaseService();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return GestureDetector(
      // behavior: HitTestBehavior.,
      onTap: () => {
        showFeed(
          context,
          widget.feed,
          api,
          databaseService,
          widget.refreshAllCallback,
        ),
      },
      onTapDown: (tapDetails) => {
        // setState(() {
        _decorationNotifier.value = BoxDecoration(
          color: theme.primaryColor.withAlpha(90),
          // borderRadius: BorderRadius.circular(8),
        ),

        // _colorNotifier.value =
        //     Color(theme.primaryColor).withAlpha(90),
        // })
      },
      onTapUp: (tapDetails) => {
        Future.delayed(const Duration(milliseconds: 200), () {
          // setState(() {

          _decorationNotifier.value = BoxDecoration(
            color: Colors.transparent,
            // borderRadius: BorderRadius.circular(8),
          );

          // _colorNotifier.value = const Color.fromARGB(0, 0, 0, 0);
          // code to be executed after 2 seconds
          // });
        })
      },
      onTapCancel: () => {
        Future.delayed(const Duration(milliseconds: 200), () {
          // setState(() {
          _decorationNotifier.value = BoxDecoration(
            color: Colors.transparent,
            // borderRadius: BorderRadius.circular(8),
          );
          // code to be executed after 2 seconds
          // });
        })
      },
      child: Slidable(
        // Specify a key if the Slidable is dismissible.
        endActionPane: ActionPane(
          extentRatio: 0.3,
          motion: const ScrollMotion(),
          children: [
            Theme(
              data: Theme.of(context).copyWith(
                outlinedButtonTheme: OutlinedButtonThemeData(
                  style: ButtonStyle(
                    iconColor: WidgetStatePropertyAll(
                      theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              child: SlidableAction(
                onPressed: (_) => {
                  showFeed(
                    context,
                    widget.feed,
                    api,
                    databaseService,
                    widget.refreshAllCallback,
                  ),
                },
                backgroundColor: theme.primaryColor.withAlpha(180),
                // foregroundColor: Colors.white,
                icon: CupertinoIcons.news,
                // label: 'Delete',
              ),
            ),
          ],
        ),
        // padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),

        child: ValueListenableBuilder<BoxDecoration>(
          valueListenable: _decorationNotifier,
          builder: (context, decoration, child) {
            return Container(
              decoration: decoration,
              child: child,
            );
          },
          child: _FeedDetails(
            feed: widget.feed,
            api: api,
          ),
        ),
      ),
    );
  }
}

class _FeedDetails extends StatelessWidget {
  const _FeedDetails({required this.feed, required this.api});

  final FeedEntry feed;
  final APIService api;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Container(
      // decoration: BoxDecoration(
      //   border: Border(
      //     top: BorderSide(color: theme.dividerColor, width: 0.1),
      //   ),
      // ),
      padding: EdgeInsets.only(
        left: 40,
        top: 8,
        bottom: 8,
        right: 20,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Flexible(
            fit: FlexFit.tight,
            child: FutureBuilder(
              future: _loadImage(feed.feed.iconUrl),
              builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Image.asset("assets/rss-16.png");
                } else if (snapshot.hasError) {
                  return Image.asset("assets/rss-16.png");
                } else if (snapshot.hasData) {
                  // log("Image has snapshot: ${feed.feed.iconUrl}");
                  return snapshot.data!; // The built widget
                } else {
                  return Image.asset("assets/rss-16.png");
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
                // fontWeight: FontWeight.w500,
                fontSize: 14.0,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          // const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 4, 4, 4),
            child: Wrap(
              children: [
                Text(
                  feed.count.toString(),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: theme.primaryColor,
                  ),
                ),
                // Icon(
                //   size: 20,
                //   CupertinoIcons.right_chevron,
                //   color: Color(theme.primaryColor),
                // ),
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
  }

  Future<Widget> _loadImage(String src) async {
    try {
      var response = await http.get(Uri.parse(src));
      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'];
        if (contentType?.startsWith('image/svg') ?? false) {
          return SvgPicture.memory(response.bodyBytes);
        } else {
          return CachedNetworkImage(
            width: 20,
            height: 20,
            imageUrl: feed.feed.iconUrl,
            cacheManager: api.cacheManager,
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                const CupertinoActivityIndicator(),
            errorWidget: (context, url, error) => Image.asset("assets/rss-16.png"),
          );
        }
      } else {
        // Handle error
        return Image.asset("assets/rss-16.png");
      }
    } catch (error) {
      // Handle error
      return Image.asset("assets/rss-16.png");
    }
  }
}

void showFeed(BuildContext context, FeedEntry feed, APIService api, DatabaseService databaseService,
    VoidCallback refreshAllCallback) {
  HapticFeedback.mediumImpact();
  Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute<void>(
      builder: (BuildContext context) {
        return ArticleList(
          refreshParent: refreshAllCallback,
          articles: feed.articles,
          title: feed.feed.title,
        );
      },
    ),
  );
}
