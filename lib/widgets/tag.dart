import 'package:expandable/expandable.dart';
import 'package:feederr/models/article.dart';
import 'package:feederr/models/feed.dart';
import 'package:feederr/models/tag.dart';
import 'package:feederr/utils/utils.dart';
import 'package:feederr/widgets/feed.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TagListItem extends StatefulWidget {
  const TagListItem({
    super.key,
    required this.tag,
    required this.articles,
    required this.feeds,
  });

  final Tag tag;
  final List<Article> articles;
  final List<Feed> feeds;

  @override
  State<TagListItem> createState() => _TagListItemState();
}

void setActiveColor() {}

class _TagListItemState extends State<TagListItem> {
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
                body: Container(
                  child: Text(widget.tag.id),
                ),
              );
            },
          ),
        ),
      },
      onTapDown: (tapDetails) => {
        setState(() {
          _color = const Color.fromRGBO(75, 2, 232, 0.186);
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
        child: ExpandablePanel(
          theme: const ExpandableThemeData(
            expandIcon: CupertinoIcons.chevron_right_circle,
            iconColor: Colors.white,
            collapseIcon: CupertinoIcons.chevron_down_circle,
          ),
          header: Row(
            children: [
              Expanded(
                child: _TagDetails(
                  tag: widget.tag,
                ),
              ),
            ],
          ),
          collapsed: const SizedBox(
            width: 0,
            height: 0,
          ),
          // expanded: Text(
          //   "sdasbsdbasjhdbashdbhjasbdsajhbdjshabdhjasbdjhbashjbdjhasb",
          // ),
          expanded: FeedListView(
            articles: widget.articles,
            feeds: widget.feeds,
          ),
          // tapHeaderToExpand: true,
          // hasIcon: true,
        ),
      ),
    );
  }
}

class _TagDetails extends StatelessWidget {
  const _TagDetails({required this.tag});

  final Tag tag;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              const Icon(CupertinoIcons.folder),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 10)),
              Text(
                getTag(tag.id),
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
