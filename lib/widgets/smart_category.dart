import 'package:blazefeeds/models/app_theme.dart';
import 'package:blazefeeds/models/categories/smart_categoryentry.dart';
import 'package:blazefeeds/pages/article_list.dart';
import 'package:blazefeeds/utils/apiservice.dart';
import 'package:blazefeeds/utils/dbhelper.dart';
import 'package:blazefeeds/providers/theme_provider.dart';
import 'package:blazefeeds/widgets/feed.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class SmartCategoryListItem extends StatefulWidget {
  const SmartCategoryListItem({
    super.key,
    required this.category,
    required this.api,
    required this.databaseService,
    required this.refreshAllCallback,
  });
  final SmartCategoryEntry category;
  final APIService api;
  final DatabaseService databaseService;
  final VoidCallback refreshAllCallback;

  @override
  State<SmartCategoryListItem> createState() => _SmartCategoryListItemState();
}

class _SmartCategoryListItemState extends State<SmartCategoryListItem>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<Color> _colorNotifier = ValueNotifier<Color>(Colors.transparent);
  final ExpansionTileController controller = ExpansionTileController();
  late final slidableController = SlidableController(this);
  late AnimationController animationController;
  late Animation<double> animation;
  bool _currIndex = true;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..forward();
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(animationController);
  }

  // @override
  // void dispose() {
  //   animationController.dispose();
  //   // super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return GestureDetector(
      onTap: () => {
        HapticFeedback.mediumImpact(),
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return ArticleList(
                refreshParent: widget.refreshAllCallback,
                articles: widget.category.articles,
                title: widget.category.title,
                // Text(widget.ta
              );
            },
          ),
        ),
      },
      onTapDown: (tapDetails) => {
        // setState(() {
        _colorNotifier.value = theme.primaryColor.withAlpha(90),
        // })
      },
      onTapUp: (tapDetails) => {
        Future.delayed(const Duration(milliseconds: 200), () {
          // setState(() {
          _colorNotifier.value = const Color.fromARGB(0, 0, 0, 0);
          // code to be executed after 2 seconds
          // });
        })
      },
      onTapCancel: () => {
        Future.delayed(const Duration(milliseconds: 200), () {
          // setState(() {
          _colorNotifier.value = const Color.fromARGB(0, 0, 0, 0);
          // code to be executed after 2 seconds
          // });
        })
      },
      child: ValueListenableBuilder<Color>(
        valueListenable: _colorNotifier,
        builder: (context, color, child) {
          return Container(
            // clipBehavior: Clip.antiAlias,
            // decoration: BoxDecoration(
            //   color: color,
            //   border: Border(
            //     top: BorderSide(color: theme.dividerColor, width: 0.1),
            //   ),
            // ),
            child: child,
          );
        },
        child: Slidable(
          // Specify a key if the Slidable is dismissible.
          endActionPane: ActionPane(
            openThreshold: 0.2,
            extentRatio: 0.3,
            motion: const ScrollMotion(),
            children: [
              Theme(
                data: Theme.of(context).copyWith(
                  outlinedButtonTheme: OutlinedButtonThemeData(
                    style: ButtonStyle(
                      iconColor: WidgetStatePropertyAll(theme.colorScheme.surface),
                    ),
                  ),
                ),
                child: SlidableAction(
                  onPressed: (_) => {
                    HapticFeedback.mediumImpact(),
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) {
                          return ArticleList(
                            refreshParent: widget.refreshAllCallback,
                            articles: widget.category.articles,
                            title: widget.category.title,
                          );
                        },
                      ),
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

          // The child of the Slidable is what the user sees when the
          // component is not dragged.
          child: ExpansionTile(
            expansionAnimationStyle: AnimationStyle(
              curve: Curves.decelerate,
              duration: Durations.medium1,
            ),
            dense: true,
            enabled: false,
            shape: Border.all(color: Colors.transparent),
            tilePadding: const EdgeInsets.symmetric(horizontal: 20),
            maintainState: true,
            trailing: GestureDetector(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  // width: 0,
                  // height: 0,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                        // border: Border.all(
                        //   width: 1,
                        //   color: Color(theme.textColor),
                        // ),
                      ),
                      child: Text(
                        widget.category.articles.length.toString(),
                        style: TextStyle(
                          // fontWeight: FontWeight.w500,
                          color: theme.colorScheme.surface,
                          fontSize: 14.0,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    // const Spacer(),
                    Container(
                      padding: EdgeInsets.only(left: 10),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, anim) => RotationTransition(
                          turns: child.key == const ValueKey('icon1')
                              ? Tween<double>(begin: 1, end: 0.75).animate(anim)
                              : Tween<double>(begin: 0.75, end: 1).animate(anim),
                          child: FadeTransition(opacity: anim, child: child),
                        ),
                        child: _currIndex
                            ? Icon(CupertinoIcons.chevron_down,
                                size: 20,
                                color: theme.colorScheme.primary,
                                key: const ValueKey('icon1'))
                            : Icon(
                                size: 20,
                                CupertinoIcons.chevron_down,
                                color: theme.colorScheme.primary,
                                key: const ValueKey('icon2'),
                              ),
                      ),
                    ),
                  ],
                ),
                onTap: () => {
                      HapticFeedback.mediumImpact(),
                      setState(
                        () {
                          _currIndex = !_currIndex;
                          if (controller.isExpanded) {
                            controller.collapse();
                          } else {
                            controller.expand();
                          }
                        },
                      ),
                    }),
            controller: controller,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.folder,
                      color: theme.colorScheme.primary,
                    ),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2)),
                    Flexible(
                      flex: 10,
                      fit: FlexFit.tight,
                      child: Text(
                        widget.category.title,
                        style: TextStyle(
                          // fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface,
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
                  api: widget.api,
                  databaseService: widget.databaseService,
                  refreshAllCallback: widget.refreshAllCallback,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
