import 'package:feederr/models/smart_categoryentry.dart';
import 'package:feederr/pages/article_list.dart';
import 'package:feederr/widgets/feed.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SmartCategoryListItem extends StatefulWidget {
  const SmartCategoryListItem({
    super.key,
    required this.category,
  });

  final SmartCategoryEntry category;

  @override
  State<SmartCategoryListItem> createState() => _SmartCategoryListItemState();
}

class _SmartCategoryListItemState extends State<SmartCategoryListItem>
    with SingleTickerProviderStateMixin {
  Color _color = Colors.transparent;
  final ExpansionTileController controller = ExpansionTileController();
  late final slidableController = SlidableController(this);
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
        HapticFeedback.mediumImpact(),
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
                  articles: widget.category.articles,
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
        child: Slidable(
          // Specify a key if the Slidable is dismissible.
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (_) => {
                  HapticFeedback.mediumImpact(),
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) {
                        return Scaffold(
                          appBar: AppBar(
                            leading: Container(),
                            flexibleSpace: SafeArea(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
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
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop(),
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          body: ArticleList(
                            refreshParent: () => {},
                            articles: widget.category.articles,
                          ),
                        );
                      },
                    ),
                  ),
                },
                backgroundColor: const Color.fromRGBO(76, 2, 232, 1),
                foregroundColor: Colors.white,
                icon: CupertinoIcons.news,
                // label: 'Delete',
              ),
            ],
          ),

          // The child of the Slidable is what the user sees when the
          // component is not dragged.
          child: ExpansionTile(
            expansionAnimationStyle: AnimationStyle(
              curve: Curves.easeOutSine,
              duration: Durations.medium1,
            ),
            dense: true,
            enabled: false,
            shape: Border.all(color: Colors.transparent),
            tilePadding: const EdgeInsets.all(0),
            maintainState: true,
            trailing: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 6, 0, 34),
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                border: Border.all(
                  width: 1,
                  color: const Color.fromARGB(255, 30, 30, 30),
                ),
              ),
              child: GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 4, 4, 4),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      // width: 0,
                      // height: 0,
                      children: [
                        Text(
                          widget.category.articles.length.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: 14.0,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        // const Spacer(),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, anim) =>
                              RotationTransition(
                            turns: child.key == const ValueKey('icon1')
                                ? Tween<double>(begin: 1, end: 0.75)
                                    .animate(anim)
                                : Tween<double>(begin: 0.75, end: 1)
                                    .animate(anim),
                            child: FadeTransition(opacity: anim, child: child),
                          ),
                          child: _currIndex == 0
                              ? const Icon(CupertinoIcons.chevron_down,
                                  size: 20,
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                  key: ValueKey('icon1'))
                              : const Icon(
                                  size: 20,
                                  CupertinoIcons.chevron_down,
                                  color: Color.fromRGBO(76, 2, 232, 1),
                                  key: ValueKey('icon2'),
                                ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () => {
                        HapticFeedback.mediumImpact(),
                        setState(
                          () {
                            _currIndex = _currIndex == 0 ? 1 : 0;
                            if (controller.isExpanded) {
                              controller.collapse();
                            } else {
                              controller.expand();
                            }
                          },
                        ),
                      }),
            ),
            controller: controller,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.folder,
                      color: Color.fromRGBO(76, 2, 232, 1),
                    ),
                    const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10)),
                    Flexible(
                      flex: 10,
                      fit: FlexFit.tight,
                      child: Text(
                        widget.category.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ],
            ),
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                child: FeedListView(
                  articles: widget.category.articles,
                  feeds: widget.category.feeds,
                  count: widget.category.feeds.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
