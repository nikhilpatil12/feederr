import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:feederr/models/app_theme.dart';
import 'package:feederr/models/article.dart';
import 'package:feederr/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:share_plus/share_plus.dart';

class ArticleView extends StatefulWidget {
  final Article article;
  final AppTheme theme;
  const ArticleView({super.key, required this.article, required this.theme});

  @override
  State<ArticleView> createState() => _ArticleViewState();
}

class _ArticleViewState extends State<ArticleView> {
  final ScrollController _scrollController = ScrollController();

  bool isStyleMenuVisible = false;

  double articleTextSize = 16.0;
  double titleTextSize = 28.0;
  TextAlign articleTextAlignment = TextAlign.left;
  TextAlign titleTextAlignment = TextAlign.left;
  double lineSpacing = 1.5;
  double contentWidth = 5;
  List<String> fonts = [
    "Cabinet Grotesk",
    "Chillax",
    "Comico",
    "Clash Grotesk",
    "General Sans",
    "New Title",
    "Supreme"
  ];
  String fontFamily = "General Sans";

  bool isPopupImageVisible = false;
  String popupImageSrc = "";
  String popupImageCaption = "";
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final document = html_parser.parse(widget.article.summaryContent);
    final textSpan = _parseHtmlToTextSpan(document.body!, widget.theme);

    var screenWidth = MediaQuery.sizeOf(context).width;
    var screenHeight = MediaQuery.sizeOf(context).height;
    return Stack(
      children: [
        Scrollbar(
          thumbVisibility: true,
          controller: _scrollController,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            color: Color(widget.theme.surfaceColor),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: contentWidth),
              controller: _scrollController,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SelectableText(
                      // text: TextSpan(
                      // text: widget.article.title,
                      widget.article.title,
                      textAlign: titleTextAlignment,

                      style: TextStyle(
                        fontSize: titleTextSize,
                        fontFamily: fontFamily,
                        fontVariations: const [FontVariation('wght', 600)],
                      ),
                      // style: TextStyle(
                      //     fontSize: titleTextSize, fontWeight: FontWeight.w600),
                      // ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(bottom: 10),
                    child: RichText(
                      textAlign: TextAlign.left,
                      text: TextSpan(
                        text: widget.article.originTitle,
                        style: TextStyle(
                          fontSize: articleTextSize,
                          fontFamily: fontFamily,
                          fontVariations: const [FontVariation('wght', 600)],
                          color: Color(widget.theme.primaryColor),
                        ),
                        children: <TextSpan>[
                          const TextSpan(
                            text: '・',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: widget.article.author,
                            style: TextStyle(
                              fontSize: articleTextSize,
                              fontFamily: fontFamily,
                              fontVariations: const [
                                FontVariation('wght', 300)
                              ],
                              color: Color(widget.theme.textColor),
                            ),
                          ),
                          const TextSpan(
                            text: '・',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: timeAgo(widget.article.published),
                            style: TextStyle(
                              fontSize: articleTextSize,
                              fontFamily: fontFamily,
                              fontVariations: const [
                                FontVariation('wght', 300)
                              ],
                              color: Color(widget.theme.textColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SelectableText.rich(
                    textSpan,
                    textAlign: articleTextAlignment,
                    style: TextStyle(
                        height: lineSpacing, //line spacing
                        letterSpacing: 0, //letter spacing
                        fontSize: articleTextSize,
                        fontFamily: fontFamily,
                        // fontWeight: FontWeight.w100,
                        // fontStyle: FontStyle.normal,
                        fontVariations: const [FontVariation('wght', 400)]),
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
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Color(widget.theme.secondaryColor),
                borderRadius: const BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
              child: Wrap(
                children: [
                  IconButton(
                    highlightColor: Colors.transparent,
                    color: Colors.grey,
                    onPressed: () => {
                      HapticFeedback.lightImpact(),
                      Share.share(widget.article.canonical),
                    },
                    icon: const Icon(CupertinoIcons.share),
                  ),
                  const VerticalDivider(
                    width: 10,
                    thickness: 1,
                    indent: 20,
                    color: Colors.grey,
                  ),
                  IconButton(
                    color: Colors.grey,
                    onPressed: () => {
                      //TODO: Mark as read
                    },
                    icon: const Icon(CupertinoIcons.circle),
                  ),
                  IconButton(
                    color: Colors.grey,
                    onPressed: () => {
                      //TODO: Mark as fav
                    },
                    icon: const Icon(CupertinoIcons.star),
                  ),
                  const VerticalDivider(
                    width: 10,
                    thickness: 1,
                    indent: 20,
                  ),
                  IconButton(
                    color: Colors.grey,
                    onPressed: () => {
                      //TODO: Load Next article
                    },
                    icon: const Icon(CupertinoIcons.chevron_right),
                  ),
                  const VerticalDivider(
                    width: 10,
                    thickness: 1,
                    indent: 20,
                  ),
                  IconButton(
                    highlightColor: Colors.transparent,
                    color: Colors.grey,
                    onPressed: () => {
                      HapticFeedback.lightImpact(),
                      showModalBottomSheet(
                        shape: const BeveledRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        useSafeArea: true,
                        scrollControlDisabledMaxHeightRatio: 0.8,
                        // showDragHandle: true,
                        isScrollControlled: true,
                        useRootNavigator: true,
                        isDismissible: false,
                        context: context,
                        enableDrag: true,
                        elevation: 100,
                        builder: (context) {
                          return DraggableScrollableSheet(
                            expand: false,
                            snap: true,
                            builder: (_, controller) {
                              return SingleChildScrollView(
                                controller: controller,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Container(
                                      color: Color(widget.theme.secondaryColor),
                                      padding: const EdgeInsets.all(10),
                                      child: Center(
                                        child: Text(
                                          'Style',
                                          style: TextStyle(
                                            fontSize: articleTextSize,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    CupertinoFormSection(
                                      header: const Text("COLORS"),
                                      children: [
                                        CupertinoFormRow(
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 40,
                                                height: 40,
                                                color: Colors.amber,
                                              ),
                                              Container(
                                                width: 40,
                                                height: 40,
                                                color: Colors.green,
                                              ),
                                              Container(
                                                width: 40,
                                                height: 40,
                                                color: Colors.red,
                                              ),
                                              Container(
                                                width: 40,
                                                height: 40,
                                                color: const Color.fromARGB(
                                                    255, 7, 255, 90),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    CupertinoFormSection(
                                      header: const Text("TITLE"),
                                      children: [
                                        CupertinoFormRow(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              CupertinoButton(
                                                onPressed: () => {
                                                  setState(() {
                                                    titleTextSize -= 0.5;
                                                  })
                                                },
                                                child: const Icon(
                                                  Icons.text_decrease,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              CupertinoButton(
                                                onPressed: () => {
                                                  setState(() {
                                                    titleTextSize += 0.5;
                                                  })
                                                },
                                                child: const Icon(
                                                  Icons.text_increase,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        CupertinoFormRow(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              CupertinoButton(
                                                onPressed: () => {
                                                  setState(() {
                                                    titleTextAlignment =
                                                        TextAlign.left;
                                                  })
                                                },
                                                child: const Icon(
                                                  CupertinoIcons.text_alignleft,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              CupertinoButton(
                                                onPressed: () => {
                                                  setState(() {
                                                    titleTextAlignment =
                                                        TextAlign.center;
                                                  })
                                                },
                                                child: const Icon(
                                                  CupertinoIcons
                                                      .text_aligncenter,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              CupertinoButton(
                                                onPressed: () => {
                                                  setState(() {
                                                    titleTextAlignment =
                                                        TextAlign.right;
                                                  })
                                                },
                                                child: const Icon(
                                                  CupertinoIcons
                                                      .text_alignright,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    CupertinoFormSection(
                                      header: const Text("ARTICLE"),
                                      children: [
                                        CupertinoFormRow(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              CupertinoButton(
                                                onPressed: () => {
                                                  setState(() {
                                                    articleTextSize -= 0.5;
                                                  })
                                                },
                                                child: const Icon(
                                                  Icons.text_decrease,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              CupertinoButton(
                                                onPressed: () => {
                                                  setState(() {
                                                    articleTextSize += 0.5;
                                                  })
                                                },
                                                child: const Icon(
                                                  Icons.text_increase,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        CupertinoFormRow(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              CupertinoButton(
                                                onPressed: () => {
                                                  setState(() {
                                                    articleTextAlignment =
                                                        TextAlign.left;
                                                  })
                                                },
                                                child: const Icon(
                                                  CupertinoIcons.text_alignleft,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              CupertinoButton(
                                                onPressed: () => {
                                                  setState(() {
                                                    articleTextAlignment =
                                                        TextAlign.center;
                                                  })
                                                },
                                                child: const Icon(
                                                  CupertinoIcons
                                                      .text_aligncenter,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              CupertinoButton(
                                                onPressed: () => {
                                                  setState(() {
                                                    articleTextAlignment =
                                                        TextAlign.right;
                                                  })
                                                },
                                                child: const Icon(
                                                  CupertinoIcons
                                                      .text_alignright,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        CupertinoFormRow(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Row(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.all(10),
                                                    child: Icon(Icons.height),
                                                  ),
                                                  Text("Line Spacing"),
                                                ],
                                              ),
                                              Container(
                                                decoration: const BoxDecoration(
                                                    color: Color.fromARGB(
                                                        28, 253, 253, 253),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10))),
                                                child: Row(
                                                  children: [
                                                    CupertinoButton(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              0),
                                                      child: const Icon(
                                                        Icons.remove,
                                                        color: Colors.white,
                                                      ),
                                                      onPressed: () => {
                                                        setState(
                                                          () {
                                                            if ((lineSpacing -
                                                                    0.2) >
                                                                1.5) {
                                                              lineSpacing -=
                                                                  0.2;
                                                            }
                                                          },
                                                        ),
                                                      },
                                                    ),
                                                    CupertinoButton(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              0),
                                                      child: const Icon(
                                                        Icons.add,
                                                        color: Colors.white,
                                                      ),
                                                      onPressed: () => {
                                                        setState(
                                                          () {
                                                            lineSpacing += 0.2;
                                                          },
                                                        ),
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        CupertinoFormRow(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Row(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.all(10),
                                                    child:
                                                        Icon(Icons.width_wide),
                                                  ),
                                                  Text("Content Width"),
                                                ],
                                              ),
                                              Container(
                                                decoration: const BoxDecoration(
                                                    color: Color.fromARGB(
                                                        28, 253, 253, 253),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10))),
                                                child: Row(
                                                  children: [
                                                    CupertinoButton(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              0),
                                                      child: const Icon(
                                                        Icons.remove,
                                                        color: Colors.white,
                                                      ),
                                                      onPressed: () => {
                                                        setState(
                                                          () {
                                                            contentWidth += 5;
                                                          },
                                                        ),
                                                      },
                                                    ),
                                                    CupertinoButton(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              0),
                                                      child: const Icon(
                                                        Icons.add,
                                                        color: Colors.white,
                                                      ),
                                                      onPressed: () => {
                                                        setState(
                                                          () {
                                                            if (contentWidth >=
                                                                5) {
                                                              contentWidth -= 5;
                                                            }
                                                          },
                                                        ),
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    CupertinoFormSection(
                                      header: const Text("FONTS"),
                                      children: [
                                        ...List.generate(
                                          fonts.length,
                                          (index) => Container(
                                            alignment: Alignment.centerLeft,
                                            padding: const EdgeInsets.all(20),
                                            child: GestureDetector(
                                              onTap: () => setState(
                                                () {
                                                  fontFamily = fonts[index];
                                                },
                                              ),
                                              child: Text(
                                                fonts[index],
                                                style: TextStyle(
                                                  fontFamily: fonts[index],
                                                  fontSize: articleTextSize,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    ElevatedButton(
                                      child: const Text('Close'),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      )
                    },
                    icon: const Icon(CupertinoIcons.textformat),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 400),
          curve: Curves.decelerate,
          bottom: isPopupImageVisible ? 0 : -screenHeight,
          left: 0,
          // child: GestureDetector(
          //   onTap: () => {
          //     setState(() {
          //       isPopupImageVisible = false;
          //     }),
          //   },
          child: Container(
            width: screenWidth,
            height: screenHeight,
            color: Color.fromARGB(118, 0, 0, 0),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                  sigmaX: isPopupImageVisible ? 5 : 0,
                  sigmaY: isPopupImageVisible ? 5 : 0),
              child: SafeArea(
                child: Stack(
                  alignment: Alignment.center,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Center(, child:
                    InteractiveViewer(
                      trackpadScrollCausesScale: true,
                      clipBehavior: Clip.none,
                      minScale: 0.1,
                      maxScale: 4,
                      child: _showImage(popupImageSrc, popupImageCaption),
                    ),
                    // ),
                    Positioned(
                      bottom: 40,
                      child: Container(
                        color: Color.fromARGB(148, 0, 0, 0),
                        width: screenWidth,
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(20),
                        child: Text(
                          popupImageCaption,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: fontFamily,
                              fontVariations: [FontVariation('wght', 500)]),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 100,
                      right: 0,
                      child: Container(
                        alignment: Alignment.topRight,
                        padding: EdgeInsets.all(20),
                        child: CupertinoButton(
                          child: Icon(
                            Icons.close,
                          ),
                          borderRadius: BorderRadius.circular(100),
                          color: Color.fromARGB(104, 62, 62, 62),
                          padding: EdgeInsets.all(10),
                          onPressed: () {
                            setState(() {
                              isPopupImageVisible = false;
                            });
                          },
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
      ],
    );
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
                children
                    .addAll(_parseHtmlToTextSpan(node, widget.theme).children!);
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
            children.add(const TextSpan(text: '\n'));
          case 'br':
            children.add(const TextSpan(text: '\n'));
            break;
          case 'p':
            children.add(const TextSpan(text: '\n'));
            children.addAll(_parseHtmlToTextSpan(node, widget.theme).children!);
            children.add(const TextSpan(text: '\n'));
            break;
          case 'span':
            children.addAll(_parseHtmlToTextSpan(node, widget.theme).children!);
            break;
          case 'div':
            children.addAll(_parseHtmlToTextSpan(node, widget.theme).children!);
            break;
          case 'figure':
            children.addAll(_parseHtmlToTextSpan(node, widget.theme).children!);
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
            children.addAll(_parseHtmlToTextSpan(node, widget.theme).children!);
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
          //           //TODO
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
      return SizedBox();
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
