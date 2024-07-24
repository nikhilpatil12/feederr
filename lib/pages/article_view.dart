import 'package:feederr/models/article.dart';
import 'package:feederr/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class ArticleView extends StatefulWidget {
  Article article;
  ArticleView({super.key, required this.article});

  @override
  State<ArticleView> createState() => _ArticleViewState();
}

class _ArticleViewState extends State<ArticleView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      color: const Color.fromARGB(255, 5, 0, 26),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: RichText(
                text: TextSpan(
                  text: widget.article.title,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                ),
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
            HtmlWidget(
              widget.article.summaryContent,
              customStylesBuilder: (element) {
                if (element.attributes.containsKey("href")) {
                  return {
                    'color': "0xFF4C02E8",
                    'font-weight': "bold",
                    "text-decoration-line": "none"
                  };
                }

                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
