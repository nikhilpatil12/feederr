import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:feederr/models/app_theme.dart';
import 'package:feederr/models/article.dart';
import 'package:feederr/models/feedentry.dart';
import 'package:feederr/models/font_settings.dart';
import 'package:feederr/pages/article_list.dart';
import 'package:feederr/utils/apiservice.dart';
import 'package:feederr/utils/dbhelper.dart';
import 'package:feederr/utils/themeprovider.dart';
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
  });

  final List<FeedEntry> feeds;
  final List<Article> articles;
  final int count;
  final APIService api;
  final DatabaseService databaseService;

  @override
  State<FeedListView> createState() => _FeedListViewState();
}

class _FeedListViewState extends State<FeedListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(0),
      itemCount: widget.feeds.length,
      itemBuilder: (context, index) {
        final feed = widget.feeds[index];
        final articles = widget.articles;
        final count = widget.count;
        return FeedListItem(
          feed: feed,
          articles: articles,
          count: count,
          api: widget.api,
          databaseService: widget.databaseService,
        );
      },
    );
  }
}

class FeedListItem extends StatefulWidget {
  const FeedListItem({
    super.key,
    required this.feed,
    required this.articles,
    required this.count,
    required this.api,
    required this.databaseService,
  });
  final FeedEntry feed;
  final List<Article> articles;
  final int count;
  final APIService api;
  final DatabaseService databaseService;

  @override
  State<FeedListItem> createState() => _FeedListItemState();
}

class _FeedListItemState extends State<FeedListItem> {
  Color _color = Colors.transparent;
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return GestureDetector(
        onTap: () => {
          showFeed(context, widget.feed, themeProvider.theme,
              themeProvider.fontSettings, widget.api, widget.databaseService)
        },
        onTapDown: (tapDetails) => {
          setState(() {
            _color = Color(themeProvider.theme.primaryColor);
          })
        },
        onTapUp: (tapDetails) => {
          Future.delayed(const Duration(milliseconds: 200), () {
            setState(() {
              _color = const Color.fromARGB(0, 0, 0, 0);
              // code to be executed after 2 seconds
            });
          })
        },
        onTapCancel: () => {
          Future.delayed(const Duration(milliseconds: 200), () {
            setState(() {
              _color = const Color.fromARGB(0, 0, 0, 0);
              // code to be executed after 2 seconds
            });
          })
        },
        child: Slidable(
          // Specify a key if the Slidable is dismissible.
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (_) => {
                  showFeed(
                      context,
                      widget.feed,
                      themeProvider.theme,
                      themeProvider.fontSettings,
                      widget.api,
                      widget.databaseService),
                },
                backgroundColor: Color(themeProvider.theme.primaryColor),
                foregroundColor: Colors.white,
                icon: CupertinoIcons.news,
                // label: 'Delete',
              ),
            ],
          ),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: _color,
              //   borderRadius: const BorderRadius.all(
              //     Radius.circular(10),
              // ),
            ),
            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: _FeedDetails(feed: widget.feed),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _FeedDetails extends StatelessWidget {
  const _FeedDetails({required this.feed});

  final FeedEntry feed;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return Padding(
        padding: EdgeInsets.only(
            left: MediaQuery.sizeOf(context).width / 10, top: 8, bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Flexible(
              fit: FlexFit.tight,
              child: FutureBuilder(
                future: _loadImage(feed.feed.iconUrl),
                builder:
                    (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Image.asset("assets/rss-16.png");
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    return snapshot.data!; // The built widget
                  } else {
                    return const Text('Something went wrong');
                  }
                },
              ),
            ),
            // CachedNetworkImage(
            //   width: 20,
            //   height: 20,
            //   imageUrl: feed.feed.iconUrl,
            //   progressIndicatorBuilder: (context, url, downloadProgress) =>
            //       const CupertinoActivityIndicator(),
            //   errorWidget: (context, url, error) =>
            //       Image.asset("assets/rss-16.png"),
            // ),
            const Padding(padding: EdgeInsets.only(left: 10)),
            Flexible(
              flex: 10,
              fit: FlexFit.tight,
              child: Text(
                feed.feed.title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14.0,
                  color: Color(themeProvider.theme.textColor),
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 4, 4),
              child: Wrap(
                children: [
                  Text(
                    feed.count.toString(),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Color(themeProvider.theme.primaryColor),
                    ),
                  ),
                  Icon(
                    size: 20,
                    CupertinoIcons.right_chevron,
                    color: Color(themeProvider.theme.primaryColor),
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
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                const CupertinoActivityIndicator(),
            errorWidget: (context, url, error) =>
                Image.asset("assets/rss-16.png"),
          );
        }
      } else {
        // Handle error
        return Container();
      }
    } catch (error) {
      // Handle error
      return Container();
    }
  }
}

void showFeed(
    BuildContext context,
    FeedEntry feed,
    AppTheme theme,
    FontSettings fontSettings,
    APIService api,
    DatabaseService databaseService) {
  HapticFeedback.mediumImpact();
  Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute<void>(
      builder: (BuildContext context) {
        return Scaffold(
          // extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Color(theme.surfaceColor).withAlpha(56),
            elevation: 0,
            title: Text(
              feed.feed.title,
              style: TextStyle(
                color: Color(theme.textColor),
              ),
              overflow: TextOverflow.fade,
            ),
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 36,
                  sigmaY: 36,
                ),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
          body: ArticleList(
            refreshParent: () => {},
            articles: feed.articles,
            api: api,
            databaseService: databaseService,
          ),
        );
      },
    ),
  );
}
