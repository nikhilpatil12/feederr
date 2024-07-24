import 'package:feederr/models/article.dart';
import 'package:feederr/models/feed.dart';
import 'package:feederr/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FeedListView extends StatefulWidget {
  const FeedListView({
    super.key,
    required this.feeds,
    required this.articles,
  });

  final List<Feed> feeds;
  final List<Article> articles;

  @override
  State<FeedListView> createState() => _FeedListViewState();
}

class _FeedListViewState extends State<FeedListView> {
  Color _color = Colors.transparent;
  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _color,
        borderRadius: const BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      padding: const EdgeInsets.all(10),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: widget.feeds.length,
        itemBuilder: (context, index) {
          final feed = widget.feeds[index];
          final articles = widget.articles;
          return FeedListItem(
            feed: feed,
            articles: articles,
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
  });

  final Feed feed;
  final List<Article> articles;

  @override
  State<FeedListItem> createState() => _FeedListItemState();
}

class _FeedListItemState extends State<FeedListItem> {
  Color _color = Colors.transparent;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {
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
                //TODO: Change
                body: Text(widget.feed.title),
              );
            },
          ),
        ),
      },
      onTapDown: (tapDetails) => {
        setState(() {
          _color = Color.fromRGBO(75, 2, 232, 0.186);
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
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: _color,
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: _FeedDetails(
                feed: widget.feed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedDetails extends StatelessWidget {
  const _FeedDetails({required this.feed});

  final Feed feed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Image(
            image: NetworkImage(feed.iconUrl),
            width: 20,
            height: 20,
          ),
          Padding(padding: EdgeInsets.all(10)),
          Text(
            feed.title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }
}
