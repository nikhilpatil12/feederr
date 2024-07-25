import 'package:feederr/models/article.dart';
import 'package:feederr/models/feed.dart';
import 'package:feederr/models/tag.dart';
import 'package:feederr/models/tagentry.dart';
import 'package:feederr/pages/fav_articles.dart';
import 'package:feederr/utils/utils.dart';
import 'package:feederr/widgets/feed.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class TagListItem extends StatefulWidget {
  const TagListItem({
    super.key,
    required this.tag,
  });

  final TagEntry tag;

  @override
  State<TagListItem> createState() => _TagListItemState();
}

class _TagListItemState extends State<TagListItem>
    with SingleTickerProviderStateMixin {
  Color _color = Colors.transparent;
  final ExpansionTileController controller = ExpansionTileController();
  late AnimationController animationController;
  late Animation<double> animation;
  var _currIndex = 0;
  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..forward();
    animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(animationController);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

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
                body: FavArticleList(
                  refreshParent: () => {},
                  articles: widget.tag.articles,
                ),
                // Text(widget.ta
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
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ExpansionTile(
          dense: true,
          enabled: false,
          shape: Border.all(color: Colors.transparent),
          tilePadding: const EdgeInsets.all(0),
          maintainState: true,
          trailing: SizedBox(
            child: IconButton(
              icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) => RotationTransition(
                        turns: child.key == const ValueKey('icon1')
                            ? Tween<double>(begin: 1, end: 0.75).animate(anim)
                            : Tween<double>(begin: 0.75, end: 1).animate(anim),
                        child: FadeTransition(opacity: anim, child: child),
                      ),
                  child: _currIndex == 0
                      ? const Icon(CupertinoIcons.chevron_left,
                          color: Color.fromRGBO(255, 255, 255, 1),
                          key: ValueKey('icon1'))
                      : const Icon(
                          CupertinoIcons.chevron_up,
                          color: Color.fromRGBO(76, 2, 232, 1),
                          key: ValueKey('icon2'),
                        )),
              onPressed: () {
                setState(
                  () {
                    _currIndex = _currIndex == 0 ? 1 : 0;
                    if (controller.isExpanded) {
                      controller.collapse();
                    } else {
                      controller.expand();
                    }
                  },
                );
              },
            ),
          ),
          controller: controller,
          title: _TagDetails(
            tag: widget.tag.tag,
          ),
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              child: FeedListView(
                articles: widget.tag.articles,
                feeds: widget.tag.feeds,
              ),
            ),
          ],
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
      padding: const EdgeInsets.only(left: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              const Icon(
                CupertinoIcons.folder,
                color: Color.fromRGBO(76, 2, 232, 1),
              ),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 10)),
              Text(
                getTag(tag.id),
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
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
