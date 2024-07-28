import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:feederr/models/article.dart';
import 'package:feederr/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
              padding: const EdgeInsets.only(bottom: 10),
              child: SelectableText(
                // text: TextSpan(
                // text: widget.article.title,
                widget.article.title,
                style:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
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
              style: const TextStyle(fontSize: 16.0),
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
            for (var element in node.children) {
              if (element.localName == "span") {
                children.addAll(_parseHtmlToTextSpan(node).children!);
              }
            }
          // _parseHtmlToTextSpan(node).children!.any((x)=>x.=="img");

          case 'img':
            children.add(const TextSpan(text: '\n'));
            final src = node.attributes['src'];
            if (src != null) {
              children.add(
                WidgetSpan(
                  child: _showImage(src),
                ),
              );
            }
            children.add(const TextSpan(text: '\n'));
          case 'br':
            children.add(const TextSpan(text: '\n'));
            break;
          case 'p':
            children.add(const TextSpan(text: '\n'));
            children.addAll(_parseHtmlToTextSpan(node).children!);
            children.add(const TextSpan(text: '\n'));
            break;
          case 'span':
            children.addAll(_parseHtmlToTextSpan(node).children!);
            break;
          case 'div':
            children.addAll(_parseHtmlToTextSpan(node).children!);
            break;
          case 'figure':
            children.addAll(_parseHtmlToTextSpan(node).children!);
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
            children.addAll(_parseHtmlToTextSpan(node).children!);
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
        child: CachedNetworkImage(
          imageUrl: src,
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              const CupertinoActivityIndicator(),
          errorWidget: (context, url, error) => Container(),
        ),
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
