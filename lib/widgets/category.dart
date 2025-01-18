import 'dart:ui';

import 'package:feederr/models/app_theme.dart';
import 'package:feederr/models/font_settings.dart';
import 'package:feederr/models/categoryentry.dart';
import 'package:feederr/pages/article_list.dart';
import 'package:feederr/utils/apiservice.dart';
import 'package:feederr/utils/dbhelper.dart';
import 'package:feederr/utils/themeprovider.dart';
import 'package:feederr/widgets/feed.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class CategoryListItem extends StatefulWidget {
  const CategoryListItem({
    super.key,
    required this.category,
    required this.api,
    required this.databaseService,
  });

  final CategoryEntry category;
  final APIService api;
  final DatabaseService databaseService;

  @override
  State<CategoryListItem> createState() => _CategoryListItemState();
}

class _CategoryListItemState extends State<CategoryListItem>
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
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return GestureDetector(
        onTap: () => {
          HapticFeedback.mediumImpact(),
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) {
                return Scaffold(
                  // extendBodyBehindAppBar: true,
                  appBar: AppBar(
                    backgroundColor:
                        Color(themeProvider.theme.surfaceColor).withAlpha(56),
                    elevation: 0,
                    title: Text(
                      widget.category.category.name,
                      style: TextStyle(
                        color: Color(themeProvider.theme.textColor),
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
                    articles: widget.category.articles,
                    api: widget.api,
                    databaseService: widget.databaseService,
                  ),
                );
              },
            ),
          ),
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
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: _color,
            // borderRadius: const BorderRadius.all(
            //   Radius.circular(10),
            // ),
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
                            // extendBodyBehindAppBar: true,
                            appBar: AppBar(
                              backgroundColor:
                                  Color(themeProvider.theme.surfaceColor)
                                      .withAlpha(56),
                              elevation: 0,
                              title: Text(
                                widget.category.category.name,
                                style: TextStyle(
                                  color: Color(themeProvider.theme.textColor),
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
                              articles: widget.category.articles,
                              api: widget.api,
                              databaseService: widget.databaseService,
                            ),
                          );
                        },
                      ),
                    ),
                  },
                  backgroundColor: Color(themeProvider.theme.primaryColor),
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
              trailing: Padding(
                padding: const EdgeInsets.only(left: 10, bottom: 10, top: 10),
                child: GestureDetector(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(themeProvider.theme.surfaceColor),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        border: Border.all(
                          width: 1,
                          color: Color(themeProvider.theme.textColor),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 4, 4, 4),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          // width: 0,
                          // height: 0,
                          children: [
                            Text(
                              widget.category.count.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Color(themeProvider.theme.primaryColor),
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
                                child:
                                    FadeTransition(opacity: anim, child: child),
                              ),
                              child: _currIndex == 0
                                  ? Icon(CupertinoIcons.chevron_down,
                                      size: 20,
                                      color: Color(
                                          themeProvider.theme.primaryColor),
                                      key: const ValueKey('icon1'))
                                  : Icon(
                                      size: 20,
                                      CupertinoIcons.chevron_down,
                                      color: Color(
                                          themeProvider.theme.primaryColor),
                                      key: const ValueKey('icon2'),
                                    ),
                            ),
                          ],
                        ),
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
                      Icon(
                        CupertinoIcons.folder,
                        color: Color(themeProvider.theme.primaryColor),
                      ),
                      const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10)),
                      Flexible(
                        flex: 10,
                        fit: FlexFit.tight,
                        child: Text(
                          widget.category.category.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(themeProvider.theme.textColor),
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
                    feeds: widget.category.feedEntry,
                    count: widget.category.count,
                    api: widget.api,
                    databaseService: widget.databaseService,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
