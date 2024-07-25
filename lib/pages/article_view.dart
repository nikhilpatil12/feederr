import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:feederr/models/article.dart';
import 'package:feederr/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter/services.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

class ArticleView extends StatefulWidget {
  Article article;
  ArticleView({super.key, required this.article});

  @override
  State<ArticleView> createState() => _ArticleViewState();
}

class _ArticleViewState extends State<ArticleView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final document = html_parser.parse(widget.article.summaryContent);
    final textSpan = _parseHtmlToTextSpan(document.body!);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      color: const Color.fromARGB(255, 5, 0, 26),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: SelectableText(
                // text: TextSpan(
                // text: widget.article.title,
                widget.article.title,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
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
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color.fromRGBO(76, 2, 232, 1),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.w300,
                        color: Color.fromRGBO(231, 231, 231, 1),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.w300,
                        color: Color.fromRGBO(231, 231, 231, 1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SelectableText.rich(
              textSpan,
              style: TextStyle(fontSize: 16.0),
            ),
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
    );
  }

  TextSpan _parseHtmlToTextSpan(dom.Element element) {
    List<InlineSpan> children = [];
    element.nodes.forEach((node) {
      if (node is dom.Text) {
        children.add(TextSpan(text: node.text));
      } else if (node is dom.Element) {
        if (node.localName == 'b') {
          children.add(TextSpan(
            text: node.text,
            style: TextStyle(fontWeight: FontWeight.bold),
          ));
        } else if (node.localName == 'i') {
          children.add(TextSpan(
            text: node.text,
            style: TextStyle(fontStyle: FontStyle.italic),
          ));
        } else if (node.localName == 'a') {
          final url = node.attributes['href'];
          children.add(TextSpan(
            text: node.text,
            style: const TextStyle(
                color: Color.fromRGBO(76, 2, 232, 1),
                decoration: TextDecoration.none),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                if (url != null) {
                  launchUrl(Uri.parse(url));
                }
              },
          ));
        } else if (node.localName == 'img') {
          final src = node.attributes['src'];
          if (src != null) {
            children.add(
              WidgetSpan(
                child: _showImage(src),
              ),
            );
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
          }
        } else {
          children.add(_parseHtmlToTextSpan(node));
        }
      }
    });
    return TextSpan(children: children);
  }

  GestureDetector _showImage(String src) {
    if (src.startsWith('data:image/')) {
      // Handle Base64 image
      final base64Data = src.split(',').last;
      final imageBytes = base64Decode(base64Data);
      return GestureDetector(
        onLongPress: () async {
          //TODO
          // _showBlurMenu(context);
        },
        child: Image.memory(Uint8List.fromList(imageBytes)),
      );
    } else {
      return GestureDetector(
        onLongPress: () async {
          //TODO:
          // _showBlurMenu(context);
        },
        child: Image.network(
          src,
          errorBuilder: (context, exception, stackTrace) {
            return const SizedBox(height: 40);
          },
        ),
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
