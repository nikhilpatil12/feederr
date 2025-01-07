import 'package:cached_network_image/cached_network_image.dart';
import 'package:feederr/models/app_theme.dart';
import 'package:feederr/models/article.dart';
import 'package:feederr/models/feedentry.dart';
import 'package:feederr/pages/article_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;

class FeedListView extends StatefulWidget {
  const FeedListView({
    super.key,
    required this.feeds,
    required this.articles,
    required this.count,
    required this.theme,
  });

  final List<FeedEntry> feeds;
  final List<Article> articles;
  final int count;
  final AppTheme theme;

  @override
  State<FeedListView> createState() => _FeedListViewState();
}

class _FeedListViewState extends State<FeedListView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // clipBehavior: Clip.antiAlias,
      // decoration: BoxDecoration(
      //   color: _color,
      //   borderRadius: const BorderRadius.all(
      //     Radius.circular(10),
      //   ),
      // ),
      // padding: EdgeInsets.only(
      //   left: MediaQuery.sizeOf(context).width / 10,
      // ),
      child: ListView.builder(
        shrinkWrap: true,
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
              theme: widget.theme);
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
    required this.theme,
  });

  final FeedEntry feed;
  final List<Article> articles;
  final int count;
  final AppTheme theme;

  @override
  State<FeedListItem> createState() => _FeedListItemState();
}

class _FeedListItemState extends State<FeedListItem> {
  Color _color = Colors.transparent;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {showFeed(context, widget.feed, widget.theme)},
      onTapDown: (tapDetails) => {
        setState(() {
          _color = Color(widget.theme.primaryColor);
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
                showFeed(context, widget.feed, widget.theme),
              },
              backgroundColor: Color(widget.theme.primaryColor),
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
                child: _FeedDetails(feed: widget.feed, theme: widget.theme),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedDetails extends StatelessWidget {
  const _FeedDetails({required this.feed, required this.theme});

  final FeedEntry feed;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
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
              builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  return snapshot.data!; // The built widget
                } else {
                  return const Text('Something went wrong');
                }
              },
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
          ),
          const Padding(padding: EdgeInsets.only(left: 10)),
          Flexible(
            flex: 10,
            fit: FlexFit.tight,
            child: Text(
              feed.feed.title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14.0,
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

void showFeed(BuildContext context, FeedEntry feed, AppTheme theme) {
  HapticFeedback.mediumImpact();
  Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute<void>(
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            leading: Container(),
            flexibleSpace: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    CupertinoButton(
                      child: const Row(
                        children: [
                          Icon(
                            CupertinoIcons.back,
                          ),
                          Text('Back')
                        ],
                      ),
                      onPressed: () => {
                        Navigator.of(context, rootNavigator: true).pop(),
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: ArticleList(
            refreshParent: () => {},
            articles: feed.articles,
            theme: theme,
          ),
        );
      },
    ),
  );
}
