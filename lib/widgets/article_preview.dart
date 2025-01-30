import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:feederr/models/app_theme.dart';
import 'package:feederr/models/article.dart';
import 'package:feederr/utils/apiservice.dart';
import 'package:feederr/utils/dbhelper.dart';
import 'package:feederr/providers/font_provider.dart';
import 'package:feederr/providers/theme_provider.dart';
import 'package:feederr/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

class ArticlePreView extends StatefulWidget {
  final Article article;
  final int articleIndex;
  final APIService api;
  final DatabaseService databaseService;
  final AppUtils utils = AppUtils();

  ArticlePreView({
    super.key,
    required this.article,
    required this.articleIndex,
    required this.api,
    required this.databaseService,
  });

  @override
  State<ArticlePreView> createState() => _ArticlePreViewState();
}

class _ArticlePreViewState extends State<ArticlePreView> {
  bool isStyleMenuVisible = false;

  bool isPopupImageVisible = false;
  String popupImageSrc = "";
  String popupImageCaption = "";
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.sizeOf(context).width;
    Article article = widget.article;
    final document = html_parser.parse(article.summaryContent);
    return Consumer<ThemeProvider>(builder: (_, themeProvider, __) {
      final textSpan = _parseHtmlToTextSpan(document.body!, themeProvider.theme);
      return SizedBox(
        width: screenWidth,
        height: 400,
        child: Scrollbar(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            color: Color(themeProvider.theme.surfaceColor),
            child: Consumer<FontProvider>(builder: (_, fontProvider, __) {
              return SingleChildScrollView(
                padding:
                    EdgeInsets.symmetric(horizontal: fontProvider.fontSettings.articleContentWidth),
                child: Column(
                  children: [
                    Container(
                      width: screenWidth,
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SelectableText(
                        article.title,
                        textAlign: fontProvider.fontSettings.titleAlignment,
                        style: TextStyle(
                          fontSize: fontProvider.fontSettings.titleFontSize,
                          fontFamily: fontProvider.fontSettings.articleFont,
                          fontVariations: const [FontVariation('wght', 600)],
                          color: Color(themeProvider.theme.textColor),
                        ),
                      ),
                    ),
                    Container(
                      width: screenWidth,
                      padding: const EdgeInsets.only(bottom: 10),
                      child: RichText(
                        textAlign: TextAlign.left,
                        text: TextSpan(
                          text: article.originTitle,
                          style: TextStyle(
                            fontSize: fontProvider.fontSettings.articleFontSize,
                            fontFamily: fontProvider.fontSettings.articleFont,
                            fontVariations: const [FontVariation('wght', 600)],
                            color: Color(themeProvider.theme.primaryColor),
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
                                fontSize: fontProvider.fontSettings.articleFontSize,
                                fontFamily: fontProvider.fontSettings.articleFont,
                                fontVariations: const [FontVariation('wght', 300)],
                                color: Color(themeProvider.theme.textColor),
                              ),
                            ),
                            const TextSpan(
                              text: '・',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: widget.utils.timeAgo(article.published),
                              style: TextStyle(
                                fontSize: fontProvider.fontSettings.articleFontSize,
                                fontFamily: fontProvider.fontSettings.articleFont,
                                fontVariations: const [FontVariation('wght', 300)],
                                color: Color(themeProvider.theme.textColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SelectableText.rich(
                      textSpan,
                      textAlign: fontProvider.fontSettings.articleAlignment,
                      style: TextStyle(
                          height: fontProvider.fontSettings.articleLineSpacing, //line spacing
                          letterSpacing: 0, //letter spacing
                          fontSize: fontProvider.fontSettings.articleFontSize,
                          fontFamily: fontProvider.fontSettings.articleFont,
                          color: Color(themeProvider.theme.textColor),
                          fontVariations: const [FontVariation('wght', 400)]),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              );
            }),
          ),
        ),
      );
    });
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
                  fontStyle: FontStyle.italic, fontWeight: FontWeight.w500, fontSize: 14),
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
              style: TextStyle(color: Color(theme.primaryColor), decoration: TextDecoration.none),
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
                children.last is TextSpan && !(children.last as TextSpan).text!.endsWith('\n')) {
              children.add(const TextSpan(text: '\n'));
            }
            break;
          case 'br':
            if (children.isEmpty ||
                children.last is TextSpan && !(children.last as TextSpan).text!.endsWith('\n')) {
              children.add(const TextSpan(text: '\n'));
            }
            break;
          case 'p':
            if (children.isEmpty ||
                children.last is TextSpan && !(children.last as TextSpan).text!.endsWith('\n')) {
              children.add(const TextSpan(text: '\n'));
            }
            children.addAll(_parseHtmlToTextSpan(node, theme).children!);
            if (children.isEmpty ||
                children.last is TextSpan && !(children.last as TextSpan).text!.endsWith('\n')) {
              children.add(const TextSpan(text: '\n'));
            }
            break;
          case 'span':
            children.addAll(_parseHtmlToTextSpan(node, theme).children!);
            if (children.isEmpty ||
                children.last is TextSpan && !(children.last as TextSpan).text!.endsWith('\n')) {
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
                style: const TextStyle(fontStyle: FontStyle.normal, fontSize: 12.0),
              ),
            );
          case 'li':
            children.add(TextSpan(
              text: "\n◦ ${node.text}",
              style: const TextStyle(fontWeight: FontWeight.normal),
            ));
          default:
            children.addAll(_parseHtmlToTextSpan(node, theme).children!);
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
          cacheManager: widget.api.cacheManager,
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
      );
    }
  }
}
