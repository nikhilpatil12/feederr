import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:feederr/models/app_theme.dart';
import 'package:feederr/models/article.dart';
import 'package:feederr/models/server.dart';
import 'package:feederr/utils/apiservice.dart';
import 'package:feederr/utils/dbhelper.dart';
import 'package:feederr/utils/themeprovider.dart';
import 'package:feederr/utils/utils.dart';
import 'package:feederr/widgets/actionbar.dart';
import 'package:feederr/widgets/webview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

enum View { webview, articleview }

Map<View, Icon> views = <View, Icon>{
  View.webview: const Icon(CupertinoIcons.globe),
  View.articleview: const Icon(Icons.article),
};

class ArticleView extends StatefulWidget {
  final List<Article> articles;
  final int articleIndex;
  final APIService api;
  final DatabaseService databaseService;

  const ArticleView({
    super.key,
    required this.articles,
    required this.articleIndex,
    required this.api,
    required this.databaseService,
  });

  @override
  State<ArticleView> createState() => _ArticleViewState();
}

class _ArticleViewState extends State<ArticleView> {
  bool isStyleMenuVisible = false;

  bool isPopupImageVisible = false;
  String popupImageSrc = "";
  String popupImageCaption = "";
  View selectedView = View.articleview;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.sizeOf(context).width;
    var screenHeight = MediaQuery.sizeOf(context).height;
    final PageController pageController =
        PageController(initialPage: widget.articleIndex);
    Article article = widget.articles[widget.articleIndex];
    _markArticleAsRead(article.id2 ?? 0, article.serverId);
    article.isRead = true;
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor:
              Color(themeProvider.theme.surfaceColor).withAlpha(56),
          elevation: 0,
          centerTitle: true,
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 36,
                sigmaY: 36,
              ),
              child: Container(
                color: Colors.transparent,
                child: SafeArea(
                  child: Center(
                    child: CupertinoSlidingSegmentedControl<View>(
                      // padding: EdgeInsets.all(8),
                      // unselectedColor:
                      //     Color(themeProvider.theme.surfaceColor),
                      // selectedColor: Color(themeProvider.theme.primaryColor),
                      backgroundColor: Color(themeProvider.theme.textColor)
                          .withValues(alpha: 0.5),
                      thumbColor: Color(themeProvider.theme.primaryColor),
                      groupValue: selectedView,
                      children: <View, Widget>{
                        View.webview: Icon(CupertinoIcons.globe),
                        View.articleview: Icon(Icons.article),
                      },
                      onValueChanged: (View? value) {
                        if (value != null) {
                          setState(() {
                            selectedView = value;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: PageView.builder(
            onPageChanged: ((int index) => {
                  article = widget.articles[index],
                  _markArticleAsRead(article.id2 ?? 0, article.serverId),
                }),
            itemCount: widget.articles.length,
            controller: pageController,
            itemBuilder: (BuildContext ctxt, int index) {
              article = widget.articles[index];
              article.isRead = true;
              final document = html_parser.parse(article.summaryContent);
              final textSpan =
                  _parseHtmlToTextSpan(document.body!, themeProvider.theme);
              final ScrollController scrollController = ScrollController();
              return SafeArea(
                bottom: false,
                child: Stack(
                  children: [
                    selectedView == View.articleview
                        ? RawScrollbar(
                            interactive: true,
                            thumbColor: Color(themeProvider.theme.primaryColor),
                            thickness: 4,
                            radius: const Radius.circular(1),
                            // thumbVisibility: true,
                            controller: scrollController,
                            child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context)
                                  .copyWith(scrollbars: false),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                color: Color(themeProvider.theme.surfaceColor),
                                child: SingleChildScrollView(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: themeProvider
                                          .fontSettings.articleContentWidth),
                                  controller: scrollController,
                                  child: Column(
                                    children: [
                                      // Padding(
                                      //   padding: EdgeInsets.all(60),
                                      // ),
                                      Container(
                                        width: double.infinity,
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: SelectableText(
                                          article.title,
                                          textAlign: themeProvider
                                              .fontSettings.titleAlignment,
                                          style: TextStyle(
                                            fontSize: themeProvider
                                                .fontSettings.titleFontSize,
                                            fontFamily: themeProvider
                                                .fontSettings.articleFont,
                                            fontVariations: const [
                                              FontVariation('wght', 600)
                                            ],
                                            color: Color(
                                                themeProvider.theme.textColor),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: RichText(
                                          textAlign: TextAlign.left,
                                          text: TextSpan(
                                            text: article.originTitle,
                                            style: TextStyle(
                                              fontSize: themeProvider
                                                  .fontSettings.articleFontSize,
                                              fontFamily: themeProvider
                                                  .fontSettings.articleFont,
                                              fontVariations: const [
                                                FontVariation('wght', 600)
                                              ],
                                              color: Color(themeProvider
                                                  .theme.primaryColor),
                                            ),
                                            children: <TextSpan>[
                                              const TextSpan(
                                                text: '・',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              TextSpan(
                                                text: article.author,
                                                style: TextStyle(
                                                  fontSize: themeProvider
                                                      .fontSettings
                                                      .articleFontSize,
                                                  fontFamily: themeProvider
                                                      .fontSettings.articleFont,
                                                  fontVariations: const [
                                                    FontVariation('wght', 300)
                                                  ],
                                                  color: Color(themeProvider
                                                      .theme.textColor),
                                                ),
                                              ),
                                              const TextSpan(
                                                text: '・',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              TextSpan(
                                                text:
                                                    timeAgo(article.published),
                                                style: TextStyle(
                                                  fontSize: themeProvider
                                                      .fontSettings
                                                      .articleFontSize,
                                                  fontFamily: themeProvider
                                                      .fontSettings.articleFont,
                                                  fontVariations: const [
                                                    FontVariation('wght', 300)
                                                  ],
                                                  color: Color(themeProvider
                                                      .theme.textColor),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SelectableText.rich(
                                        textSpan,
                                        textAlign: themeProvider
                                            .fontSettings.articleAlignment,
                                        style: TextStyle(
                                            height: themeProvider.fontSettings
                                                .articleLineSpacing, //line spacing
                                            letterSpacing: 0, //letter spacing
                                            fontSize: themeProvider.fontSettings.articleFontSize,
                                            fontFamily: themeProvider.fontSettings.articleFont,
                                            color: Color(themeProvider.theme.textColor),
                                            fontVariations: const [
                                              FontVariation('wght', 400)
                                            ]),
                                      ),
                                      const SizedBox(height: 80),
                                      // HtmlWidget(
                                      //   widget.article.summaryContent,
                                      //   enableCaching: true,
                                      //   customWidgetBuilder: (element) {
                                      //     if (element.localName == 'p') {
                                      //       return SelectableText.rich(
                                      //         _parseHtmlToTextSpan(element),
                                      //         style: TextStyle(fontSize: 16.0),
                                      //       );
                                      //     }
                                      //     if (element.localName == 'img') {
                                      //       final src = element.attributes['src'];
                                      //       if (src != null) {
                                      //         return Image.network(src);
                                      //       }
                                      //     }
                                      //     return null;
                                      //   },
                                      //   renderMode: RenderMode.column,
                                      //   textStyle: TextStyle(fontSize: 14),
                                      //   customStylesBuilder: (element) {
                                      //     if (element.attributes.containsKey("href")) {
                                      //       return {
                                      //         'color': "0xFF4C02E8",
                                      //         'font-weight': "bold",
                                      //         "text-decoration-line": "none"
                                      //       };
                                      //     }

                                      //     return null;
                                      //   },
                                      // ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        : CustomWebView(
                            theme: themeProvider.theme,
                            url: article.canonical,
                          ),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.decelerate,
                      bottom: isPopupImageVisible ? 0 : -screenHeight,
                      left: 0,
                      child: Container(
                        width: screenWidth,
                        height: screenHeight,
                        color: const Color.fromARGB(118, 0, 0, 0),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                              sigmaX: isPopupImageVisible ? 5 : 0,
                              sigmaY: isPopupImageVisible ? 5 : 0),
                          child: SafeArea(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                InteractiveViewer(
                                  trackpadScrollCausesScale: true,
                                  clipBehavior: Clip.none,
                                  minScale: 0.1,
                                  maxScale: 4,
                                  child: _showImage(
                                      popupImageSrc, popupImageCaption),
                                ),
                                Positioned(
                                  bottom: 40,
                                  child: Container(
                                    color: const Color.fromARGB(148, 0, 0, 0),
                                    width: screenWidth,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.all(20),
                                    child: Text(
                                      popupImageCaption,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontFamily: themeProvider
                                              .fontSettings.articleFont,
                                          fontVariations: const [
                                            FontVariation('wght', 500)
                                          ]),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 100,
                                  right: 0,
                                  child: Container(
                                    alignment: Alignment.topRight,
                                    padding: const EdgeInsets.all(20),
                                    child: CupertinoButton(
                                      borderRadius: BorderRadius.circular(100),
                                      color:
                                          const Color.fromARGB(104, 62, 62, 62),
                                      padding: const EdgeInsets.all(10),
                                      onPressed: () {
                                        setState(() {
                                          isPopupImageVisible = false;
                                        });
                                      },
                                      child: const Icon(
                                        Icons.close,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // ),
                    ),
                    ActionBar(
                      article: article,
                      databaseService: widget.databaseService,
                      api: widget.api,
                      themeProvider: themeProvider,
                      pageController: pageController,
                    ),
                  ],
                ),
              );
            }),
      );
    });
    // pageController.animateToPage(widget.articleIndex,
    //     curve: Curves.bounceIn, duration: Durations.long2);
    // return pv;
  }

  Future<void> _markArticleAsRead(int articleId, int serverId) async {
    // setState(() {});
    try {
      //Getting Server list
      await widget.databaseService.deleteUnreadId(articleId);
      Server server = await widget.databaseService.server(serverId);
      await widget.api.markAsRead(server.baseUrl, server.auth, articleId);
    } on Exception {
      // Handle error
    } finally {
      // setState(() {});
    }
  }

  TextSpan _parseHtmlToTextSpan(dom.Element element, AppTheme theme) {
    List<InlineSpan> children = [];

    for (var node in element.nodes) {
      if (node is dom.Text) {
        children.add(TextSpan(text: node.text));
      } else if (node is dom.Element) {
        switch (node.localName) {
          case 'h1':
          case 'h2':
          case 'h3':
          case 'h4':
          case 'h5':
          case 'h6':
            children.add(TextSpan(
              text: "\n${node.text}\n",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ));
            break;
          case 'b':
            children.add(TextSpan(
              text: node.text,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ));
            break;
          case 'cite':
            children.add(TextSpan(
              text: "${node.text}\n",
              style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                  fontSize: 14),
            ));
            break;
          case 'em':
            children.add(TextSpan(
              text: node.text,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ));
          case 'strong':
            children.add(TextSpan(
              text: node.text,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ));
            break;
          case 'i':
            children.add(TextSpan(
              text: node.text,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ));
            break;
          case 'u':
            children.add(TextSpan(
              text: node.text,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ));
            break;
          case 'a':
            final url = node.attributes['href'];
            children.add(TextSpan(
              text: node.text,
              style: TextStyle(
                  color: Color(theme.primaryColor),
                  decoration: TextDecoration.none),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  if (url != null) {
                    launchUrl(Uri.parse(url));
                  }
                },
            ));
            for (var element in node.children) {
              if (element.localName == "span" && element.text != node.text) {
                children.addAll(_parseHtmlToTextSpan(node, theme).children!);
              }
            }
          // _parseHtmlToTextSpan(node).children!.any((x)=>x.=="img");

          case 'img':
            children.add(const TextSpan(text: '\n'));
            final src = node.attributes['src'];
            final alt = node.attributes['alt'];
            if (src != null) {
              children.add(
                WidgetSpan(
                  child: _showImage(src, alt ?? ""),
                ),
              );
            }
            if (children.isEmpty ||
                children.last is TextSpan &&
                    !(children.last as TextSpan).text!.endsWith('\n')) {
              children.add(const TextSpan(text: '\n'));
            }
            break;
          case 'br':
            if (children.isEmpty ||
                children.last is TextSpan &&
                    !(children.last as TextSpan).text!.endsWith('\n')) {
              children.add(const TextSpan(text: '\n'));
            }
            break;
          case 'p':
            if (children.isEmpty ||
                children.last is TextSpan &&
                    !(children.last as TextSpan).text!.endsWith('\n')) {
              children.add(const TextSpan(text: '\n'));
            }
            children.addAll(_parseHtmlToTextSpan(node, theme).children!);
            if (children.isEmpty ||
                children.last is TextSpan &&
                    !(children.last as TextSpan).text!.endsWith('\n')) {
              children.add(const TextSpan(text: '\n'));
            }
            break;
          case 'span':
            children.addAll(_parseHtmlToTextSpan(node, theme).children!);
            if (children.isEmpty ||
                children.last is TextSpan &&
                    !(children.last as TextSpan).text!.endsWith('\n')) {
              children.add(const TextSpan(text: '\n'));
            }
            break;
          case 'div':
            children.addAll(_parseHtmlToTextSpan(node, theme).children!);
            break;
          case 'figure':
            children.addAll(_parseHtmlToTextSpan(node, theme).children!);
            break;
          case 'figcaption':
            children.add(
              TextSpan(
                text: "${node.text}\n",
                style: const TextStyle(
                    fontStyle: FontStyle.normal, fontSize: 12.0),
              ),
            );
          case 'li':
            children.add(TextSpan(
              text: "\n◦ ${node.text}",
              style: const TextStyle(fontWeight: FontWeight.normal),
            ));
          default:
            children.addAll(_parseHtmlToTextSpan(node, theme).children!);
          // if (src.startsWith('data:image/')) {
          //   // Handle Base64 image
          //   final base64Data = src.split(',').last;
          //   final imageBytes = base64Decode(base64Data);
          //   children.add(
          //     WidgetSpan(
          //       child: GestureDetector(
          //         child: Image.memory(Uint8List.fromList(imageBytes)),
          //       ),
          //     ),
          //   );
          // } else {
          //   // Handle network image
          //   children.add(
          //     WidgetSpan(
          //       child: GestureDetector(
          //         onTap: () async {
          //         },
          //         onLongPress: () async {
          //           _showMenu(
          //             context,
          //           );
          //           // await Clipboard.setData(ClipboardData(text: src));
          //           // ScaffoldMessenger.of(context).showSnackBar(
          //           //     SnackBar(content: Text('Image URL copied')));
          //         },
          //         child: Image.network(src),
          //       ),
          //     ),
          //   );
          // }
          //   }
          // } else {
          //   children.add(_parseHtmlToTextSpan(node));
          // }
        }
      }
    }
    return TextSpan(children: children);
  }

  Widget _showImage(String src, String alt) {
    if (src.startsWith('data:image/')) {
      // Handle Base64 image
      // final base64Data = src.split(',').last;
      // final imageBytes = base64Decode(base64Data);
      return const SizedBox();
      // return GestureDetector(
      //   onLongPress: () async {
      //     //TODO
      //     // _showBlurMenu(context);
      //   },
      //   child: Image.memory(Uint8List.fromList(imageBytes)),
      // );
    } else {
      return GestureDetector(
        onLongPress: () async {
          //TODO:
          // _showBlurMenu(context);
        },
        child: CachedNetworkImage(
          imageUrl: src,
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              const CupertinoActivityIndicator(),
          errorWidget: (context, url, error) => const SizedBox(
            width: 10,
            height: 10,
          ),
        ),
        onTap: () {
          setState(() {
            isPopupImageVisible = true;
            popupImageSrc = src;
            popupImageCaption = alt;
          });
        },
        // child: Image.network(
        //   src,
        //   errorBuilder: (context, exception, stackTrace) {
        //     return const SizedBox(height: 40);
        //   },
        // ),
      );
    }
  }

  static Animation<Decoration> _boxDecorationAnimation(
      Animation<double> animation) {
    return _tween.animate(
      CurvedAnimation(
        parent: animation,
        curve: Interval(
          0.0,
          CupertinoContextMenu.animationOpensAt,
        ),
      ),
    );
  }
}

final DecorationTween _tween = DecorationTween(
  begin: BoxDecoration(
    color: CupertinoColors.systemYellow,
    boxShadow: const <BoxShadow>[],
    borderRadius: BorderRadius.circular(20.0),
  ),
  end: BoxDecoration(
    color: CupertinoColors.systemYellow,
    boxShadow: CupertinoContextMenu.kEndBoxShadow,
    borderRadius: BorderRadius.circular(20.0),
  ),
);
